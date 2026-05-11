class_name RangedEnemyEntity
extends EntityInstance
## Instance Script that oversees a ranged enemy.

#region Variables

@export_group("Other Components")
@export var aim_component: EntityAimComponent
@export var hitbox_component: EntityHitboxComponent
@export var pathfinder_component: EntityPathfinderComponent
@export var rigid_body_component: EntityRigidBodyComponent
@export var state_machine_component: EntityStateMachineComponent
@export var automatic_spawner_weapon: AutomaticSpawnerWeapon

@export_group("Basic")
@export var detection_distance: float = 10 ## How far away the Enemy can detect the player.

@export var comfortable_attacking_distance: float = 5
@export var min_attacking_distance: float = 3
@export var max_attacking_distance: float = 7

@export_group("Advanced")
@export var idle_animation_max_velocity: float = 0.1 ## The velocity needed for the sprite to exit its idle animation.

var charging_timer: float = 0
var cooldown_timer: float = 0


var idle_state = EntityState.new(
	func(): # on_enter
		
		sprite.current_sprite_mode = EntitySpriteComponent.SpriteMode.HORIZONTAL_FLIP_RIGIDBODY
		aim_component.current_aim_state = aim_component.AimState.VELOCITY
		
		pass,
	func(delta: float): # on_process
		
		if get_distance_to_player() < detection_distance:
			state_machine_component.current_state = chasing_state
			
		if rigid_body_component.linear_velocity.length() > idle_animation_max_velocity:
			sprite.current_animation = "walk"
		else:
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
			if distance_to_player < comfortable_attacking_distance:
				state_machine_component.current_state = attacking_state
			elif distance_to_player > detection_distance:
				state_machine_component.current_state = idle_state
		
		if rigid_body_component.linear_velocity.length() > idle_animation_max_velocity:
			sprite.current_animation = "run"
		else:
			sprite.current_animation = "idle"
			
		pass,
	func(delta: float): # on_physics_process
		
		chase_player()
		
		pass,
	func(): # on_exit
		pass,
)

var attacking_state = EntityState.new(
	func(): # on_enter
		
		sprite.current_sprite_mode = EntitySpriteComponent.SpriteMode.HORIZONTAL_FLIP_RIGIDBODY
		aim_component.current_aim_state = aim_component.AimState.POSITION
		automatic_spawner_weapon.is_firing = true
		
		pass,
	func(delta: float): # on_process
		
		aim_component.aim_position = GameManager.player.hitbox_component.global_position
		
		var distance_to_player = get_distance_to_player()
		
		if is_player_visible():
			if distance_to_player > max_attacking_distance:
				state_machine_component.current_state = chasing_state
			elif distance_to_player < min_attacking_distance:
				state_machine_component.current_state = fleeing_state
		else:
			state_machine_component.current_state = chasing_state

		sprite.current_animation = "idle"

		pass,
	func(delta: float): # on_physics_process

		stand_still()

		pass,
	func(): # on_exit
		
		automatic_spawner_weapon.is_firing = false
		
		pass,
)

var fleeing_state = EntityState.new(
	func(): # on_enter
		
		sprite.current_sprite_mode = EntitySpriteComponent.SpriteMode.HORIZONTAL_FLIP_RIGIDBODY
		aim_component.current_aim_state = aim_component.AimState.VELOCITY
		
		pass,
	func(delta: float): # on_process
		
		if get_distance_to_player() > comfortable_attacking_distance:
			state_machine_component.current_state = attacking_state

		if rigid_body_component.linear_velocity.length() > idle_animation_max_velocity:
			sprite.current_animation = "run"
		else:
			sprite.current_animation = "idle"
			
		pass,
	func(delta: float): # on_physics_process
		
		stand_still()
		
		pass,
	func(): # on_exit
		pass,
)

#endregion

#region Functions

func _ready() -> void:
	state_machine_component.current_state = idle_state


func damage_entity(value: float, direction: Vector3) -> void:
	super(value, direction)
	
	# If not invincible, 
	if not invincible:
		sprite.animation_override = "hit"


func get_distance_to_player() -> float:
	return (GameManager.player.rigid_body_component.global_position - rigid_body_component.global_position).length()


func is_player_visible() -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		GameManager.player.rigid_body_component.global_position, 
		rigid_body_component.global_position, 
		GameManager.environment_layer)
		
	var result = space_state.intersect_ray(query)

	return result.is_empty()


func stand_still() -> void:
	rigid_body_component.target_velocity = Vector3.ZERO


func chase_player() -> void:
	pathfinder_component.target_position = GameManager.player.rigid_body_component.global_position
	var next_path_position = pathfinder_component.get_next_path_position()
	rigid_body_component.target_velocity = rigid_body_component.global_position.direction_to(next_path_position) * rigid_body_component.speed


func get_angle_to_player() -> float:
	var forward_vector = -aim_component.global_basis.z
	return forward_vector.angle_to(GameManager.player.hitbox_component.global_position - aim_component.global_position)

#endregion
