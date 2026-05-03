class_name PlayerInstance
extends EntityInstance
## Instance Script that oversees the player.

@export_group("States")

@export_subgroup("Normal")
@export var normal_move_speed: float = 5.0
@export var normal_move_accel: float = 0.75
@export var normal_aim_max_distance: float = 10.0
@export var normal_aim_height: float = 10.0
@export var normal_aim_state: PlayerAimComponent.AimState = PlayerAimComponent.AimState.POSITION
var normal_state = EntityState.new(
		func():
			move_speed = normal_move_speed
			move_accel = normal_move_accel
			aim_max_distance = normal_aim_max_distance
			aim_height = normal_aim_height
			aim_state = normal_aim_state,
		func(delta: float):
			if InputManager.sprint_input:
				change_state(sprinting_state),
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
@export var sprinting_aim_state: PlayerAimComponent.AimState = PlayerAimComponent.AimState.VELOCITY
var sprinting_state = EntityState.new(
		func():
			move_speed = sprinting_move_speed
			move_accel = sprinting_move_accel
			aim_max_distance = sprinting_aim_max_distance
			aim_height = sprinting_aim_height
			aim_state = sprinting_aim_state,
		func(delta: float):
			if not InputManager.sprint_input:
				change_state(normal_state),
		func(delta: float):
			pass,
		func():
			pass,
	)
	
var aim_max_distance: float = 10.0
var aim_height: float = 10.0

func _enter_tree() -> void:
	current_state = normal_state

func _process(delta: float) -> void:
	super(delta)
	body.target_velocity = Vector3(
		InputManager.move_input.x * move_speed,
		 0.0,
		-InputManager.move_input.y * move_speed
	)
