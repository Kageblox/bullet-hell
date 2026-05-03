class_name Camera3DModified
extends Camera3D
## Modified version of Camera3D, that incorporates simple harmonic motion

@export var angular_frequency: float = 15
@export var damping_ratio: float = 1

var target_position: Vector3
var previous_position: Vector3

func _process(delta: float) -> void:
	var velocity = position - previous_position
	
	var damped_spring_motion_params = HarmonicMotionUtility.CalcDampedSpringMotionParams(
		delta,
		angular_frequency,
		damping_ratio
	)
	
	var new_x_pos_and_vel = HarmonicMotionUtility.UpdateDampedSpringMotion(
		position.x,
		velocity.x,
		target_position.x,
		damped_spring_motion_params
	)
	
	var new_y_pos_and_vel = HarmonicMotionUtility.UpdateDampedSpringMotion(
		position.y,
		velocity.y,
		target_position.y,
		damped_spring_motion_params
	)
	
	var new_z_pos_and_vel = HarmonicMotionUtility.UpdateDampedSpringMotion(
		position.z,
		velocity.z,
		target_position.z,
		damped_spring_motion_params
	)
	
	position = Vector3(new_x_pos_and_vel.x, new_y_pos_and_vel.x, new_z_pos_and_vel.x)
	
	previous_position = position
