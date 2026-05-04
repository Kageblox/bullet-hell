class_name EntityAimComponent
extends Node3D
## Component Script that allows for an Entity to Aim.

#region Variables

## Minimum velocity for Velocity Aim State.
const min_velocity: float = 1

enum AimState { POSITION, VELOCITY, DISABLED }

@export var current_aim_state: AimState = AimState.POSITION

## Where the Entity is currently aiming at.
@export var aim_position: Vector3 = Vector3.ZERO

## The entity this component is attached to.
var entity: EntityInstance

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)

func _process(delta: float) -> void:
	match(current_aim_state):
		AimState.POSITION: 
			if aim_position != global_position:
				look_at(Vector3(aim_position.x, global_position.y, aim_position.z))
		AimState.VELOCITY:
			if entity.rigid_body_component != null:
				if entity.rigid_body_component.linear_velocity.length() > min_velocity:
					var global_velocity = entity.rigid_body_component.linear_velocity + global_position
					if global_velocity != global_position:
						look_at(Vector3(global_velocity.x, global_position.y, global_velocity.z))
		AimState.DISABLED:
			pass

#endregion
