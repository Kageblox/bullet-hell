class_name MapLayout
extends Node3D

# Uses component/map/gen.gd

@export var map_width: int = 100
@export var map_height: int = 100
@export var starting_width: int = 15
@export var starting_height: int = 15
@export var steps: int = 2000
@export var min_size: int = 6
@export var max_size: int = 22
@export var variance: int = 2
@export var tile_size: float = 1.0
@export var chunk_size: int = 12
@export var max_active_lights: int = 8

var generator: Gen.LayoutGenerator
var room_lights: Array[Light3D] = []

func _enter_tree() -> void:
	generator = Gen.Generator.Run(
		map_width,
		map_height,
		starting_width,
		starting_height,
		steps,
		min_size,
		max_size,
		variance
	)
	# var ascii := generator.ToString()
	# generator.Print()
	# print(ascii)
	_build_geometry(generator)
	_build_navmesh(generator)
	_build_lights(generator)

func get_generator() -> Gen.LayoutGenerator:
	return generator

func _process(_delta: float) -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null or room_lights.is_empty():
		return
	var cam_pos: Vector3 = cam.global_position
	var sorted: Array[Light3D] = room_lights.duplicate()
	sorted.sort_custom(func(a, b):
		return a.global_position.distance_squared_to(cam_pos) < b.global_position.distance_squared_to(cam_pos)
	)
	for i in range(sorted.size()):
		sorted[i].visible = i < max_active_lights

# World space pos
func room_index_at(pos: Vector3) -> int:
	if generator == null:
		return 0
	var offset_x: float = -generator.MapWidth * tile_size * 0.5
	var offset_z: float = -generator.MapHeight * tile_size * 0.5
	var i: int = int(floor((pos.x - offset_x) / tile_size + 0.5))
	var j: int = int(floor((pos.z - offset_z) / tile_size + 0.5))
	return generator.RoomIndexAt(i, j)

func room_at(pos: Vector3) -> Gen.Room:
	if generator == null:
		return null
	var index: int = room_index_at(pos)
	if index > 0:
		return generator.rooms[index]
	else:
		return null

func _build_geometry(layout) -> void:
	var floor_tex: Texture2D = load("res://images(png)/map/sewer_floor.png")
	var floor_mats: Array[StandardMaterial3D] = []
	for q in range(4):
		var m := StandardMaterial3D.new()
		m.albedo_texture = floor_tex
		m.albedo_color = Color(0.13, 0.16, 0.13)
		m.metallic_specular = 0.0
		m.roughness = 1.0
		m.uv1_scale = Vector3(0.5, 0.5, 1.0)
		m.uv1_offset = Vector3(float(q & 1) * 0.5, float((q >> 1) & 1) * 0.5, 0.0)
		floor_mats.append(m)
	var wall_mat := StandardMaterial3D.new()
	wall_mat.albedo_texture = floor_tex
	wall_mat.albedo_color = Color(0.25, 0.25, 0.25)
	wall_mat.metallic_specular = 0.0
	wall_mat.roughness = 1.0

	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(tile_size, tile_size)
	var wall_mesh := BoxMesh.new()
	wall_mesh.size = Vector3(tile_size, tile_size, tile_size)
	var column_mesh := CylinderMesh.new()
	column_mesh.top_radius = tile_size * 0.4
	column_mesh.bottom_radius = tile_size * 0.4
	column_mesh.height = tile_size

	var offset_x: float = -layout.MapWidth * tile_size * 0.5
	var offset_z: float = -layout.MapHeight * tile_size * 0.5

	@warning_ignore("integer_division")
	var chunks_x: int = (layout.MapWidth + chunk_size - 1) / chunk_size
	@warning_ignore("integer_division")
	var chunks_z: int = (layout.MapHeight + chunk_size - 1) / chunk_size

	for ccz in range(chunks_z):
		for ccx in range(chunks_x):
			var floor_sts: Array[SurfaceTool] = []
			var floor_counts: Array[int] = [0, 0, 0, 0]
			for q in range(4):
				var st := SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				floor_sts.append(st)
			var wall_st := SurfaceTool.new()
			wall_st.begin(Mesh.PRIMITIVE_TRIANGLES)
			var wall_count: int = 0

			var i_start: int = ccx * chunk_size
			var j_start: int = ccz * chunk_size
			var i_end: int = min(i_start + chunk_size, layout.MapWidth)
			var j_end: int = min(j_start + chunk_size, layout.MapHeight)

			for j in range(j_start, j_end):
				for i in range(i_start, i_end):
					var ch: String = layout.At(i, j)
					var x: float = offset_x + i * tile_size
					var z: float = offset_z + j * tile_size
					var quad: int = (i & 1) | ((j & 1) << 1)
					if ch == '.':
						floor_sts[quad].append_from(floor_mesh, 0, Transform3D(Basis(), Vector3(x, 0.0, z)))
						floor_counts[quad] += 1
					elif ch == '|' or ch == '-':
						floor_sts[quad].append_from(floor_mesh, 0, Transform3D(Basis(), Vector3(x, 0.0, z)))
						wall_st.append_from(wall_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * 2.5, z)))
						floor_counts[quad] += 1
						wall_count += 1
					elif ch == "V" or ch == "H" or ch == "#":
						for k in range(3):
							wall_st.append_from(wall_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * (0.5 + k), z)))
						wall_count += 1
					elif ch == "P":
						floor_sts[quad].append_from(floor_mesh, 0, Transform3D(Basis(), Vector3(x, 0.0, z)))
						for k in range(3):
							wall_st.append_from(column_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * (0.5 + k), z)))
						floor_counts[quad] += 1
						wall_count += 1

			var total_floor: int = floor_counts[0] + floor_counts[1] + floor_counts[2] + floor_counts[3]
			if total_floor == 0 and wall_count == 0:
				continue

			var baked := ArrayMesh.new()
			var surface: int = 0
			for q in range(4):
				if floor_counts[q] > 0:
					floor_sts[q].commit(baked)
					baked.surface_set_material(surface, floor_mats[q])
					surface += 1
			if wall_count > 0:
				wall_st.commit(baked)
				baked.surface_set_material(surface, wall_mat)

			var mi := MeshInstance3D.new()
			mi.name = "Chunk_%d_%d" % [ccx, ccz]
			mi.mesh = baked
			add_child(mi)
			mi.create_trimesh_collision()

