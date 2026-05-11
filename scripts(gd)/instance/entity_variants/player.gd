class_name PlayerEntity
extends EntityInstance
## Instance Script that controls the player.

#region Variables

@export_group("Other Components")
@export var player_camera: NewCamera
@export var aim_component: EntityAimComponent
@export var hitbox_component: EntityHitboxComponent
@export var rigid_body_component: EntityRigidBodyComponent
@export var state_machine_component: EntityStateMachineComponent
@export var player_shape: CollisionShape3D
@export var automatic_raycast_area_weapon: AutomaticRaycastAreaWeapon
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
		_target_body_size = aiming_body_size
		rigid_body_component.mass = aiming_body_mass
		
		aim_max_distance = aiming_aim_max_distance
		aim_height = aiming_aim_height
		aim_component.current_aim_state = aiming_aim_state,
		
	func(delta: float):
		
		# Link the weapon's firing to the player's fire input.
		automatic_raycast_area_weapon.is_firing = InputManager.primary_fire_input 

		if InputManager.sprint_input:
			state_machine_component.current_state = sprinting_state
			
		if rigid_body_component.linear_velocity.length() > idle_animation_max_velocity:
			sprite.current_animation = "walk"
			if !AudioManager.is_playing_sfx("walk"):
				AudioManager.play_sfx("walk")
		
		else:
			sprite.current_animation = "idle"
			if AudioManager.is_playing_sfx("walk"):
				AudioManager.stop_sfx("walk")
			
		pass,
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
		
		automatic_raycast_area_weapon.is_firing = false
		
		rigid_body_component.speed = sprinting_body_speed
		rigid_body_component.acceleration = sprinting_body_accel
		_target_body_size = sprinting_body_size
		rigid_body_component.mass = sprinting_body_mass
		
		aim_max_distance = sprinting_aim_max_distance
		aim_height = sprinting_aim_height
		aim_component.current_aim_state = sprinting_aim_state
		
		AudioManager.play_sfx("dash")
		
		pass,
	func(delta: float):
		
		if not InputManager.sprint_input:
			state_machine_component.current_state = aiming_state
			
		if rigid_body_component.linear_velocity.length() > idle_animation_max_velocity:
			sprite.current_animation = "run"
		else:
			sprite.current_animation = "idle"
			
		pass,
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
var _self_rids: Array[RID] = []
var _initial_y: float = 0.0
var _target_body_size: float = 1.0
@export var body_size_smooth_speed: float = 18.0

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

	_collect_self_rids(self)
	_initial_y = rigid_body_component.global_position.y

func _collect_self_rids(node: Node) -> void:
	if node is CollisionObject3D:
		_self_rids.append((node as CollisionObject3D).get_rid())
	for c in node.get_children():
		_collect_self_rids(c)


func _process(delta: float) -> void:
	super(delta)

	# Set the Rigid Body Component's Velocity, based on the Player's move input.
	rigid_body_component.target_velocity = Vector3(InputManager.move_input.x, 0.0, -InputManager.move_input.y) * rigid_body_component.speed

	# Smoothly animate body scale toward target.
	var s_t: float = clamp(body_size_smooth_speed * delta, 0.0, 1.0)
	var current_s: float = player_shape.scale.x
	var new_s: float = lerp(current_s, _target_body_size, s_t)
	player_shape.scale = Vector3(new_s, new_s, new_s)

	var pos: Vector3 = rigid_body_component.global_position
	if pos.y != _initial_y:
		pos.y = _initial_y
		rigid_body_component.global_position = pos
	if rigid_body_component.linear_velocity.y != 0.0:
		var v: Vector3 = rigid_body_component.linear_velocity
		v.y = 0.0
		rigid_body_component.linear_velocity = v

	# Raycast from the camera through the mouse to find what the player is aiming at.
	var camera_raycast = raycast_from_camera()
	# if camera_raycast:

	# Raycast from the camera to the aimed position.
	# var camera_raycast = raycast_from_camera()
	
	# # If the ray hit anything,
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

	# var raw_aim_vector = camera_raycast["position"] - aim_component.global_position
	# var clamped_aim_vector = raw_aim_vector.limit_length(aim_max_distance)
	# aim_component.aim_position = clamped_aim_vector + aim_component.global_position


func damage_entity(value: float, direction: Vector3) -> void:
	var horizontal: Vector3 = Vector3(direction.x, 0.0, direction.z)
	if horizontal.length_squared() > 0.0:
		horizontal = horizontal.normalized()
	super(value, horizontal)

	# If not invincible,
	if not invincible:
		sprite.animation_override = "pain"
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
	query.exclude = _self_rids

	return space_state.intersect_ray(query)

#endregion
