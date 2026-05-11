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
@export var props_per_room_min: int = 3
@export var props_per_room_max: int = 8
@export var prop_min_occlusion: float = 0.5
@export var crate_scale: float = 1.0
@export var trash_scale: float = 1.0
@export var barrel_scale: float = 0.5

@export var player_tint_strength: float = 0.9
@export var player_tint_smooth_speed: float = 5.0
@export var light_fade_speed: float = 4.0

var generator: Gen.LayoutGenerator
var room_nodes: Dictionary = {}
var room_neighbors: Dictionary = {}
var room_doors: Dictionary = {}
var room_lights: Dictionary = {}
var room_light_colors: Dictionary = {}
var room_light_base_energy: Dictionary = {}
var _last_active_rooms: Dictionary = {}
var _last_known_room: int = 0
var _player_tint: Color = Color.WHITE
var _player_sprite: AnimatedSprite3D = null

func _enter_tree() -> void:
	GameManager.map = self
	
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
	_build_geometry(generator)
	_build_navmesh(generator)
	_build_rooms(generator)
	_build_lights(generator)
	_build_doors(generator)
	_build_props(generator)

func get_room_aabb(room_id: int) -> AABB:
	if generator == null or not generator.rooms.has(room_id):
		return AABB()
	var r = generator.rooms[room_id]
	var offset_x: float = -generator.MapWidth * tile_size * 0.5
	var offset_z: float = -generator.MapHeight * tile_size * 0.5
	var min_x: float = offset_x + r.x * tile_size - tile_size * 0.5
	var min_z: float = offset_z + r.y * tile_size - tile_size * 0.5
	var size_x: float = r.w * tile_size
	var size_z: float = r.h * tile_size
	return AABB(Vector3(min_x, 0.0, min_z), Vector3(size_x, tile_size * 2.0, size_z))

func get_generator() -> Gen.LayoutGenerator:
	return generator

func _build_rooms(layout) -> void:
	for r in layout.rooms.values():
		var room_node := Node3D.new()
		room_node.name = "Room_" + str(r.id)
		add_child(room_node)
		room_nodes[r.id] = room_node
		room_neighbors[r.id] = []
		room_doors[r.id] = []

func get_room_doors(room_id: int) -> Array:
	return room_doors.get(room_id, [])

func _process(delta: float) -> void:
	var player_pos: Vector3 = _get_player_position()
	if player_pos == Vector3.INF:
		return
	var current: int = room_index_at(player_pos)
	if current > 0:
		_last_known_room = current
	_apply_player_tint(_last_known_room, delta)

	var active: Dictionary = _last_active_rooms
	if current > 0:
		active = {current: true}
		if room_neighbors.has(current):
			for n in room_neighbors[current]:
				active[n] = true
		if active != _last_active_rooms:
			for id in room_nodes:
				var node: Node3D = room_nodes[id]
				var on: bool = active.has(id)
				if node.visible != on:
					node.visible = on
					node.process_mode = Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED
			_last_active_rooms = active
	_apply_light_fade(active, delta)

func _apply_light_fade(active: Dictionary, delta: float) -> void:
	var t: float = clamp(light_fade_speed * delta, 0.0, 1.0)
	for id in room_lights:
		var light: Light3D = room_lights[id]
		var target: float = room_light_base_energy.get(id, 0.0) if active.has(id) else 0.0
		light.light_energy = lerp(light.light_energy, target, t)
		light.visible = light.light_energy > 0.01

func _apply_player_tint(room_id: int, delta: float) -> void:
	var target: Color = Color.WHITE
	if room_light_colors.has(room_id):
		target = Color.WHITE.lerp(room_light_colors[room_id], player_tint_strength)
	var t: float = clamp(player_tint_smooth_speed * delta, 0.0, 1.0)
	_player_tint = _player_tint.lerp(target, t)
	if _player_sprite == null or not is_instance_valid(_player_sprite):
		var p = GameManager.player
		if p != null and "sprite" in p and p.sprite is AnimatedSprite3D:
			_player_sprite = p.sprite
	if _player_sprite != null:
		_player_sprite.modulate = _player_tint

func _get_player_position() -> Vector3:
	var player = GameManager.player
	if player == null:
		return Vector3.INF
	if "rigid_body_component" in player and player.rigid_body_component != null:
		return player.rigid_body_component.global_position
	return player.global_position

