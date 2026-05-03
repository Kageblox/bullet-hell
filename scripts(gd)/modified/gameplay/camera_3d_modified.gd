class_name Camera3DModified
extends Camera3D
## Modified version of Camera3D, that incorporates simple harmonic motion


@export var focus_target: Node3D
@export var offset: Vector3 = Vector3(0, 8, 0)

@export var angular_frequency: float = 15
@export var damping_ratio: float = 1

var previous_position: Vector3

func _process(delta: float) -> void:
	var target_position = focus_target.position + offset
	
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
