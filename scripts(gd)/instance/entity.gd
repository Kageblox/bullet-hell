class_name EntityInstance
extends Node
## Instance Script that controls a single entity.

# States
var current_state: EntityState

# Movement
var body: EntityBodyComponent
var move_speed: float = 7.5
var move_accel: float = 0.25

# Aiming
var aim: EntityAimComponent
var aim_state: EntityAimComponent.AimState = EntityAimComponent.AimState.POSITION

func _ready() -> void:
	if current_state != null:
		current_state.on_enter.emit()

func _process(delta: float) -> void:
	if current_state != null:
		current_state.on_process.emit(delta)

func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.on_physics_process.emit(delta)
	
func change_state(new_state: EntityState) -> void:
	if current_state != null:
		current_state.on_exit.emit()
	current_state = new_state
	current_state.on_enter.emit()
