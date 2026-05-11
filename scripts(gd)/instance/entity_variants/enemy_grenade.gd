class_name EnemyGrenade
extends EntityInstance
## Entity Script that defines the Grenade Enemy Type.

#region Variables

@export_group("Other Components")
@export var aim_component: EntityAimComponent
@export var hitbox_component: EntityHitboxComponent
@export var pathfinder_component: EntityPathfinderComponent
@export var raycast_component: EntityRaycastComponent
@export var rigid_body_component: EntityRigidBodyComponent
@export var state_machine_component: EntityStateMachineComponent
@export var chargable_area_weapon: ChargableAreaWeapon

@export_group("Basic")
@export var detection_distance: float = 10 ## How far away the Enemy can detect the player.

@export var kamikaze_distance: float = 5 ## Distance needed to enter the Kamikaze State.
@export var kamikaze_speed: float = 5
@export var kamikaze_acceleration: float = 0.05
@export var explode_distance: float = 2 ## Distance needed before Exploding.

@export_group("Advanced")
@export var idle_animation_max_velocity: float = 0.1 ## The velocity needed for the sprite to exit its idle animation.


var idle_state = EntityState.new(
	func(): # on_enter
		
		sprite.current_sprite_mode = EntitySpriteComponent.SpriteMode.HORIZONTAL_FLIP_RIGIDBODY
		aim_component.current_aim_state = aim_component.AimState.VELOCITY
		
		pass,
	func(delta: float): # on_process
		
		if get_distance_to_player() < detection_distance:
			state_machine_component.current_state = chasing_state
		
		sprite.current_animation = "idle"
		
		pass,
	func(delta: float): # on_physics_process
		
		stand_still()
		
		pass,
	func(): # on_exit
		pass,
)

var chasing_state = EntityState.new(
	func(): # on_enter
		
		sprite.current_sprite_mode = EntitySpriteComponent.SpriteMode.HORIZONTAL_FLIP_RIGIDBODY
		aim_component.current_aim_state = aim_component.AimState.VELOCITY
		
		pass,
	func(delta: float): # on_process
		
		var distance_to_player = get_distance_to_player()
		if is_player_visible():
			if distance_to_player < kamikaze_distance:
				state_machine_component.current_state = kamikaze_state
			elif distance_to_player > detection_distance:
				state_machine_component.current_state = idle_state
		
		sprite.current_animation = "idle"
			
		pass,
	func(delta: float): # on_physics_process
		
		chase_player()
		
		pass,
	func(): # on_exit
		pass,
)

var kamikaze_state = EntityState.new(
	func(): # on_enter
		
		sprite.current_sprite_mode = EntitySpriteComponent.SpriteMode.FOLLOW_AIM
		aim_component.current_aim_state = aim_component.AimState.VELOCITY
		
		rigid_body_component.speed = kamikaze_speed
		rigid_body_component.acceleration = kamikaze_acceleration
		
		pass,
	func(delta: float): # on_process
		
		aim_component.aim_position = GameManager.player.hitbox_component.global_position
		
		var distance_to_player = get_distance_to_player()
		
		if get_distance_to_player() < explode_distance:
			state_machine_component.current_state = exploding_state

		sprite.current_animation = "kamikaze"

		pass,
	func(delta: float): # on_physics_process

		chase_player()

		pass,
	func(): # on_exit
		
		pass,
)

var exploding_state = EntityState.new(
	func(): # on_enter
		
		sprite.current_sprite_mode = EntitySpriteComponent.SpriteMode.FOLLOW_AIM
		aim_component.current_aim_state = aim_component.AimState.VELOCITY
		
		chargable_area_weapon.begin_charging()
		
		pass,
	func(delta: float): # on_process

		sprite.current_animation = "kamikaze"
			
		pass,
	func(delta: float): # on_physics_process
		
		chase_player()
		
		pass,
	func(): # on_exit
		pass,
)

#endregion

#region Functions

func _ready() -> void:
	state_machine_component.current_state = idle_state
	
	chargable_area_weapon.on_fired.connect(
		func():
			entity_die()
			)


func get_distance_to_player() -> float:
	return (GameManager.player.rigid_body_component.global_position - rigid_body_component.global_position).length()


func is_player_visible() -> bool:
	var result = raycast_component.get_obstacle(GameManager.player.hitbox_component.global_position)
	return result["collider"] == null


func stand_still() -> void:
	rigid_body_component.target_velocity = Vector3.ZERO


func chase_player() -> void:
	pathfinder_component.target_position = GameManager.player.rigid_body_component.global_position
	var next_path_position = pathfinder_component.get_next_path_position()
	rigid_body_component.target_velocity = rigid_body_component.global_position.direction_to(next_path_position) * rigid_body_component.speed
	

func get_angle_to_player() -> float:
	var forward_vector = -aim_component.global_basis.z
	var signed_rad_angle = forward_vector.signed_angle_to(GameManager.player.hitbox_component.global_position - aim_component.global_position, Vector3.UP)
	return rad_to_deg(abs(signed_rad_angle))

#endregion
