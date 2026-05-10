class_name MapDoor
extends Node3D
## Double-door whose two halves swing open away from an approaching player.

@export var open_radius: float = 2.5
@export var close_radius: float = 4.0
@export var open_angle: float = PI * 0.5
@export var swing_speed: float = 4.0

var left_hinge: Node3D
var right_hinge: Node3D
var is_open: bool = false
var swing_dir: float = 0.0

func _process(delta: float) -> void:
	if left_hinge == null or right_hinge == null:
		return
	var player_pos: Vector3 = _get_player_position()
	if player_pos == Vector3.INF:
		return
	var dist: float = global_position.distance_to(player_pos)
	if not is_open and dist < open_radius:
		is_open = true
		var local_p: Vector3 = to_local(player_pos)
		swing_dir = signf(local_p.z)
		if swing_dir == 0.0:
			swing_dir = 1.0
		AudioManager.play_sfx("open_door")
	elif is_open and dist > close_radius:
		is_open = false
	var target_left: float = open_angle * swing_dir if is_open else 0.0
	var target_right: float = -open_angle * swing_dir if is_open else 0.0
	var step: float = swing_speed * delta
	left_hinge.rotation.y = move_toward(left_hinge.rotation.y, target_left, step)
	right_hinge.rotation.y = move_toward(right_hinge.rotation.y, target_right, step)
	if not is_open and is_equal_approx(left_hinge.rotation.y, 0.0) and is_equal_approx(right_hinge.rotation.y, 0.0):
		swing_dir = 0.0

func _get_player_position() -> Vector3:
	var player = GameManager.player
	if player == null:
		return Vector3.INF
	if "rigid_body_component" in player and player.rigid_body_component != null:
		return player.rigid_body_component.global_position
	return player.global_position
