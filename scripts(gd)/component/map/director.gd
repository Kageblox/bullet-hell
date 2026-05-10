class_name Director
extends Node3D

var locator: Locator

func _ready() -> void:
	locator = %Locator
	locator.connect("on_room_changed", _on_room_changed)

func _on_room_changed(room: int, last_room: int) -> void:
	_room_enter(room)
	_room_leave(last_room)

func _room_enter(room: int) -> void:
	pass

func _room_leave(last_room: int) -> void:
	pass

func _process(delta: float) -> void:
	pass
