class_name EntityAimComponent
extends Node3D
## Component Script that allows for an Entity to Aim.

#region Variables

const min_velocity: float = 1 ## Minimum velocity for Velocity Aim State.

enum AimState { 
	POSITION, # The Entity aims towards the aim_position.
	VELOCITY, # The Entity looks towards the velocity of its EntityRigidBodyComponent
	INACTIVE, # The Entity does not aim towards anything.
	}

@export var turn_speed: float = 15 ## How fast the Entity turns to aim.

var current_aim_state: AimState = AimState.POSITION ## The current Aim State of the Entity
var aim_position: Vector3 = Vector3.ZERO ## Where the Entity is currently aiming at.
var _target_angle: float ## The target angle this Aim Component turns to face.

var entity: EntityInstance ## The entity this component is attached to.

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)


func _process(delta: float) -> void:
	# First, get the direction the Aim Component is currently facing.
	var forward_vector = -global_basis.z
	
	match(current_aim_state):
		AimState.POSITION: # The Entity aims towards the aim_position.
			# Next, calculate the target angle, namely the angle needed to face the aim_position from the forward_vector.
			_target_angle = forward_vector.signed_angle_to(aim_position - global_position, Vector3.UP)
			
		AimState.VELOCITY: # The Entity looks towards the velocity of its EntityRigidBodyComponent
			
			# Only if the Entity has a Rigid Body Component,
			if entity.rigid_body_component != null:
				# And the Rigid Body Component's moving at a certain speed,
				if entity.rigid_body_component.linear_velocity.length() > min_velocity:
					# Then calculate the target angle, the angle needed to face the Rigid Body Component's velocity.
					_target_angle = forward_vector.signed_angle_to(entity.rigid_body_component.linear_velocity, Vector3.UP)
		
		AimState.INACTIVE: # The Entity does not aim towards anything.
			_target_angle = 0
			pass

	# Calculate the allowed turn for this frame,
	var turn_speed_delta = turn_speed * delta
	
	# Rotate the Aim Component to face the target angle, clamped by the allowed turn for this frame.
	global_rotate(Vector3.UP, clamp(_target_angle, -turn_speed_delta, turn_speed_delta))
	
#endregion