# World space position -> room
func room_index_at(pos: Vector3) -> int:
	if generator == null:
		return 0
	var offset_x: float = -generator.MapWidth * tile_size * 0.5
	var offset_z: float = -generator.MapHeight * tile_size * 0.5
	var i: int = int(floor((pos.x - offset_x) / tile_size + 0.5))
	var j: int = int(floor((pos.z - offset_z) / tile_size + 0.5))
	return generator.RoomIndexAt(i, j)

func tile_at(pos: Vector3) -> String:
	if generator == null:
		return " "
	var offset_x: float = -generator.MapWidth * tile_size * 0.5
	var offset_z: float = -generator.MapHeight * tile_size * 0.5
	var i: int = int(floor((pos.x - offset_x) / tile_size + 0.5))
	var j: int = int(floor((pos.z - offset_z) / tile_size + 0.5))
	return generator.At(i, j)

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

	var wall_bottom_shader := Shader.new()
	wall_bottom_shader.code = """
shader_type spatial;
uniform sampler2D albedo_tex : source_color, filter_linear;
uniform vec3 wall_tint : source_color = vec3(0.25);
uniform vec3 floor_tint : source_color = vec3(0.13, 0.16, 0.13);
uniform float fade_top = 1.0;
uniform float fade_bottom = 0.0;
varying float world_y;
void vertex() {
	world_y = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}
void fragment() {
	float t = smoothstep(fade_bottom, fade_top, world_y);
	vec3 tint = mix(floor_tint, wall_tint, t);
	ALBEDO = texture(albedo_tex, UV).rgb * tint;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
}
"""
	var wall_bottom_mat := ShaderMaterial.new()
	wall_bottom_mat.shader = wall_bottom_shader
	wall_bottom_mat.set_shader_parameter("albedo_tex", floor_tex)
	wall_bottom_mat.set_shader_parameter("wall_tint", Vector3(0.25, 0.25, 0.25))
	wall_bottom_mat.set_shader_parameter("floor_tint", Vector3(0.13, 0.16, 0.13))
	wall_bottom_mat.set_shader_parameter("fade_top", tile_size)
	wall_bottom_mat.set_shader_parameter("fade_bottom", 0.0)

	var wall_top_mat := ShaderMaterial.new()
	wall_top_mat.shader = wall_bottom_shader
	wall_top_mat.set_shader_parameter("albedo_tex", floor_tex)
	wall_top_mat.set_shader_parameter("wall_tint", Vector3(0.0, 0.0, 0.0))
	wall_top_mat.set_shader_parameter("floor_tint", Vector3(0.25, 0.25, 0.25))
	wall_top_mat.set_shader_parameter("fade_top", tile_size * 3.0)
	wall_top_mat.set_shader_parameter("fade_bottom", tile_size * 2.0)

	var floor_mesh: ArrayMesh = _make_unit_cube_mesh()
	var floor_y_offset: float = -tile_size * 0.5
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
			var wall_bottom_st := SurfaceTool.new()
			wall_bottom_st.begin(Mesh.PRIMITIVE_TRIANGLES)
			var wall_bottom_count: int = 0
			var wall_top_st := SurfaceTool.new()
			wall_top_st.begin(Mesh.PRIMITIVE_TRIANGLES)
			var wall_top_count: int = 0

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
					if ch == '.' or ch == 'c' or ch == 'C' or ch == 'v' or ch == 'h':
						floor_sts[quad].append_from(floor_mesh, 0, Transform3D(Basis(), Vector3(x, floor_y_offset, z)))
						floor_counts[quad] += 1
					elif ch == '|' or ch == '-':
						floor_sts[quad].append_from(floor_mesh, 0, Transform3D(Basis(), Vector3(x, floor_y_offset, z)))
						wall_top_st.append_from(wall_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * 2.5, z)))
						floor_counts[quad] += 1
						wall_top_count += 1
					elif ch == "V" or ch == "H" or ch == "#":
						wall_bottom_st.append_from(wall_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * 0.5, z)))
						wall_bottom_count += 1
						wall_st.append_from(wall_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * 1.5, z)))
						wall_count += 1
						wall_top_st.append_from(wall_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * 2.5, z)))
						wall_top_count += 1
					elif ch == "P":
						floor_sts[quad].append_from(floor_mesh, 0, Transform3D(Basis(), Vector3(x, floor_y_offset, z)))
						for k in range(3):
							wall_st.append_from(column_mesh, 0, Transform3D(Basis(), Vector3(x, tile_size * (0.5 + k), z)))
						floor_counts[quad] += 1
						wall_count += 1

			var total_floor: int = floor_counts[0] + floor_counts[1] + floor_counts[2] + floor_counts[3]
			if total_floor == 0 and wall_count == 0 and wall_bottom_count == 0 and wall_top_count == 0:
				continue

			if total_floor > 0:
				var floor_baked := ArrayMesh.new()
				var floor_surface: int = 0
				for q in range(4):
					if floor_counts[q] > 0:
						floor_sts[q].commit(floor_baked)
						floor_baked.surface_set_material(floor_surface, floor_mats[q])
						floor_surface += 1
				var floor_mi := MeshInstance3D.new()
				floor_mi.name = "ChunkFloor_%d_%d" % [ccx, ccz]
				floor_mi.mesh = floor_baked
				add_child(floor_mi)
				floor_mi.create_trimesh_collision()
				_set_collision_layer(floor_mi, 2)

			if wall_count > 0 or wall_bottom_count > 0 or wall_top_count > 0:
				var walls_baked := ArrayMesh.new()
				var walls_surface: int = 0
				if wall_count > 0:
					wall_st.commit(walls_baked)
					walls_baked.surface_set_material(walls_surface, wall_mat)
					walls_surface += 1
				if wall_bottom_count > 0:
					wall_bottom_st.commit(walls_baked)
					walls_baked.surface_set_material(walls_surface, wall_bottom_mat)
					walls_surface += 1
				if wall_top_count > 0:
					wall_top_st.commit(walls_baked)
					walls_baked.surface_set_material(walls_surface, wall_top_mat)
				var walls_mi := MeshInstance3D.new()
				walls_mi.name = "ChunkWalls_%d_%d" % [ccx, ccz]
				walls_mi.mesh = walls_baked
				add_child(walls_mi)
				walls_mi.create_trimesh_collision()
				_set_collision_layer(walls_mi, 1)

