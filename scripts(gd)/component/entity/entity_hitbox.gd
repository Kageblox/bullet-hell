class_name EntityHitboxComponent
extends Area3D
## Component Script that gives an Entity a hitbox.

#region Variables

## The entity this component is attached to.
var entity: EntityInstance

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)
	
#endregion
