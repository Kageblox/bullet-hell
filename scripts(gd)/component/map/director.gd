class_name Director
extends Node3D

const DOOR_CLEARANCE: float = 2.0
const SPAWN_WALL_INSET: float = 2.0
const SPAWN_MIN_PLAYER_DIST: float = 4.0
const SPAWN_PLACEMENT_ATTEMPTS: int = 16
const ENEMY_POOLS: Array[String] = ["enemy_drone", "enemy_laser_mouse"]

var locator: Locator
var player: EntityRigidBodyComponent
var rooms: Dictionary = {}
var pending: Dictionary = {}
var room_template: Dictionary = {"index": 0, "alive": 0}
var layout: MapLayout

var spawn_room: Gen.Room
var spawn_pos: Vector3
var boss_room: Gen.Room

func _enter_tree() -> void:
	GameManager.director = self

func _ready() -> void:
	layout = GameManager.map
	locator = GameManager.locater
	player = GameManager.player.get_node("PlayerBody")
	locator.on_room_changed.connect(_on_room_changed)

	# Position player on spawn
	spawn_room = layout.generator.rooms.get(layout.generator.StartRoom, null)
	boss_room = layout.generator.rooms.get(layout.generator.EndRoom, null)

	if spawn_room == null:
		printerr("No spawn room")
		return
	if boss_room == null:
		printerr("No boss room")
		return

	var aabb: AABB = layout.get_room_aabb(spawn_room.id)
	spawn_pos = aabb.position + aabb.size * 0.5
	spawn_pos.y = player.global_position.y
	locator.spawn_pos = spawn_pos
	player.global_position = spawn_pos

func _on_room_changed(room_id: int, last_room_id: int) -> void:
	if pending.has(last_room_id):
		pending.erase(last_room_id)
	if last_room_id == 0:
		if not rooms.has(room_id) and layout.generator.mainRooms.has(room_id):
			var dup: Dictionary = room_template.duplicate()
			dup["index"] = room_id
			dup["alive"] = 0
			rooms[room_id] = dup
		return
	_room_enter(room_id)

func _room_enter(room_id: int) -> void:
	if rooms.has(room_id) or pending.has(room_id):
		return
	if not layout.generator.mainRooms.has(room_id):
		return
	var room: Gen.Room = layout.generator.rooms.get(room_id, null)
	if room == null:
		return
	if _room_contains_subroom(room):
		return
	pending[room_id] = true

func _room_contains_subroom(main: Gen.Room) -> bool:
	for sub in layout.generator.subrooms.values():
		if sub.x < main.x + main.w and sub.x + sub.w > main.x \
				and sub.y < main.y + main.h and sub.y + sub.h > main.y:
			return true
	return false

func _process(_delta: float) -> void:
	var current_id: int = _player_room()
	# if current_id > 0 and layout.generator.mainRooms.has(current_id):
	# 	pass
		# var _s = DebugDraw3D.new_scoped_config().set_no_depth_test(true)
		# DebugDraw3D.draw_aabb(layout.get_room_aabb(current_id), Color.AQUA)
	if pending.is_empty():
		return
	var ids: Array = pending.keys()
	for room_id in ids:
		if _player_room() != room_id:
			continue
		if _player_past_doors(room_id):
			pending.erase(room_id)
			_commit_room(room_id)

func _player_past_doors(room_id: int) -> bool:
	var doors: Array = layout.get_room_doors(room_id)
	if doors.is_empty():
		return true
	var p: Vector3 = player.global_position
	for d in doors:
		if d is MapDoor:
			var md: MapDoor = d as MapDoor
			var dx: float = md.global_position.x - p.x
			var dz: float = md.global_position.z - p.z
			if sqrt(dx * dx + dz * dz) < DOOR_CLEARANCE:
				return false
	return true

