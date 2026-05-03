class_name EntityBodyComponent
extends RigidBody3D
## Component Script in charge of moving Entities.

#region Variables

## A constant force multiplier.
const force_multi = 1000

## Curve that determines the acceleration of the Entity, based on the difference between the current and target velocity direction.
var accel_curve: Curve = preload("res://resource(tres)/curves/entity_body_accel_curve.tres") as Curve

## The direction and speed this Entity should be moving at.
var target_velocity: Vector3

## The entity this component is attached to.
var entity: EntityInstance

#endregion

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)
	entity.body = self
	
	gravity_scale = 0
	
	axis_lock_linear_x = false
	axis_lock_linear_y = true
	axis_lock_linear_z = false
	
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true


func _physics_process(delta: float) -> void:
	
	# Determine the acceleration to use based on the difference between the target and current velocity.
	var direction_difference = linear_velocity.normalized().dot(target_velocity.normalized())
	var true_acceleration = accel_curve.sample(direction_difference) * entity.move_accel * entity.move_speed
	
	# Determine the final, goal velocity by moving from the current to the target velocity, based on the acceleration.
	var goal_velocity = linear_velocity.move_toward(target_velocity, true_acceleration)
	
	# Finally, apply the velocity to the rigidbody
	apply_central_force(
		(
			(goal_velocity - linear_velocity) 
			* delta 
			* mass 
			* force_multi
		)
	)
