class_name Locator
extends Node3D

@export var actor: Node3D = null

var layout: MapLayout
var generator: Gen.LayoutGenerator
var room_id: int = 0
var room: Gen.Room
var _debug_label: Label

signal on_room_changed(room_id: int, last_room_id: int)


func _ready() -> void:
	self.actor = %Player.get_node("PlayerBody")
	self.layout = %Map
	self.generator = self.layout.generator

	var canvas := CanvasLayer.new()
	canvas.name = "LocatorDebug"
	add_child(canvas)
	_debug_label = Label.new()
	_debug_label.position = Vector2(8, 8)
	_debug_label.add_theme_color_override("font_color", Color.WHITE)
	_debug_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_debug_label.add_theme_constant_override("outline_size", 4)
	_debug_label.add_theme_font_size_override("font_size", 32)
	canvas.add_child(_debug_label)
	_update_debug_label()

func _physics_process(_delta) -> void:
	if self.actor == null:
		printerr("Actor not set")
		return
	if self.generator == null:
		return
	var new_room: Gen.Room = self.current_room()
	if new_room == null or new_room.id <= 0:
		return
	var last_room_id: int = 0
	if self.room != null:
		last_room_id = self.room.id
	if new_room.id == last_room_id:
		return
	self.room = new_room
	self.room_id = new_room.id
	on_room_changed.emit(new_room.id, last_room_id)
	_update_debug_label()

func _update_debug_label() -> void:
	if _debug_label == null:
		return
	_debug_label.text = "Room: %d" % self.room_id

func current_room() -> Gen.Room:
	return layout.room_at(self.global_position)
