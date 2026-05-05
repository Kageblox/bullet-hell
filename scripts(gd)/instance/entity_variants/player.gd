class_name PlayerInstance
extends EntityInstance
## Instance Script that oversees the player.

#region Variables

@export_group("Other Components")
@export var player_camera: ModifiedCamera3D
@export var aim_component: EntityAimComponent
@export var health_component: EntityHealthComponent
@export var rigid_body_component: EntityRigidBodyComponent
@export var projectile_spawner_component: EntitySpawnerComponent
@export var state_machine_component: EntityStateMachineComponent

@export_group("States")

@export_subgroup("Aiming")
@export var aiming_move_speed: float = 5.0
@export var aiming_move_accel: float = 0.75
@export var aiming_aim_max_distance: float = 10.0
@export var aiming_aim_height: float = 10.0
@export var aiming_aim_state: EntityAimComponent.AimState = EntityAimComponent.AimState.POSITION

var aiming_state = EntityState.new(
		func():
			rigid_body_component.speed = aiming_move_speed
			rigid_body_component.acceleration = aiming_move_accel
			aim_max_distance = aiming_aim_max_distance
			aim_height = aiming_aim_height
			aim_component.current_aim_state = aiming_aim_state,
		func(delta: float):
			if InputManager.sprint_input:
				state_machine_component.current_state = sprinting_state,
		func(delta: float):
			pass,
		func():
			pass,
	)

@export_subgroup("Sprinting")
@export var sprinting_move_speed: float = 10.0
@export var sprinting_move_accel: float = 0.5
@export var sprinting_aim_max_distance: float = 10.0
@export var sprinting_aim_height: float = 10.0
@export var sprinting_aim_state: EntityAimComponent.AimState = EntityAimComponent.AimState.VELOCITY

var sprinting_state = EntityState.new(
		func():
			rigid_body_component.speed = sprinting_move_speed
			rigid_body_component.acceleration = sprinting_move_accel
			aim_max_distance = sprinting_aim_max_distance
			aim_height = sprinting_aim_height
			aim_component.current_aim_state = sprinting_aim_state,
		func(delta: float):
			if not InputManager.sprint_input:
				state_machine_component.current_state = aiming_state,
		func(delta: float):
			pass,
		func():
			pass,
	)
	
@export_group("Advanced")
@export var ray_length: float = 1000
@export_flags_2d_physics var ray_collide_layers: int

var aim_distance_curve: Curve = preload("res://resource(tres)/curves/player_aim_distance_curve.tres") as Curve
var aim_max_distance: float = 10.0
var aim_height: float = 10.0

#endregion

#region Functions

func _ready() -> void:
	GameManager.player_instance = self
	
	state_machine_component.current_state = aiming_state
	
	InputManager.on_primary_fire_pressed.connect(
		func():
		if state_machine_component.current_state == aiming_state:
			projectile_spawner_component.spawn_singular("player_projectile")
		)

func _process(delta: float) -> void:
	rigid_body_component.target_velocity = Vector3(InputManager.move_input.x, 0.0, -InputManager.move_input.y) * rigid_body_component.speed

	var raw_aim_vector = raycast_from_camera()["position"] - aim_component.global_position # The vector that points from the player to the aimed position.
	var clamped_aim_vector = raw_aim_vector.limit_length(aim_max_distance)
	var aim_position = clamped_aim_vector + aim_component.global_position
	
	aim_component.aim_position = aim_position
	
	var aim_lerp = aim_distance_curve.sample(clamped_aim_vector.length()/aim_max_distance)
	player_camera.target_position = lerp(aim_component.global_position, aim_position, aim_lerp) + Vector3(0, aim_height, 0)

		
## Returns various stats from the currently moused-over position
func raycast_from_camera() -> Dictionary:
	var space_state = aim_component.get_world_3d().direct_space_state

	var origin = player_camera.project_ray_origin(InputManager.mouse_pos)
	var end = origin + player_camera.project_ray_normal(InputManager.mouse_pos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end, ray_collide_layers)
	query.collide_with_areas = true

	return space_state.intersect_ray(query)

#endregion
