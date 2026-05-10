class_name Director
extends Node3D

var locator: Locator
var player: EntityRigidBodyComponent
var rooms: Dictionary = {}
var room_template: Dictionary = {"index": 0, "alive": 0}
var layout: MapLayout

func _ready() -> void:
	layout = %Map
	locator = %Locator
	player = %Player.get_node("PlayerBody")
	locator.on_room_changed.connect(_on_room_changed)

func _on_room_changed(room_id: int, last_room_id: int) -> void:
	_room_enter(room_id)
	_room_leave(last_room_id)

func _room_enter(room_id: int) -> void:
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

	var spawn_count: int = 1
	for k in range(spawn_count):
		var drone: Node3D = SpawnManager.get_from_pool("enemy_drone")
		if drone == null:
			continue
		drone.global_position = Vector3(
			randf_range(aabb.position.x, aabb.position.x + aabb.size.x),
			aabb.position.y,
			randf_range(aabb.position.z, aabb.position.z + aabb.size.z)
		)
		dup["alive"] += 1
		if drone is EntityInstance:
			(drone as EntityInstance).on_death.connect(_on_enemy_died.bind(room_id), CONNECT_ONE_SHOT)

	if dup["alive"] > 0:
		_set_room_locked(room_id, true)

func _room_leave(_last_room: int) -> void:
	pass

func _on_enemy_died(room_id: int) -> void:
	if not rooms.has(room_id):
		return
	var data: Dictionary = rooms[room_id]
	data["alive"] = max(0, data["alive"] - 1)
	if data["alive"] == 0:
		_set_room_locked(room_id, false)

func _set_room_locked(room_id: int, locked: bool) -> void:
	for door in layout.get_room_doors(room_id):
		if door != null and door is MapDoor:
			(door as MapDoor).set_locked(locked)

func _process(_delta: float) -> void:
	pass
