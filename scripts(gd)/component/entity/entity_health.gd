class_name EntityHealthComponent
extends Area3D
## Component Script that gives an Entity Health.

#region Signals

signal on_health_changed(value: float)
signal on_death()

#endregion

#region Variables

var _health: float = 100

## The health value of this entity.
@export_range(0, 1000) var health: float:
	get:
		return _health
	set(value):
		_health = value
		on_health_changed.emit(value)
		if value == 0:
			on_death.emit()
			die()

@export_range(0, 1000) var max_health: float = 100

## The entity this component is attached to.
var entity: EntityInstance

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)

## Called when the Entity reaches 0 HP
func die() -> void:
	pass

#endregion
