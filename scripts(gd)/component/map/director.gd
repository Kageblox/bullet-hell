class_name Director
extends Node3D

var locator: Locator
var player: EntityRigidBodyComponent
var rooms: Dictionary = {}
var room_template: Dictionary = {"index": 0}
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
	if not rooms.has(room_id):
		var dup: Dictionary = room_template.duplicate()
		dup["index"] = room_id
		rooms[room_id] = dup
		var room: Gen.Room = layout.generator.rooms.get(room_id, null)
		if room != null:
			var aabb: AABB = layout.get_room_aabb(room_id)
			# Spawn enemy
			var drone: Node3D = SpawnManager.get_from_pool("enemy_drone")
			# Random position from room AABB
			drone.global_position: Vector3 = Vector3(
				randf_range(aabb.position.x, aabb.position.x + aabb.size.x),
				aabb.position.y,
				randf_range(aabb.position.z, aabb.position.z + aabb.size.z)
			)
			get_tree().add_child(drone)

func _room_leave(_last_room: int) -> void:
	pass

func _process(_delta: float) -> void:
	pass
