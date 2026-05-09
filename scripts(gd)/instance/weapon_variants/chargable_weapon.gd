class_name ChargableWeapon
extends WeaponInstance
## Weapon that can be charged before firing.

#region Signals

signal on_charge_start()
signal while_charging(current_charge: float)
signal on_charge_end()

#endregion

#region Variables

@export var charge_duration: float = 1 ## How long this weapon takes to charge.
var charge: float = 0  ## The charge of this weapon. Fires when it reaches 1.
var is_charging: bool = false ## Whether the weapon is currently charging.

#endregion

#region Functions

func _process(delta: float) -> void:
	if is_charging:
		if charge < 1:
			charge = charge + (delta / charge_duration)
			while_charging.emit(charge)
		else:
			charge = 0
			is_charging = false
			on_charge_end.emit()
			fire()


func begin_charging() -> void:
	charge = 0
	is_charging = true
	on_charge_start.emit()

#endregion
