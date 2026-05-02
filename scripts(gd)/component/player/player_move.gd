class_name PlayerMove
extends RigidBody3D
## Component script that controls player movement.

@export_group("Basic")
@export_range(0.001, 1) var accelaration: float = 0.25

@export_group("Advanced")
@export var accel_curve: Curve
@export var mass_multi = 1000

var player: PlayerInstance

func _enter_tree() -> void:
	player = GeneralUtility.get_nearest_parent_of_class(self, PlayerInstance)
	
func _physics_process(delta: float) -> void:
	var move_input = InputManager.move_input
	var move_speed = player.move_speed
	
	# Determine the target velocity based on the movement input and movement speed.
	var target_velocity = Vector3(move_input.x * move_speed, 0.0, -move_input.y * move_speed)
	
	# Determine the acceleration to use based on the difference between the target and current velocity.
	var direction_difference = linear_velocity.normalized().dot(target_velocity.normalized())
	var true_acceleration = accel_curve.sample(direction_difference) * accelaration * move_speed
	
	# Determine the final, goal velocity by moving from the current to the target velocity, based on the acceleration.
	var goal_velocity = linear_velocity.move_toward(target_velocity, true_acceleration * move_speed)
	
	# Finally, apply the velocity to the rigidbody
	apply_central_force(
		(
			(goal_velocity - linear_velocity) 
			* delta 
			* mass * mass_multi
		)
	)
