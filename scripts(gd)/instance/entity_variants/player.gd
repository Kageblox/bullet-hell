class_name PlayerEntity
extends EntityInstance
## Instance Script that controls the player.

#region Variables

@export_group("Other Components")
@export var player_camera: ModifiedCamera3D
@export var aim_component: EntityAimComponent
@export var hitbox_component: EntityHitboxComponent
@export var rigid_body_component: EntityRigidBodyComponent
@export var state_machine_component: EntityStateMachineComponent
@export var player_shape: CollisionShape3D
@export var weapon: WeaponInstance
@export var hitstop_timer: Timer

@export_group("States")

@export_subgroup("Aiming")
@export var aiming_body_speed: float = 5.0
@export var aiming_body_accel: float = 0.75
@export var aiming_body_size: float = 1.0
@export var aiming_body_mass: float = 1.0

@export var aiming_aim_max_distance: float = 10.0
@export var aiming_aim_height: float = 10.0
@export var aiming_aim_state: EntityAimComponent.AimState = EntityAimComponent.AimState.POSITION

var aiming_state = EntityState.new(
	func():
		sprite.current_sprite_mode = EntitySpriteComponent.SpriteMode.HORIZONTAL_FLIP_RIGIDBODY
		
		rigid_body_component.speed = aiming_body_speed
		rigid_body_component.acceleration = aiming_body_accel
		player_shape.scale = Vector3(aiming_body_size, aiming_body_size, aiming_body_size)
		rigid_body_component.mass = aiming_body_mass
		
		aim_max_distance = aiming_aim_max_distance
		aim_height = aiming_aim_height
		aim_component.current_aim_state = aiming_aim_state,
	func(delta: float):
		# Link the weapon's firing to the player's fire input.
		weapon.is_firing = InputManager.primary_fire_input 

		if InputManager.sprint_input:
			state_machine_component.current_state = sprinting_state
			
		if sprite.animation == "hit" and sprite.is_playing():
			return
		if rigid_body_component.linear_velocity.length() > idle_animation_max_velocity:
			if sprite.animation != "walk":
				sprite.play("walk")
		else:
			if sprite.animation != "idle":
				sprite.play("idle"),
	func(delta: float):
		pass,
	func():
		pass,
	)

@export_subgroup("Sprinting")
@export var sprinting_body_speed: float = 10.0
@export var sprinting_body_accel: float = 0.25
@export var sprinting_body_size: float = 0.5
@export var sprinting_body_mass: float = 0.1

@export var sprinting_aim_max_distance: float = 10.0
@export var sprinting_aim_height: float = 10.0
@export var sprinting_aim_state: EntityAimComponent.AimState = EntityAimComponent.AimState.VELOCITY

var sprinting_state = EntityState.new(
	func():
		weapon.is_firing = false
		
		rigid_body_component.speed = sprinting_body_speed
		rigid_body_component.acceleration = sprinting_body_accel
		player_shape.scale = Vector3(sprinting_body_size, sprinting_body_size, sprinting_body_size)
		rigid_body_component.mass = sprinting_body_mass
		
		aim_max_distance = sprinting_aim_max_distance
		aim_height = sprinting_aim_height
		aim_component.current_aim_state = sprinting_aim_state
		pass,
	func(delta: float):
		if not InputManager.sprint_input:
			state_machine_component.current_state = aiming_state
			
		if sprite.animation == "hit" and sprite.is_playing():
			return
		if rigid_body_component.linear_velocity.length() > idle_animation_max_velocity:
			if sprite.animation != "run":
				sprite.play("run")
		else:
			if sprite.animation != "idle":
				sprite.play("idle"),
	func(delta: float):
		pass,
	func():
		pass,
	)
	
@export_group("Advanced")
@export var aim_ray_length: float = 1000 ## How far the aim ray travels.
@export_flags_2d_physics var aim_ray_collide_layers: int ## What layers the aim ray will collide with.
@export var hitstop_duration: float = 0.5 ## How long the game will freeze for when the player gets hit.
@export var hit_invincibility_duration: float = 1 ## How long the player will become invincible for after getting hit.
@export var idle_animation_max_velocity: float = 0.1 ## The velocity needed for the sprite to exit its idle animation.
## Curve that dictates the camera's target position, based on the distance between the player and the aimed position.
var aim_distance_curve: Curve = preload("res://resource(tres)/curves/player_aim_distance_curve.tres") as Curve

var aim_max_distance: float = 10.0 ## The current max distance the player can aim.
var aim_height: float = 10.0 ## The current target height of the camera.

#endregion

#region Functions

func _ready() -> void:
	GameManager.player = self

	# Upon being loaded, update the player state machine's current state.
	state_machine_component.current_state = aiming_state
	
	# And set up the hitstop timer, such that the game resumes after the timer ends.
	hitstop_timer.timeout.connect(
		func():
			GameManager.hitstop_active = false
			)


func _process(delta: float) -> void:
	super(delta)
	
	# Set the Rigid Body Component's Velocity, based on the Player's move input.
	rigid_body_component.target_velocity = Vector3(InputManager.move_input.x, 0.0, -InputManager.move_input.y) * rigid_body_component.speed

	# Raycast from the camera to the aimed position.
	var camera_raycast = raycast_from_camera()
	
	# If the ray hit anything,
	if camera_raycast:
		
		# Clamp the aimed positon to the max aim distance,
		var raw_aim_vector = raycast_from_camera()["position"] - aim_component.global_position # The vector that points from the player to the aimed position.
		var clamped_aim_vector = raw_aim_vector.limit_length(aim_max_distance)
		var aim_position = clamped_aim_vector + aim_component.global_position
		
		# And update the Aim Component's aim_position.
		aim_component.aim_position = aim_position
		
		# Update the Camera's target position based on the player's curernt position, their aimed position, and the aim distance curve.
		var aim_lerp = aim_distance_curve.sample(clamped_aim_vector.length()/aim_max_distance)
		player_camera.target_position = lerp(aim_component.global_position, aim_position, aim_lerp) + Vector3(0, aim_height, 0)
	else:
		# Else, focus on the player.
		player_camera.target_position = aim_component.global_position + Vector3(0, aim_height, 0)


func damage_entity(value: float, direction: Vector3) -> void:
	super(value, direction)
	
	# If not invincible, 
	if not invincible:
		sprite.play("hit")
		# Trigger the player's hitstop, and make them invincible.
		hitstop_timer.start(hitstop_duration)
		GameManager.hitstop_active = true
		make_entity_invincible(hit_invincibility_duration)


## Returns various stats from the currently moused-over position
func raycast_from_camera() -> Dictionary:
	var space_state = aim_component.get_world_3d().direct_space_state

	var origin = player_camera.project_ray_origin(InputManager.mouse_pos)
	var end = origin + player_camera.project_ray_normal(InputManager.mouse_pos) * aim_ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end, aim_ray_collide_layers)
	query.collide_with_areas = true

	return space_state.intersect_ray(query)

#endregion
