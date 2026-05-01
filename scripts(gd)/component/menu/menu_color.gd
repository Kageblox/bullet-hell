class_name MenuColorComponent
extends ColorRect
## Component Script that chages color when the connected menu opens or closes.

#region Variables

@export var invisible_color: Color = Color(1,1,1,0)

@export var visible_color: Color = Color(1,1,1,1)

@export var entry_transition : Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var entry_ease : Tween.EaseType = Tween.EaseType.EASE_OUT

@export var exit_transition : Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var exit_ease : Tween.EaseType = Tween.EaseType.EASE_IN

var connected_menu: MenuInstance

#endregion

#region Functions

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		connected_menu = GeneralUtility.get_nearest_parent_of_class(self, MenuInstance)
		connected_menu.on_open_start.connect(
			func():
				_tween_color(
					invisible_color, 
					visible_color, 
					connected_menu.open_duration, 
					entry_ease, 
					entry_transition)
				)
		connected_menu.on_close_start.connect(
			func():
				_tween_color(
					visible_color, 
					invisible_color, 
					connected_menu.close_duration, 
					exit_ease, 
					exit_transition)
				)

func _tween_color(_from: Color, _to: Color, _duration: float, _ease: Tween.EaseType, _transition: Tween.TransitionType) -> void:
	color = _from
	
	var tween = create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "color", _to, _duration).set_ease(_ease).set_trans(_transition)

#endregion
