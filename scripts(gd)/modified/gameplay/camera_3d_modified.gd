class_name ModifiedCamera3D
extends Camera3D
## Modified version of Camera3D, that incorporates simple harmonic motion

@export var angular_frequency: float = 15
@export var damping_ratio: float = 1
@export var speed: float = 10.0

var target_position: Vector3
var previous_position: Vector3
var offset: Vector3

func _enter_tree() -> void:
	position = Vector3(0,0,0)
	offset = Vector3(0.0, 0.0, position.z)

func _process(delta: float) -> void:
	var velocity = position - previous_position
	
	# var damped_spring_motion_params = HarmonicMotionUtility.CalcDampedSpringMotionParams(
	# 	delta * speed,
	# 	angular_frequency,
	# 	damping_ratio
	# )
	
	# var new_x_pos_and_vel = HarmonicMotionUtility.UpdateDampedSpringMotion(
	# 	position.x,
	# 	velocity.x,
	# 	target_position.x,
	# 	damped_spring_motion_params
	# )
	
	# var new_y_pos_and_vel = HarmonicMotionUtility.UpdateDampedSpringMotion(
	# 	position.y,
	# 	velocity.y,
	# 	target_position.y,
	# 	damped_spring_motion_params
	# )
	
	# var new_z_pos_and_vel = HarmonicMotionUtility.UpdateDampedSpringMotion(
	# 	position.z,
	# 	velocity.z,
	# 	target_position.z,
	# 	damped_spring_motion_params
	# )
	
	# position = Vector3(new_x_pos_and_vel.x, new_y_pos_and_vel.x, new_z_pos_and_vel.x)
	position = target_position
	previous_position = position
