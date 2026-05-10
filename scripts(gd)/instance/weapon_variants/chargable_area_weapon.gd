class_name ChargableAreaWeapon
extends ChargableWeapon
## Weapon that damages entities in an area, once charged.

@export_group("Other Components")
@export var area_component: WeaponAreaComponent
@export var indicator_component: ChargableWeaponIndicatorComponent

func fire() -> void:
	super()
	
	AudioManager.play_sfx("melee")
	for hit_entity in area_component.get_entities_in_area():
		hit_entity.damage_entity(damage, hit_entity.global_position - entity.hitbox_component.global_position)
