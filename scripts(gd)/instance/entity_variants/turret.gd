class_name TurretInstance
extends EntityInstance
## Instance Script that oversees a Turret Enemy

#region Variables

@export_group("Other Components")
@export var aim_component: EntityAimComponent
@export var health_component: EntityHealthComponent
@export var spawn_component: EntitySpawnComponent
@export var projectile_spawner_component: EntitySpawnerComponent
@export var static_body_component: EntityStaticBodyComponent
@export var cooldown_timer: Timer

@export_group("Stats")
@export var cooldown: float = 0.5

@export_group("Advanced")
@export_flags_2d_physics var ray_collide_layers: int

#endregion

#region Parameters

func _ready() -> void:
	cooldown_timer.timeout.connect(
		func():
			projectile_spawner_component.spawn_singular("enemy_projectile")
	)

func _process(delta: float) -> void:
	if GameManager.player_instance:
		var player_position = GameManager.player_instance.health_component.global_position
		
		aim_component.aim_position = player_position
		if detect_obstacle(aim_component.global_position, player_position).is_empty():
			if cooldown_timer.is_stopped():
				cooldown_timer.start(cooldown)
		else:
			if not cooldown_timer.is_stopped():
				cooldown_timer.stop()
			
func detect_obstacle(from: Vector3, to: Vector3) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to, ray_collide_layers)
	
	return space_state.intersect_ray(query)

#endregion
