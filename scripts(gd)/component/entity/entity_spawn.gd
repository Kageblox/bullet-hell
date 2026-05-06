class_name EntitySpawnComponent
extends Node
## Component Script that integrates the Entity with the Spawning system.

signal on_set_used()
signal on_set_unused()

#region Variables

@export var pool_name: String ## The name of the pool this Entity belongs to

## The entity this component is attached to.
var entity: EntityInstance

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)
	
func set_used() -> void:
	on_set_used.emit()
	
	#entity.visible = true
	entity.set_deferred("process_mode", Node.PROCESS_MODE_PAUSABLE)

func set_unused() -> void:
	on_set_unused.emit()
	
	if entity == null:
		entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)
	
	#entity.visible = false
	entity.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	
	if pool_name != "":
		var unused_pool = SpawnManager.get_node(pool_name + "/unused")
		entity.call_deferred("reparent", unused_pool)

#endregion
