class_name EntityState
extends Resource
## Resource Script used for Entity State Machines.

signal on_enter() ## Emitted when the State is entered
signal on_process(delta: float) ## Emitted within the Entity's _process function while in this state.
signal on_physics_process(delta: float) ## Emitted within the Entity's _physics_process function while in this state.
signal on_exit() ## Emitted when the State is exited

func _init(
	_on_enter: Callable,
	_on_process: Callable,
	_on_physics_process: Callable,
	_on_exit: Callable,
) -> void:
	on_enter.connect(_on_enter)
	on_process.connect(_on_process)
	on_physics_process.connect(_on_physics_process)
	on_exit.connect(_on_exit)
	