func _make_unit_cube_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var s: float = tile_size * 0.5
	_add_face(st, Vector3(s, -s, s), Vector3(s, -s, -s), Vector3(s, s, -s), Vector3(s, s, s), Vector3.RIGHT)
	_add_face(st, Vector3(-s, -s, -s), Vector3(-s, -s, s), Vector3(-s, s, s), Vector3(-s, s, -s), Vector3.LEFT)
	_add_face(st, Vector3(-s, s, s), Vector3(s, s, s), Vector3(s, s, -s), Vector3(-s, s, -s), Vector3.UP)
	_add_face(st, Vector3(-s, -s, -s), Vector3(s, -s, -s), Vector3(s, -s, s), Vector3(-s, -s, s), Vector3.DOWN)
	_add_face(st, Vector3(-s, -s, s), Vector3(s, -s, s), Vector3(s, s, s), Vector3(-s, s, s), Vector3.BACK)
	_add_face(st, Vector3(s, -s, -s), Vector3(-s, -s, -s), Vector3(-s, s, -s), Vector3(s, s, -s), Vector3.FORWARD)
	return st.commit()

func _add_face(st: SurfaceTool, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, n: Vector3) -> void:
	st.set_normal(n); st.set_uv(Vector2(0, 1)); st.add_vertex(p0)
	st.set_normal(n); st.set_uv(Vector2(0, 0)); st.add_vertex(p3)
	st.set_normal(n); st.set_uv(Vector2(1, 0)); st.add_vertex(p2)
	st.set_normal(n); st.set_uv(Vector2(0, 1)); st.add_vertex(p0)
	st.set_normal(n); st.set_uv(Vector2(1, 0)); st.add_vertex(p2)
	st.set_normal(n); st.set_uv(Vector2(1, 1)); st.add_vertex(p1)

const MapDoorScript = preload("res://scripts(gd)/component/map/door.gd")

