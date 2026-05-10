class_name NewCamera
extends Camera3D

@export var pan_max: float = 4.0
@export var pan_smooth_speed: float = 6.0

var offset: Vector3
var target_position: Vector3
var previous_position: Vector3
var target: Node3D
var pan_offset: Vector3 = Vector3.ZERO

func _enter_tree() -> void:
	offset = position
	target = %Player.get_node("PlayerBody")

func _process(delta: float) -> void:
	previous_position = position
	var base_pos: Vector3 = offset + target.position
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var mouse: Vector2 = get_viewport().get_mouse_position()
	var norm: Vector2 = ((mouse / viewport_size) - Vector2(0.5, 0.5)) * 2.0
	norm.x = clamp(norm.x, -1.0, 1.0)
	norm.y = clamp(norm.y, -1.0, 1.0)
	var target_pan: Vector3 = Vector3(norm.x, 0.0, norm.y) * pan_max
	var t: float = clamp(pan_smooth_speed * delta, 0.0, 1.0)
	pan_offset = pan_offset.lerp(target_pan, t)
	position = base_pos + pan_offset
