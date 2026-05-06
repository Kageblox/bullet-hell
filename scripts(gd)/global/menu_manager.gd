class_name MenuManagerGlobal
extends Node
## Global Script in charge of Menus.

#region Signals

## Emitted at the start of any Menu Instance's Open Animation.
signal on_any_menu_open_start()

## Emitted at the end of any Menu Instance's Open Animation.
signal on_any_menu_open_end()

## Emitted at the start of any Menu Instance's Close Animation.
signal on_any_menu_close_start()

## Emitted at the end of any Menu Instance's Close Animation.
signal on_any_menu_close_end()

#endregion

#region Variables

# Various Menus
var question_menu_resource = preload("res://scene(tscn)/ui/menus/question_menu.tscn") as Resource
var settings_menu_resource = preload("res://scene(tscn)/ui/menus/settings_menu.tscn") as Resource
var pause_menu_resource = preload("res://scene(tscn)/ui/menus/pause_menu.tscn") as Resource

## The foremost menu's child index. -1 if there are no open menus.
@export var foremost_menu_index = -1

#endregion

#region Functions

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	var foremost_menu = get_foremost_menu()
	if foremost_menu:
		if  foremost_menu.escape_closes_menu and event.is_action_pressed("ui_cancel") and not InputManager.inputs_disabled:
			foremost_menu.close()


## Opens the Question Menu.[br]
## Parameters:[br]
## question: The question being asked.[br]
## answers: A Dictionary matching the text to be put in each answer button to their callback.[br]
func open_question_menu(question: String, answers: Dictionary[String, Callable]) -> void:
	var question_menu = question_menu_resource.instantiate() as QuestionMenu
	_open_menu(question_menu, [question, answers])


## Opens the Settings Menu.[br]
func open_settings_menu() -> void:
	var settings_menu = settings_menu_resource.instantiate() as SettingsMenu
	_open_menu(settings_menu)


## Opens the Pause Menu.[br]
func open_pause_menu() -> void:
	var pause_menu = pause_menu_resource.instantiate() as PauseMenu
	_open_menu(pause_menu)


## Returns the foremost menu.
func get_foremost_menu() -> MenuInstance:
	if foremost_menu_index < 0:
		return null
	else:
		return get_child(MenuManager.foremost_menu_index) as MenuInstance


## Closes all Menus.[br]
## Parameters:[br]
## instant: Whether to do so instantly by deleting them, or by closing them normally.
func close_all_menus(instant: bool) -> void:
	if instant:
		for child in get_children():
			child.queue_free()
	else:
		for child in get_children():
			child.close()
	foremost_menu_index = -1


## Opens a Menu.[br]
## Parameters:[br]
## menu: The Menu Instance to open.[br]
## _params: Parameters required to open the specified Menu Instance.[br]
func _open_menu(menu: MenuInstance, _params: Array[Variant] = []) -> void:
	# Adds and opens the given menu under this node, and updates the foremost_menu_index.
	get_parent().move_child(self, -1)
	add_child(menu)
	menu.open(_params)
	foremost_menu_index = foremost_menu_index + 1

#endregion
