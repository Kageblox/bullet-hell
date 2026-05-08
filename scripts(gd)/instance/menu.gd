class_name MenuInstance
extends Control
## Instance Script that oversees and represents a single Menu.

#region Signals

## Emitted at the start of the menu's open animation.
signal on_open_start()

## Emitted at the end of the menu's open animation.
signal on_open_end()

## Emitted at the start of the menu's close animation.
signal on_close_start()

## Emitted at the end of the menu's close animation.
signal on_close_end()

#endregion

#region Variables

## How long it takes for the Menu to be fully opened.
@export var open_duration: float = 1.0

## How long it takes for the Menu to be fully closed.
@export var close_duration: float = 1.0

## Whether clocking the background closes the menu.
@export var background_click_closes_menu: bool = false

## Whether the escape input closes the menu.
@export var escape_closes_menu: bool = false

## Whether the menu deletes itself upon being closed. If False, it'll be hidden instead.
@export var queue_free_on_close: bool = true

## The first UI element that'll be focused on when the menu's open.
@export var focus_control: Control

#endregion

#region Functions

func _enter_tree() -> void:
	## If the background is clicked, close the Menu.
	if background_click_closes_menu:
		gui_input.connect(
			func(event: InputEvent):
				if event is InputEventMouseButton:
					if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and !InputManager.inputs_disabled:
						close()
					)

## Opens the Menu.[br]
## Parameters:[br]
## _params: Parameters required to open the specified Menu Instance.[br]
func open(_params: Array[Variant] = [])-> void:
	visible = true
	
	on_open_start.emit()
	MenuManager.on_any_menu_open_start.emit()
	
	InputManager.disable_inputs(open_duration)
	
	await get_tree().create_timer(open_duration).timeout
	
	on_open_end.emit()
	MenuManager.on_any_menu_open_end.emit()


## Closes the Menu.
func close() -> void:
	MenuManager.foremost_menu_index = MenuManager.foremost_menu_index - 1
	
	on_close_start.emit()
	MenuManager.on_any_menu_close_start.emit()
	
	InputManager.disable_inputs(close_duration)
	
	await get_tree().create_timer(close_duration).timeout
	
	on_close_end.emit()
	MenuManager.on_any_menu_close_end.emit()
	
	if queue_free_on_close:
		queue_free()
	else:
		visible = false

#endregion
