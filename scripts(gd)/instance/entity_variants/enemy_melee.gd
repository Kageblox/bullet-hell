class_name EnemyRangedEntity
extends EntityInstance
## Instance Script that oversees a ranged enemy.

#region Variables

@export_group("Other Components")
@export var aim_component: EntityAimComponent
@export var hitbox_component: EntityHitboxComponent
@export var pathfinder_component: EntityPathfinderComponent
@export var rigid_body_component: EntityRigidBodyComponent
@export var state_machine_component: EntityStateMachineComponent
@export var weapon: WeaponInstance

@export_group("States")
@export_subgroup("Idle")
@export var idle_range: float = 10 ## How far away the Enemy can detect the player.

var idle_state = EntityState.new(
	func(): # on_enter
		sprite.current_sprite_mode = EntitySpriteComponent.SpriteMode.HORIZONTAL_FLIP_RIGIDBODY
		aim_component.current_aim_state = aim_component.AimState.VELOCITY
		weapon.is_firing = false
		pass,
	func(delta: float): # on_process
		if get_distance_to_player() < idle_range:
			state_machine_component.current_state = chasing_state
		
		if sprite.animation == "hit" and sprite.is_playing():
			return
		if sprite.animation != "idle":
			sprite.play("idle")
		pass,
	func(delta: float): # on_physics_process
		stand_still()
		pass,
	func(): # on_exit
		pass,
)

@export_subgroup("Chasing")
@export var attacking_range: float = 5 ## How closely the Enemy will approach the player before attacking.

var chasing_state = EntityState.new(
	func(): # on_enter
		aim_component.current_aim_state = aim_component.AimState.VELOCITY
		weapon.is_firing = false
		pass,
	func(delta: float): # on_process
		var distance_to_player = get_distance_to_player()
		if is_player_visible():
			if distance_to_player < attacking_range:
				state_machine_component.current_state = attacking_state
			elif distance_to_player > idle_range:
				state_machine_component.current_state = idle_state
		
		if sprite.animation == "hit" and sprite.is_playing():
			return
		if rigid_body_component.linear_velocity.length() > idle_animation_max_velocity:
			if sprite.animation != "run":
				sprite.play("run")
		else:
			if sprite.animation != "idle":
				sprite.play("idle")
		pass,
	func(delta: float): # on_physics_process
		chase_player()
		pass,
	func(): # on_exit
		pass,
)

@export_subgroup("Attacking")
@export var chasing_range: float = 7

var attacking_state = EntityState.new(
	func(): # on_enter
		aim_component.current_aim_state = aim_component.AimState.POSITION
		weapon.is_firing = true
		pass,
	func(delta: float): # on_process
		
		aim_component.aim_position = GameManager.player.hitbox_component.global_position
		var distance_to_player = get_distance_to_player()
		if is_player_visible():
			if distance_to_player < fleeing_range:
				state_machine_component.current_state = fleeing_state
			elif distance_to_player > chasing_range:
				state_machine_component.current_state = chasing_state
		else:
			state_machine_component.current_state = chasing_state
		
		if sprite.animation == "hit" and sprite.is_playing():
			return
		if rigid_body_component.linear_velocity.length() > idle_animation_max_velocity:
			if sprite.animation != "run":
				sprite.play("run")
		else:
			if sprite.animation != "idle":
				sprite.play("idle")
		pass,
	func(delta: float): # on_physics_process
		stand_still()
		pass,
	func(): # on_exit
		pass,
)

@export_subgroup("Fleeing")
@export var fleeing_range: float = 3
	
var fleeing_state = EntityState.new(
	func(): # on_enter
		aim_component.current_aim_state = aim_component.AimState.VELOCITY
		weapon.is_firing = false
		pass,
	func(delta: float): # on_process
		if get_distance_to_player() > attacking_range:
			state_machine_component.current_state = attacking_state
		
		if sprite.animation == "hit" and sprite.is_playing():
			return
		if rigid_body_component.linear_velocity.length() > idle_animation_max_velocity:
			if sprite.animation != "run":
				sprite.play("run")
		else:
			if sprite.animation != "idle":
				sprite.play("idle")

		pass,
	func(delta: float): # on_physics_process
		flee_from_player()
		pass,
	func(): # on_exit
		pass,
)

@export_group("Advanced")	
@export_flags_2d_physics var obstacle_detect_ray_collide_layers: int
@export var idle_animation_max_velocity: float = 0.1 ## The velocity needed for the sprite to exit its idle animation.

#endregion

#region Functions

func _ready() -> void:
	state_machine_component.current_state = idle_state

func damage_entity(value: float, direction: Vector3) -> void:
	super(value, direction)
	
	# If not invincible, 
	if not invincible:
		sprite.play("hit")


func entity_die() -> void:
	set_unused()

func get_distance_to_player() -> float:
	return (GameManager.player.rigid_body_component.global_position - rigid_body_component.global_position).length()


func is_player_visible() -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		GameManager.player.rigid_body_component.global_position, 
		rigid_body_component.global_position, 
		obstacle_detect_ray_collide_layers)
		
	var result = space_state.intersect_ray(query)

	return result.is_empty()


func stand_still() -> void:
	rigid_body_component.target_velocity = Vector3.ZERO


func chase_player() -> void:
	pathfinder_component.target_position = GameManager.player.rigid_body_component.global_position
	var next_path_position = pathfinder_component.get_next_path_position()
	rigid_body_component.target_velocity = rigid_body_component.global_position.direction_to(next_path_position) * rigid_body_component.speed


func flee_from_player() -> void:
	rigid_body_component.target_velocity = (rigid_body_component.global_position - GameManager.player.rigid_body_component.global_position).normalized() * rigid_body_component.speed

#endregion
