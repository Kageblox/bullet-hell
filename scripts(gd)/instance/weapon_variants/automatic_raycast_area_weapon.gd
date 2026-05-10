class_name AutomaticRaycastAreaWeapon
extends AutomaticWeapon
## Weapon that constantly damages entities hit by a raycast.

@export_group("Other Components")
@export var area_component: WeaponAreaComponent
@export var raycast_component: WeaponRaycastComponent
@export var sprite_component: WeaponSpriteComponent
@export var ray_node: Node3D

var explosion_point: Vector3

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
	
	sprite_component.stop()
	sprite_component.play("beam")

	for entity in area_component.get_entities_in_area():
		entity.damage_entity(damage, -global_basis.z)

func _process(delta: float) -> void:
	super(delta)
	if is_firing:
		var aim_world: Vector3 = global_position - global_basis.z * 5.0
		if entity != null and entity.aim_component != null:
			aim_world = entity.aim_component.aim_position
		raycast_component.target_position = raycast_component.to_local(aim_world)
		var hit = raycast_component.get_hit()
		explosion_point = aim_world
		if hit["point"] != null and (global_position - hit["point"]).length_squared() < (global_position - aim_world).length_squared():
			explosion_point = hit["point"]

		area_component.global_position = explosion_point

		ray_node.look_at_from_position(lerp(global_position, explosion_point, 0.5), explosion_point)
		ray_node.scale.z = (global_position - explosion_point).length()

		ray_node.visible = true
	else:
		ray_node.visible = false
	sprite_component.visible = ray_node.visible
		
