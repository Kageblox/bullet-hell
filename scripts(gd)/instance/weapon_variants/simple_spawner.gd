class_name SimpleSpawnerWeapon
extends WeaponInstance

#region Variables

@export_group("Other Components")

## The weapon this component is attached to.
var entity: EntityInstance

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance) as EntityInstance		

#endregion
