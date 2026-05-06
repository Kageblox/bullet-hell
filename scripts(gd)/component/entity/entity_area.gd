class_name EntityAreaComponent
extends Area3D
## Component that adds an area around the Entity.

#region Variables

## The entity this component is attached to.
var entity: EntityInstance

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)

#endregion
