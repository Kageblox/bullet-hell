class_name EntityInstance
extends Node3D
## Instance Script that controls a single entity.

#region Signals

signal on_damaged(value: float) ## Emitted when the Entity takes damage.
signal on_healed(value: float) ## Emitted when the Entity is healed.
signal on_health_changed(value: float) ## Emitted whenever the Entity's HP changes
signal on_death() ## Emitted when the Entity dies.

#endregion

#region Variables

@export_group("Stats")
var _health: float = 100
@export var health: float:
	get:
		return _health
	set(value):
		if not invulnurable:
			_health = clamp(value, 0, max_health)
			on_health_changed.emit(value)
		
@export var max_health: float = 100
@export var invulnurable: bool = false

#endregion

#region Functions

func damage(value: float) -> void:
	health = clamp(health - value, 0, max_health)
	
	if health == 0:
		die()
	else:
		on_damaged.emit(value)

func heal(value: float) -> void:
	health = clamp(health + value, 0, max_health)
	on_healed.emit(value)

func die() -> void:
	on_death.emit()

#endregion
