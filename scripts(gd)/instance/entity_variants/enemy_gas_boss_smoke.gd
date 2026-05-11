class_name EnemyGasBossSmoke
extends EntityInstance

#region Variables

@export_group("Other Components")
@export var chargable_area_weapon: ChargableAreaWeapon

@export_group("Variables")
@export var damage: float = 10.0

#endregion

#region Functions

func _ready() -> void:
	chargable_area_weapon.on_fired.connect(
		func():
			set_unused()
			)


func set_used() -> void:
	super()
	chargable_area_weapon.begin_charging()
	sprite.stop()
	sprite.animation_override = "charging"
	sprite.play("charging")
	
#endregion
