class_name WeaponInstance
extends Node3D
## Instance Script that defines a single weapon.

signal on_fired()

@export_group("Basic")
@export var fire_cooldown: float = 1 ## How often the weapon fires.

var is_firing: bool = false ## Whether the weapon is currently being fired.
var _cooldown_timer: float = 0

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer = _cooldown_timer - delta
	else:
		if is_firing:
			on_fired.emit()
			_cooldown_timer = fire_cooldown