func _build_doors(layout) -> void:
	var door_mat := StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.04, 0.025, 0.015)
	door_mat.metallic_specular = 0.0
	door_mat.roughness = 1.0
	door_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	door_mat.emission_enabled = false

	var offset_x: float = -layout.MapWidth * tile_size * 0.5
	var offset_z: float = -layout.MapHeight * tile_size * 0.5

	for j in range(layout.MapHeight):
		for i in range(layout.MapWidth):
			var ch: String = layout.At(i, j)
			if ch == "-":
				var left_ch: String = layout.At(i - 1, j) if i > 0 else "#"
				var right_ch: String = layout.At(i + 1, j) if i + 1 < layout.MapWidth else "#"
				if left_ch != "-" and right_ch == "-":
					var cx: float = offset_x + (i + 0.5) * tile_size
					var cz: float = offset_z + j * tile_size
					var room_a: int = layout.RoomIndexAt(i, j - 1)
					var room_b: int = layout.RoomIndexAt(i, j + 1)
					_register_room_pair(room_a, room_b)
					_place_door(ch, cx, cz, door_mat, room_a, room_b)
			elif ch == "|":
				var above_ch: String = layout.At(i, j - 1) if j > 0 else "#"
				var below_ch: String = layout.At(i, j + 1) if j + 1 < layout.MapHeight else "#"
				if above_ch != "|" and below_ch == "|":
					var cx: float = offset_x + i * tile_size
					var cz: float = offset_z + (j + 0.5) * tile_size
					var room_a: int = layout.RoomIndexAt(i - 1, j)
					var room_b: int = layout.RoomIndexAt(i + 1, j)
					_register_room_pair(room_a, room_b)
					_place_door(ch, cx, cz, door_mat, room_a, room_b)

func _register_room_pair(a: int, b: int) -> void:
	if a <= 0 or b <= 0 or a == b:
		return
	if not room_nodes.has(a) or not room_nodes.has(b):
		return
	if not room_neighbors[a].has(b):
		room_neighbors[a].append(b)
	if not room_neighbors[b].has(a):
		room_neighbors[b].append(a)

func _place_door(ch: String, x: float, z: float, mat: StandardMaterial3D, room_a: int, room_b: int) -> void:
	var door_thickness: float = tile_size * 0.12
	var half_width: float = tile_size * 0.99
	var door_height: float = tile_size * 2.0

	var door = MapDoorScript.new()
	door.position = Vector3(x, 0.0, z)
	if ch == "|":
		door.rotation.y = PI * 0.5

	var left_hinge := _make_door_half(half_width, door_height, door_thickness, mat, true)
	left_hinge.position = Vector3(-tile_size, 0.0, 0.0)
	var right_hinge := _make_door_half(half_width, door_height, door_thickness, mat, false)
	right_hinge.position = Vector3(tile_size, 0.0, 0.0)

	door.add_child(left_hinge)
	door.add_child(right_hinge)
	door.left_hinge = left_hinge
	door.right_hinge = right_hinge

	var body := StaticBody3D.new()
	body.collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(tile_size * 2.0, door_height, door_thickness)
	shape.shape = box
	shape.position = Vector3(0.0, door_height * 0.5, 0.0)
	shape.disabled = true
	body.add_child(shape)
	door.add_child(body)
	door.collider = shape

	var connecting: Array[int] = []
	if room_a > 0:
		connecting.append(room_a)
	if room_b > 0 and room_b != room_a:
		connecting.append(room_b)
	door.connecting_rooms = connecting

	var parent_id: int = room_a if room_a > 0 else room_b
	var parent: Node = room_nodes.get(parent_id, self)
	parent.add_child(door)

	if room_a > 0 and room_doors.has(room_a):
		room_doors[room_a].append(door)
	if room_b > 0 and room_doors.has(room_b) and room_b != room_a:
		room_doors[room_b].append(door)

func _make_door_half(half_width: float, height: float, thickness: float, mat: StandardMaterial3D, extends_positive_x: bool) -> Node3D:
	var hinge := Node3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(half_width, height, thickness)
	var mi := MeshInstance3D.new()
	mi.mesh = box_mesh
	mi.set_surface_override_material(0, mat)
	var x_off: float = half_width * 0.5 if extends_positive_x else -half_width * 0.5
	mi.position = Vector3(x_off, height * 0.5, 0)
	hinge.add_child(mi)
	return hinge

