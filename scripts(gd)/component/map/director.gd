class_name Director
extends Node3D

const DOOR_CLEARANCE: float = 2.0
const SPAWN_WALL_INSET: float = 2.0
const SPAWN_MIN_PLAYER_DIST: float = 4.0
const SPAWN_PLACEMENT_ATTEMPTS: int = 16

var locator: Locator
var player: EntityRigidBodyComponent
var rooms: Dictionary = {}
var pending: Dictionary = {}
var room_template: Dictionary = {"index": 0, "alive": 0}
var layout: MapLayout

func _ready() -> void:
	layout = %Map
	locator = %Locator
	player = %Player.get_node("PlayerBody")
	locator.on_room_changed.connect(_on_room_changed)

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
	var spawn_count: int = max(1, rooms.size() / 2)
	# print("commit room=", room_id, " spawn=", spawn_count, " rooms=", rooms.size())
	for k in range(spawn_count):
		var drone: Node3D = SpawnManager.get_from_pool("enemy_drone")
		if drone == null:
			printerr("No enemy in pool")
			break
		drone.global_position = _pick_spawn_position(aabb, room_id)
		# print("  drone[", k, "] pos=", drone.global_position, " tile='", layout.tile_at(drone.global_position), "' room=", layout.room_index_at(drone.global_position), " visible=", drone.visible)
		dup["alive"] += 1
		if drone is EntityInstance:
			(drone as EntityInstance).on_death.connect(_on_enemy_died.bind(room_id), CONNECT_ONE_SHOT)

	if dup["alive"] > 0:
		_set_room_locked(room_id, true)

func _player_room() -> int:
	return layout.room_index_at(player.global_position)

func _is_walkable_floor(ch: String) -> bool:
	return ch != "" and ch != " " and ch != "V" and ch != "H" and ch != "#" and ch != "P"

func _pick_spawn_position(aabb: AABB, room_id: int) -> Vector3:
	var min_x: float = aabb.position.x + SPAWN_WALL_INSET
	var max_x: float = aabb.position.x + aabb.size.x - SPAWN_WALL_INSET
	var min_z: float = aabb.position.z + SPAWN_WALL_INSET
	var max_z: float = aabb.position.z + aabb.size.z - SPAWN_WALL_INSET
	if min_x >= max_x or min_z >= max_z:
		return aabb.position + aabb.size * 0.5
	var min_dist_sq: float = SPAWN_MIN_PLAYER_DIST * SPAWN_MIN_PLAYER_DIST
	var player_pos: Vector3 = player.global_position
	var p: Vector3 = Vector3.ZERO
	var fallback: Vector3 = Vector3.ZERO
	var have_fallback: bool = false
	for attempt in range(SPAWN_PLACEMENT_ATTEMPTS):
		p = Vector3(randf_range(min_x, max_x), aabb.position.y, randf_range(min_z, max_z))
		if layout.room_index_at(p) != room_id:
			continue
		if not _is_walkable_floor(layout.tile_at(p)):
			continue
		if not have_fallback:
			fallback = p
			have_fallback = true
		var dx: float = p.x - player_pos.x
		var dz: float = p.z - player_pos.z
		if dx * dx + dz * dz >= min_dist_sq:
			return p
	if have_fallback:
		return fallback
	return aabb.position + aabb.size * 0.5

func _on_enemy_died(room_id: int) -> void:
	if not rooms.has(room_id):
		return
	var data: Dictionary = rooms[room_id]
	data["alive"] = max(0, data["alive"] - 1)
	if data["alive"] == 0:
		_set_room_locked(room_id, false)

func _set_room_locked(room_id: int, locked: bool) -> void:
	for d in layout.get_room_doors(room_id):
		if d is MapDoor:
			(d as MapDoor).set_locked(locked)
