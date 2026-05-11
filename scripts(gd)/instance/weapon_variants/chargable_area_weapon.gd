class_name ChargableAreaWeapon
extends ChargableWeapon
## Weapon that damages entities in an area, once charged.

@export_group("Other Components")
@export var area_component: WeaponAreaComponent
@export var indicator_component: ChargableWeaponIndicatorComponent

func fire() -> void:

	var sfx_played = false
	for hit_entity in area_component.get_entities_in_area():
		hit_entity.damage_entity(damage, hit_entity.global_position - global_position)
		if not sfx_played:
			sfx_played = true
			AudioManager.play_sfx("melee")
	
	super()
