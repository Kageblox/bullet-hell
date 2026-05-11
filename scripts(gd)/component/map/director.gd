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
	layout = GameManager.map
	locator = GameManager.locater
	player = GameManager.player.get_node("PlayerBody")
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
		#_reset_after_spawn(drone)
		# print("  drone[", k, "] pos=", drone.global_position, " tile='", layout.tile_at(drone.global_position), "' room=", layout.room_index_at(drone.global_position), " visible=", drone.visible)
		dup["alive"] += 1
		if drone is EntityInstance:
			(drone as EntityInstance).on_death.connect(_on_enemy_died.bind(room_id), CONNECT_ONE_SHOT)

	if dup["alive"] > 0:
		_set_room_locked(room_id, true)

func _player_room() -> int:
	return layout.room_index_at(player.global_position)
	

func _is_walkable_floor(ch: String) -> bool:
	return ch == "." or ch == "c" or ch == "C" or ch == "v" or ch == "h"


func _pick_spawn_position(aabb: AABB, room_id: int) -> Vector3:
	var room: Gen.Room = layout.generator.rooms.get(room_id, null)
	if room == null:
		return aabb.position + aabb.size * 0.5
	var inset: int = 2
	while inset > 0 and (room.w - inset * 2 < 1 or room.h - inset * 2 < 1):
		inset -= 1
	var i_min: int = room.x + inset
	var i_max: int = room.x + room.w - 1 - inset
	var j_min: int = room.y + inset
	var j_max: int = room.y + room.h - 1 - inset
	var offset_x: float = -layout.generator.MapWidth * layout.tile_size * 0.5
	var offset_z: float = -layout.generator.MapHeight * layout.tile_size * 0.5
	for attempt in range(SPAWN_PLACEMENT_ATTEMPTS):
		var i: int = randi_range(i_min, i_max)
		var j: int = randi_range(j_min, j_max)
		if _tile_is_safe_to_spawn(i, j, room_id):
			return Vector3(offset_x + i * layout.tile_size, 0.0, offset_z + j * layout.tile_size)
	for j in range(j_min, j_max + 1):
		for i in range(i_min, i_max + 1):
			if _tile_is_safe_to_spawn(i, j, room_id):
				return Vector3(offset_x + i * layout.tile_size, 0.0, offset_z + j * layout.tile_size)
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
	for d in layout.get_room_doors(room_id):
		if d is MapDoor:
			(d as MapDoor).set_locked(locked)
