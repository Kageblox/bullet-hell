class_name WeaponInstance
extends Node3D
## Instance Script that defines a single weapon.

#region Signals

signal on_fired()

#endregion

#region Variables

@export_group("Basic")
@export var damage: float = 1

## The weapon this component is attached to.
var entity: EntityInstance

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance) as EntityInstance

func fire() -> void:
	on_fired.emit()

#endregion