func _build_props(layout) -> void:
	var crate_mat := StandardMaterial3D.new()
	crate_mat.albedo_texture = load("res://images(png)/map/crate2_diff.png")
	crate_mat.albedo_color = Color(0.2, 0.2, 0.2)
	crate_mat.metallic_specular = 0.0
	crate_mat.roughness = 1.0
	crate_mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	crate_mat.emission_enabled = false

	var crate_mesh := _make_unit_cube_mesh()
	crate_mesh.surface_set_material(0, crate_mat)

	var trash_mat := _make_prop_material("res://scene(tscn)/props/TrashBag_TrashBag.png", Color(0.2, 0.2, 0.2))
	var trash_meshes: Array[Mesh] = [
		load("res://scene(tscn)/props/TrashBag_Cube_002.res"),
		load("res://scene(tscn)/props/TrashBag_Cube_003.res"),
		load("res://scene(tscn)/props/TrashBag_Cube_004.res"),
	]

	var barrel_mat := _make_prop_material("res://scene(tscn)/props/Barrels_Barrels.png", Color(0.2, 0.2, 0.2))
	var barrel_meshes: Array[Mesh] = [
		load("res://scene(tscn)/props/Barrels_Cylinder.res"),
		load("res://scene(tscn)/props/Barrels_Cylinder_001.res"),
	]

	var offset_x: float = -layout.MapWidth * tile_size * 0.5
	var offset_z: float = -layout.MapHeight * tile_size * 0.5

	var mesh_table: Dictionary = {
		"crate": crate_mesh,
		"trash_0": trash_meshes[0],
		"trash_1": trash_meshes[1],
		"trash_2": trash_meshes[2],
		"barrel_0": barrel_meshes[0],
		"barrel_1": barrel_meshes[1],
	}
	var material_table: Dictionary = {
		"trash_0": trash_mat, "trash_1": trash_mat, "trash_2": trash_mat,
		"barrel_0": barrel_mat, "barrel_1": barrel_mat,
	}

	var placed: Array = []

	for r in layout.mainRooms.values():
		var n: int = randi_range(props_per_room_min, props_per_room_max)
		for k in range(n):
			var attempts: int = 32
			while attempts > 0:
				var i: int = randi_range(r.x + 1, r.x + r.w - 2)
				var j: int = randi_range(r.y + 1, r.y + r.h - 2)
				if layout.At(i, j) == "." and not _near_door(layout, i, j, 2) and layout.occlusion[j][i] >= prop_min_occlusion and randf() < pow(layout.occlusion[j][i], 3.0):
					var x: float = offset_x + i * tile_size
					var z: float = offset_z + j * tile_size
					match randi() % 3:
						0:
							_record_crate(crate_mesh, x, z, crate_scale, placed)
						1:
							var idx: int = randi() % trash_meshes.size()
							_record_mesh_prop(trash_meshes[idx], "trash_" + str(idx), x, z, 0.8, 1.1, trash_scale, placed)
						2:
							var idx2: int = randi() % barrel_meshes.size()
							_record_mesh_prop(barrel_meshes[idx2], "barrel_" + str(idx2), x, z, 0.9, 1.1, barrel_scale, placed)
					break
				attempts -= 1

	var kept: Array = _filter_overlapping_props(placed)
	_spawn_prop_multimeshes(kept, mesh_table, material_table)

func _filter_overlapping_props(placed: Array) -> Array:
	var kept: Array = []
	for entry in placed:
		var entry_aabb: AABB = entry["aabb"]
		var overlaps: bool = false
		for k in kept:
			if entry_aabb.intersects(k["aabb"]):
				overlaps = true
				break
		if not overlaps:
			kept.append(entry)
	return kept

func _spawn_prop_multimeshes(kept: Array, mesh_table: Dictionary, material_table: Dictionary) -> void:
	var transforms_by_key: Dictionary = {}
	var props_body := StaticBody3D.new()
	props_body.collision_layer = 1
	add_child(props_body)

	for entry in kept:
		for c in entry["contributions"]:
			var key: String = c["mesh_key"]
			if not transforms_by_key.has(key):
				transforms_by_key[key] = []
			transforms_by_key[key].append(c["mesh_transform"])

			var cs := CollisionShape3D.new()
			cs.shape = c["collider_shape"]
			cs.transform = c["collider_transform"]
			props_body.add_child(cs)

	for key in transforms_by_key:
		var transforms: Array = transforms_by_key[key]
		if transforms.is_empty():
			continue
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = mesh_table[key]
		mm.instance_count = transforms.size()
		for i in range(transforms.size()):
			mm.set_instance_transform(i, transforms[i])
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		if material_table.has(key):
			mmi.material_override = material_table[key]
		mmi.gi_mode = GeometryInstance3D.GI_MODE_STATIC
		add_child(mmi)

