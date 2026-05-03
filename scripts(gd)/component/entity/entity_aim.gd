class_name EntityAimComponent
extends Node3D
## Component Script in charge of Entity aiming.

## Minimum velocity for Velocity Aim State.
const min_velocity: float = 1

enum AimState { POSITION, VELOCITY, DISABLED }

var aim_position: Vector3 ## Where the Entity is currently aiming at.

## The entity this component is attached to.
var entity: EntityInstance

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)
	entity.aim = self

func _process(delta: float) -> void:
	match(entity.aim_state):
		AimState.POSITION:
			look_at(Vector3(aim_position.x, global_position.y, aim_position.z))
		AimState.VELOCITY:
			if entity.body.linear_velocity.length() > min_velocity:
				var global_velocity = entity.body.linear_velocity + global_position
				look_at(Vector3(global_velocity.x, global_position.y, global_velocity.z))
		AimState.DISABLED:
			pass
		