func _commit_room(room_id: int) -> void:
	if rooms.has(room_id):
		return
	var room: Gen.Room = layout.generator.rooms.get(room_id, null)
	if room == null:
		return
	var aabb: AABB = layout.get_room_aabb(room_id)
	var dup: Dictionary = room_template.duplicate()
	dup["index"] = room_id
	dup["alive"] = 0
	rooms[room_id] = dup

	@warning_ignore("integer_division")
	var spawn_count: int = max(2, min(rooms.size(), 8))
	_set_room_locked(room_id, true)
	for k in range(spawn_count):
		var pool_name: String = ENEMY_POOLS[randi() % ENEMY_POOLS.size()]
		var drone: Node3D = SpawnManager.get_from_pool(pool_name)
		if drone == null:
			printerr("No enemy in pool: ", pool_name)
			break
		drone.global_position = _pick_spawn_position(aabb, room_id)
		_sync_after_spawn(drone)
		dup["alive"] += 1
		if drone is EntityInstance:
			(drone as EntityInstance).on_death.connect(_on_enemy_died.bind(room_id), CONNECT_ONE_SHOT)

	if dup["alive"] == 0:
		_set_room_locked(room_id, false)

	# Test layout random_position_in_room
	# for n in range(20):
	# 	var test_pos: Vector3 = layout.random_position_in_room(room_id)
	# 	DebugDraw3D.draw_sphere(test_pos, 0.2, Color.LIME_GREEN, 10.0)

func _player_room() -> int:
	return layout.room_index_at(player.global_position)

func _sync_after_spawn(drone: Node3D) -> void:
	var rb = drone.get("rigid_body_component")
	if rb is RigidBody3D:
		rb.global_position = drone.global_position
		rb.linear_velocity = Vector3.ZERO
		rb.angular_velocity = Vector3.ZERO
		if "target_velocity" in rb:
			rb.target_velocity = Vector3.ZERO
	var pf = drone.get("pathfinder_component")
	if pf is NavigationAgent3D:
		pf.target_position = drone.global_position
	

func _is_walkable_floor(ch: String) -> bool:
	return ch == "." or ch == "c" or ch == "C" or ch == "v" or ch == "h"


func _pick_spawn_position(aabb: AABB, room_id: int) -> Vector3:
	var min_x: float = aabb.position.x
	var max_x: float = aabb.position.x + aabb.size.x
	var min_z: float = aabb.position.z
	var max_z: float = aabb.position.z + aabb.size.z
	for attempt in range(SPAWN_PLACEMENT_ATTEMPTS):
		var p: Vector3 = Vector3(randf_range(min_x, max_x), aabb.position.y, randf_range(min_z, max_z))
		if layout.room_index_at(p) == room_id:
			return p
	return aabb.position + aabb.size * 0.5

func _tile_is_safe_to_spawn(i: int, j: int, room_id: int) -> bool:
	if layout.generator.RoomIndexAt(i, j) != room_id:
		return false
	for dj in range(-1, 2):
		for di in range(-1, 2):
			if not _is_walkable_floor(layout.generator.At(i + di, j + dj)):
				return false
	return true

func _on_enemy_died(room_id: int) -> void:
	if not rooms.has(room_id):
		return
	var data: Dictionary = rooms[room_id]
	data["alive"] = max(0, data["alive"] - 1)
	if data["alive"] == 0:
		_set_room_locked(room_id, false)

func _set_room_locked(room_id: int, locked: bool) -> void:
	if locked:
		_clamp_player_into_room(room_id)
	for d in layout.get_room_doors(room_id):
		if d is MapDoor:
			(d as MapDoor).set_locked(locked)

func _clamp_player_into_room(room_id: int) -> void:
	var aabb: AABB = layout.get_room_aabb(room_id)
	if aabb.size.x <= 0.0 or aabb.size.z <= 0.0:
		return
	var p: Vector3 = player.global_position
	var inside: bool = layout.room_index_at(p) == room_id
	if inside:
		return
	p.x = clamp(p.x, aabb.position.x, aabb.position.x + aabb.size.x)
	p.z = clamp(p.z, aabb.position.z, aabb.position.z + aabb.size.z)
	player.global_position = p
	player.linear_velocity = Vector3.ZERO