func _build_lights(layout) -> void:
	var offset_x: float = -layout.MapWidth * tile_size * 0.5
	var offset_z: float = -layout.MapHeight * tile_size * 0.5
	var height: float = tile_size * 2.5
	for r in layout.mainRooms.values():
		var cx: float = offset_x + (r.x + r.w * 0.5) * tile_size
		var cz: float = offset_z + (r.y + r.h * 0.5) * tile_size
		var extent: float = max(r.w, r.h) * 0.6 * tile_size
		var light := OmniLight3D.new()
		light.light_color = Color(
			clamp(1.0 + randf_range(-0.05, 0.05), 0.0, 1.0),
			clamp(0.95 + randf_range(-0.07, 0.05), 0.0, 1.0),
			clamp(0.7 + randf_range(-0.1, 0.1), 0.0, 1.0)
		)
		light.light_energy = 32.0
		light.light_specular = 0.0
		light.omni_range = sqrt(height * height + extent * extent) * 2.5
		light.omni_attenuation = 0.5
		light.position = Vector3(cx, height, cz)
		add_child(light)
		room_lights.append(light)

func _build_navmesh(layout) -> void:
	var vertices := PackedVector3Array()
	var corner_index := {}
	var polygons: Array[PackedInt32Array] = []
	var offset_x: float = -layout.MapWidth * tile_size * 0.5
	var offset_z: float = -layout.MapHeight * tile_size * 0.5

	for j in range(layout.MapHeight):
		for i in range(layout.MapWidth):
			var ch: String = layout.At(i, j)
			if ch != ".":
				continue
			# CCW from +Y
			var corners := [
				Vector2i(i, j),
				Vector2i(i, j + 1),
				Vector2i(i + 1, j + 1),
				Vector2i(i + 1, j),
			]
			var poly := PackedInt32Array()
			for c in corners:
				if not corner_index.has(c):
					corner_index[c] = vertices.size()
					vertices.append(Vector3(
						offset_x + (c.x - 0.5) * tile_size,
						0.0,
						offset_z + (c.y - 0.5) * tile_size
					))
				poly.append(corner_index[c])
			polygons.append(poly)

	var nav_mesh := NavigationMesh.new()
	nav_mesh.vertices = vertices
	for p in polygons:
		nav_mesh.add_polygon(p)

	var region := NavigationRegion3D.new()
	region.name = "NavRegion"
	region.navigation_mesh = nav_mesh
	add_child(region)
