class_name EntitySpawnerComponent
extends Node3D
## Component Script that gives an Entity Entity-Spawining Capabilities.

#region Variables

## The entity this component is attached to.
var entity: EntityInstance

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)

func spawn_singular(pool_name: String) -> EntityInstance:
	var spawned = SpawnManager.get_unused_instances(pool_name)[0]
	spawned.global_position = global_position
	spawned.global_rotation = global_rotation
	
	return spawned
	
#endregion
