class_name Director
extends Node3D

var locator: Locator
var player: Player
var rooms: Dictionary = {}
var room_template: Dictionary = {"index": -1}

func _ready() -> void:
	locator = %Locator
	player = %Player.get_node("PlayerBody")
	locator.connect("on_room_changed", _on_room_changed)

func _on_room_changed(room: int, last_room: int) -> void:
	_room_enter(room)
	_room_leave(last_room)

func _room_enter(room: int) -> void:
	var dup: Dictionary = room_template.duplicate()
	dup.index = room
	rooms.append(room, dup)

func _room_leave(last_room: int) -> void:
	pass

func _process(delta: float) -> void:
	pass
