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

var generator: Gen.LayoutGenerator
var room_lights: Array  # Array[Light3D]

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

func get_generator() -> Gen.LayoutGenerator:
	return generator

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
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.0, 0.3, 0.1)
	var wall_mat := StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.4, 0.25, 0.1)

	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(tile_size, tile_size)
	var wall_mesh := BoxMesh.new()
	wall_mesh.size = Vector3(tile_size, tile_size, tile_size)
	var column_mesh := CylinderMesh.new()
	column_mesh.top_radius = tile_size * 0.4
	column_mesh.bottom_radius = tile_size * 0.4
	column_mesh.height = tile_size

	var floor_st := SurfaceTool.new()
	floor_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var wall_st := SurfaceTool.new()
	wall_st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var offset_x: float = -layout.MapWidth * tile_size * 0.5
	var offset_z: float = -layout.MapHeight * tile_size * 0.5
	for j in range(layout.MapHeight):
		for i in range(layout.MapWidth):
			var ch: String = layout.At(i, j)
			var x: float = offset_x + i * tile_size
			var z: float = offset_z + j * tile_size
			if ch == '.':
				floor_st.append_from(floor_mesh, 0, Transform3D(Basis(), Vector3(x, 0.0, z)))
			elif ch == '|' or ch == '-':
				floor_st.append_from(floor_mesh, 0, Transform3D(Basis(), Vector3(x, 0.0, z)))
				wall_st.append_from(wall_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * 2.5, z)))
			elif ch == "V" or ch == "H" or ch == "#":
				for k in range(3):
					wall_st.append_from(wall_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * (0.5 + k), z)))
			elif ch == "P":
				floor_st.append_from(floor_mesh, 0, Transform3D(Basis(), Vector3(x, 0.0, z)))
				for k in range(3):
					wall_st.append_from(column_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * (0.5 + k), z)))

	var baked := ArrayMesh.new()
	floor_st.commit(baked)
	wall_st.commit(baked)
	baked.surface_set_material(0, floor_mat)
	baked.surface_set_material(1, wall_mat)

	var mi := MeshInstance3D.new()
	mi.name = "Static"
	mi.mesh = baked
	add_child(mi)
	mi.create_trimesh_collision()

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
