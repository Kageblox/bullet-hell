@tool
@icon("res://images(png)/ui/icons/Button.svg")
class_name ButtonModified
extends PanelContainer
## A modified version of the normal Button Node.

#region Label

@export_group("Label")

var _label: Label
var label: Label:
	get:
		if _label == null:
			initialize()
		return _label

@export var text: String:
	get:
		return label.text
	set(value):
		label.text = value

@export var label_settings: LabelSettings:
	get:
		return label.label_settings
	set(value):
		label.label_settings = value

@export var horizontal_alignment: HorizontalAlignment:
	get:
		return label.horizontal_alignment
	set(value):
		label.horizontal_alignment = value

@export var vertical_alignment: VerticalAlignment:
	get:
		return label.vertical_alignment
	set(value):
		label.vertical_alignment = value

@export var autowrap_mode: TextServer.AutowrapMode:
	get:
		return label.autowrap_mode
	set(value):
		label.autowrap_mode = value


#endregion

#region Button

@export_group("Button")

var _button: Button
var button: Button:
	get:
		if _button == null:
			initialize()
		return _button

signal pressed()
signal toggled(toggled_on: bool)

@export var disabled: bool:
	get:
		return button.disabled
	set(value):
		button.disabled = value

@export var toggle_mode: bool:
	get:
		return button.toggle_mode
	set(value):
		button.toggle_mode = value

@export var button_pressed: bool:
	get:
		return button.button_pressed
	set(value):
		button.button_pressed = value

#endregion

#region Margins

@export_group("Margins")
var _margins: MarginContainer
var margins: MarginContainer:
	get:
		if _margins == null:
			initialize()
		return _margins

@export var margin_left: int:
	get:
		return margins.get_theme_constant("margin_left")
	set(value):
		margins.add_theme_constant_override("margin_left", value)

@export var margin_top: int:
	get:
		return margins.get_theme_constant("margin_top")
	set(value):
		margins.add_theme_constant_override("margin_top", value)

@export var margin_right: int:
	get:
		return margins.get_theme_constant("margin_right")
	set(value):
		margins.add_theme_constant_override("margin_right", value)

@export var margin_bottom: int:
	get:
		return margins.get_theme_constant("margin_bottom")
	set(value):
		margins.add_theme_constant_override("margin_bottom", value)

#endregion

#region Other Variables

var connected_menu: MenuInstance

var _on_any_menu_open_start: Callable
var _on_any_menu_open_end: Callable
var _on_any_menu_close_start: Callable
var _on_any_menu_close_end: Callable

#endregion

#region Functions

func initialize() -> void:
	if has_node("Button"):
		_button = get_node("Button")
		_button.owner = self
	else:
		_button = Button.new()
		_button.name = "Button"
		add_child(_button)
		_button.owner = self

	if has_node("Margins"):
		_margins = get_node("Margins")
		_margins.owner = self
	else:
		_margins = MarginContainer.new()
		_margins.name = "Margins"
		add_child(_margins)
		_margins.owner = self
		_margins.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if has_node("Margins/Label"):
		_label = get_node("Margins/Label")
		_label.owner = self
	else:
		_label = Label.new()
		_label.name = "Label"
		_margins.add_child(_label)
		_label.owner = self
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		
		button.pressed.connect(
			func():
				pressed.emit()
				AudioManager.play_sfx("button_press")
		)
				
		button.toggled.connect(
			func(toggled_on: bool):
				toggled.emit(toggled_on)
		)
		
		connected_menu = GeneralUtility.get_nearest_parent_of_class(self, MenuInstance)
		focus_mode = Control.FOCUS_ALL
		focus_entered.connect(
			func():
				button.grab_focus()
				)
		
		_on_any_menu_open_start = func():
			disabled = true
		
		_on_any_menu_open_end = func():
			if connected_menu:
				if connected_menu.get_index() == MenuManager.foremost_menu_index:
					disabled = false
			else:
				disabled = true
		
		_on_any_menu_close_start = func():
			disabled = true
			
		_on_any_menu_close_end = func():
			if connected_menu:
				if connected_menu.get_index() == MenuManager.foremost_menu_index:
					disabled = false
			else:
				if MenuManager.foremost_menu_index == -1:
					disabled = false
		
		MenuManager.on_any_menu_open_start.connect(_on_any_menu_open_start)
		MenuManager.on_any_menu_open_end.connect(_on_any_menu_open_end)
		MenuManager.on_any_menu_close_start.connect(_on_any_menu_close_start)
		MenuManager.on_any_menu_close_end.connect(_on_any_menu_close_end)
		
func _exit_tree() -> void:
	if _on_any_menu_open_start and MenuManager.on_any_menu_open_start.is_connected(_on_any_menu_open_start):
		MenuManager.on_any_menu_open_start.disconnect(_on_any_menu_open_start)
	if _on_any_menu_open_end and MenuManager.on_any_menu_open_end.is_connected(_on_any_menu_open_end):
		MenuManager.on_any_menu_open_end.disconnect(_on_any_menu_open_end)
	if _on_any_menu_close_start and MenuManager.on_any_menu_close_start.is_connected(_on_any_menu_close_start):
		MenuManager.on_any_menu_close_start.disconnect(_on_any_menu_close_start)
	if _on_any_menu_close_end and MenuManager.on_any_menu_close_end.is_connected(_on_any_menu_close_end):
		MenuManager.on_any_menu_close_end.disconnect(_on_any_menu_close_end)
#endregion
