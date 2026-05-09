class_name AutomaticWeapon
extends WeaponInstance
## Weapon that fires automatically, as long as its held down.

#region Variables

@export var cooldown: float = 1 ## How often this weapon can fire.
var is_firing = false
var _cooldown_timer: float = 0

#endregion

#region Functions

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer = _cooldown_timer - delta
	else:
		if is_firing:
			fire()
			_cooldown_timer = cooldown

#endregion
