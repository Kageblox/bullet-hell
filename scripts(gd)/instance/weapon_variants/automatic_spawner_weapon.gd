class_name AutomaticSpawnerWeapon
extends AutomaticWeapon
## Weapon that automatically spawns entities.

@export_group("Other Components")
@export var spawner_component: WeaponSpawnerComponent

@export_group("Basic")
@export var projectile_pool_name: String
@export var projectile_speed: float = 1
@export var projectile_lifetime: float = 1

func fire() -> void:
	super()
	
	var random_sound = randi() % 5 # Range 0 - 4
	match random_sound:
		0:
			AudioManager.play_sfx("lazer_shot_1")
		1:
			AudioManager.play_sfx("lazer_shot_2")
		2:
			AudioManager.play_sfx("lazer_shot_3")
		3:
			AudioManager.play_sfx("lazer_shot_4")
		4:
			AudioManager.play_sfx("lazer_shot_5")
		_:
			AudioManager.play_sfx("lazer_shot_1")
	
	var spawned = spawner_component.spawn_entity(projectile_pool_name)
	
	if spawned is ProjectileEntity:
		spawned.damage = damage
		spawned.speed = projectile_speed
		spawned.lifetime = projectile_lifetime