func _record_crate(crate_mesh: Mesh, x: float, z: float, scale_factor: float, placed: Array) -> void:
	var s: float = randf_range(0.7, 1.1) * scale_factor
	var rot_y: float = randf() * TAU
	var aabb_local: AABB = crate_mesh.get_aabb()
	var contributions: Array = [_make_prop_contribution("crate", aabb_local, Vector3(x, tile_size * s * 0.5, z), rot_y, s)]

	var base_half: float = tile_size * s * 0.5
	var stack_height: float = tile_size * s

	if randf() < 0.5:
		var s2: float = randf_range(0.5, 0.9) * s
		var rot2: float = randf() * TAU
		contributions.append(_make_prop_contribution("crate", aabb_local, Vector3(x, tile_size * s + tile_size * s2 * 0.5, z), rot2, s2))
		stack_height = tile_size * s + tile_size * s2

	placed.append({
		"contributions": contributions,
		"aabb": AABB(Vector3(x - base_half, 0.0, z - base_half), Vector3(tile_size * s, stack_height, tile_size * s)),
	})

func _record_mesh_prop(mesh: Mesh, mesh_key: String, x: float, z: float, scale_min: float, scale_max: float, scale_factor: float, placed: Array) -> void:
	var s: float = randf_range(scale_min, scale_max) * scale_factor
	var rot_y: float = randf() * TAU
	var aabb_local: AABB = mesh.get_aabb()
	var mesh_pos: Vector3 = Vector3(x, -aabb_local.position.y * s, z)
	var contributions: Array = [_make_prop_contribution(mesh_key, aabb_local, mesh_pos, rot_y, s)]
	placed.append({
		"contributions": contributions,
		"aabb": AABB(Vector3(aabb_local.position.x * s + x, 0.0, aabb_local.position.z * s + z), aabb_local.size * s),
	})

func _make_prop_contribution(mesh_key: String, aabb_local: AABB, mesh_pos: Vector3, rot_y: float, s: float) -> Dictionary:
	var rot_basis: Basis = Basis(Vector3.UP, rot_y)
	var mesh_transform: Transform3D = Transform3D(rot_basis.scaled(Vector3.ONE * s), mesh_pos)
	var aabb_local_center: Vector3 = aabb_local.position + aabb_local.size * 0.5
	var collider_world_center: Vector3 = mesh_pos + rot_basis * (aabb_local_center * s)
	var collider_shape := BoxShape3D.new()
	collider_shape.size = aabb_local.size * s
	return {
		"mesh_key": mesh_key,
		"mesh_transform": mesh_transform,
		"collider_shape": collider_shape,
		"collider_transform": Transform3D(rot_basis, collider_world_center),
	}

func _make_prop_material(texture_path: String, tint: Color = Color(0.2, 0.2, 0.2)) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(texture_path)
	mat.albedo_color = tint
	mat.metallic_specular = 0.0
	mat.roughness = 1.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.emission_enabled = false
	return mat

func _set_collision_layer(mi: MeshInstance3D, layer_mask: int) -> void:
	for child in mi.get_children():
		if child is StaticBody3D:
			(child as StaticBody3D).collision_layer = layer_mask
			return

func _near_door(layout, i: int, j: int, radius: int) -> bool:
	for dj in range(-radius, radius + 1):
		for di in range(-radius, radius + 1):
			var ch: String = layout.At(i + di, j + dj)
			if ch == "|" or ch == "-":
				return true
	return false

func _build_lights(layout) -> void:
	var offset_x: float = -layout.MapWidth * tile_size * 0.5
	var offset_z: float = -layout.MapHeight * tile_size * 0.5
	var height: float = tile_size * 2.5
	for r in layout.mainRooms.values():
		var cx: float = offset_x + (r.x + r.w * 0.5) * tile_size
		var cz: float = offset_z + (r.y + r.h * 0.5) * tile_size
		var extent: float = max(r.w, r.h) * 0.6 * tile_size
		var light := OmniLight3D.new()
		var base := Color(1.0, 0.95, 0.7)
		var base_hsv := { "h": base.h, "s": base.s, "v": base.v }
		var hue: float = fposmod(base_hsv["h"] + randf_range(-0.35, 0.35), 1.0)
		var sat: float = clamp(base_hsv["s"] + randf_range(-0.25, 0.35), 0.0, 1.0)
		var val: float = clamp(base_hsv["v"] + randf_range(-0.15, 0.1), 0.0, 1.0)
		light.light_color = Color.from_hsv(hue, sat, val)
		light.light_energy = 32.0
		light.light_specular = 0.0
		light.omni_range = sqrt(height * height + extent * extent) * 2.5
		light.omni_attenuation = 0.5
		light.position = Vector3(cx, height, cz)
		add_child(light)
		room_lights[r.id] = light
		room_light_base_energy[r.id] = light.light_energy
		room_light_colors[r.id] = light.light_color
		light.light_energy = 0.0
		light.visible = false

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
