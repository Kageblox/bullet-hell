class_name InputManagerGlobal
extends Node
## Global Script in charge of Inputs.

#region Variables

const JOYSTICK_DEADZONE = 0.1

## Whether the Player's Inputs have been disabled.
@export var inputs_disabled: bool = false

var _debug_controller: bool = false
@export var debug_controller: bool:
	get:
		return _debug_controller
	set(value):
		_debug_controller = value
		if value:
			using_controller = true
			update_focus()
		else:
			using_controller = false
			clear_focus()

var using_controller = false
var _timer: Timer = null

## Normalized Movement Input of the Player.
var move_input: Vector2

#endregion

#region Functions

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Creates, configures, and adds a new timer under this node.
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.autostart = false
	_timer.ignore_time_scale = true
	_timer.timeout.connect(
		func():
			inputs_disabled = false
			)
	add_child(_timer)
	
	if debug_controller:
		using_controller = true


func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	MenuManager.on_any_menu_open_start.connect(clear_focus)
	MenuManager.on_any_menu_open_end.connect(update_focus)
	MenuManager.on_any_menu_close_start.connect(clear_focus)
	MenuManager.on_any_menu_close_end.connect(update_focus)
	
	update_focus()
	
func _process(delta: float) -> void:
	move_input = Input.get_vector("move_left","move_right","move_down","move_up")

func _input(event):
	if event.is_action_pressed("ui_cancel") and not inputs_disabled:
		var foremost_menu = MenuManager.get_foremost_menu()
		if foremost_menu != null:
			if foremost_menu.background_click_closes_menu:
				foremost_menu.close()
		elif SceneManager.current_scene.pausable:
			MenuManager.open_pause_menu()


## Disables the Player's Inputs for a certain duration.[br]
## If the Player's Inputs are already disabled, adds to the duration if it's longer than the time left.
func disable_inputs(duration: float) -> void:
	get_viewport().gui_release_focus()
	if duration >  _timer.time_left:
		inputs_disabled = true
		_timer.start(duration)


## Unfocuses from all UI elements.
func clear_focus() -> void:
	get_viewport().gui_release_focus()


## Updates the currently focused UI element.
func update_focus() -> void:
	if Input.get_connected_joypads().size() <= 0 && !debug_controller:
		return
	
	# If there's no menu currently open, focus on the focus_control specified by the MenuInstance.
	if MenuManager.foremost_menu_index == -1:
		var target = SceneManager.current_scene
		
		if target.focus_control != null:
			target.focus_control.grab_focus()
			return
	
	# Else, focus on the focus_control specified by the foremost MenuInstance.
	else:
		var target = MenuManager.get_foremost_menu()
		if target == null or not ("focus_control" in target):
			return
		else:
			if target.focus_control != null:
				target.focus_control.grab_focus()
				return


func _on_joy_connection_changed(_device_id: int, connected: bool):
	if connected:
		using_controller = true
		update_focus()
	else:
		using_controller = false
		clear_focus()
		
#endregion
