class_name EntityStateMachineComponent
extends Node
## Component Script that gives an Entity a StateMachine.

#region Signals

signal on_current_state_changed(new_state: EntityState)

#endregion

#region Variables

var _current_state: EntityState
var current_state: EntityState:
	get:
		return _current_state
	set(value):
		if current_state:
			_current_state.on_exit.emit()
		_current_state = value
		on_current_state_changed.emit(value)
		_current_state.on_enter.emit()

## The entity this component is attached to.
var entity: EntityInstance

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)

func _ready() -> void:
	if current_state:
		current_state.on_enter.emit()
	
func _process(delta: float) -> void:
	if current_state:
		current_state.on_process.emit(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.on_physics_process.emit(delta)

#endregion
