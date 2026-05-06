class_name Locator
extends Node3D

@export var actor: Node3D = null

var layout: MapLayout
var generator: Gen.LayoutGenerator
var room_id: int = 0
var room: Gen.Room
var _debug_label: Label

signal on_room_changed(room: Gen.Room, last_room: Gen.Room)


func _ready() -> void:
	self.actor = get_parent()
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
	if self.actor != null:
		if self.generator == null:
			return
		self.room = self.current_room()
		if self.room != null:
			var last_room: Gen.Room = self.room
			if self.room.id > 0:
				if room.id != self.room_id:
					self.room = room
					self.room_id = room.id
					_update_debug_label()
				on_room_changed.emit(self.room, last_room)

func _update_debug_label() -> void:
	if _debug_label == null:
		return
	_debug_label.text = "Room: %d" % self.room_id

func current_room() -> Gen.Room:
	return layout.room_at(self.global_position)
