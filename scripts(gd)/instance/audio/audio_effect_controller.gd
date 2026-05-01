class_name AudioEffectControllerInstance
extends Node
## Instance Script that controls a specific Audio Effect

#region Variables

## The actual effect, along with its activated and deactivated parameters.
var effect: ModifiedAudioEffect

## Whether the Audio Effect is active in the Audio Bus.
@export var active: bool:
	get:
		return AudioServer.is_bus_effect_enabled(
			get_parent().get_parent().get_index(), 
			get_index())
	set(value):
		AudioServer.set_bus_effect_enabled(
			get_parent().get_parent().get_index(), 
			get_index(), value)

#endregion

#region Functions

## Activates the Bus Effect.
func activate(fade_duration: float = 1.0) -> void:
	active = true
	_tween_audio_effect(
		effect.inactive_params, 
		effect.active_params,
		fade_duration,
		effect.activate_ease,
		effect.activate_transition)


## Deactivates the Bus Effect.
func deactivate(fade_duration: float = 1.0) -> void:
	_tween_audio_effect(
		effect.active_params, 
		effect.inactive_params,
		fade_duration,
		effect.deactivate_ease,
		effect.deactivate_transition)


## Tweens the Bus Effect.
func _tween_audio_effect(_from: AudioEffect, _to: AudioEffect, _duration: float, _ease: Tween.EaseType, _transition: Tween.TransitionType) -> void:
	_set_audio_effect(effect.true_params, _from)
	
	if _from.get_class() != _to.get_class():
		return push_error("From and To Audio Effects are different Audio Effects.")
	else:
		var tween = create_tween().set_parallel(true)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		
		var audio_effect_properties = _from.get_property_list()
		for property in audio_effect_properties:
			if property["type"] == 2 or property["type"] == 3: # If the Property is a float or int,
				tween.tween_property(effect.true_params, property["name"], _to.get(property["name"]), _duration).set_ease(_ease).set_trans(_transition)
		tween.tween_callback(
			func():
				if _to == effect.inactive_params:
					active = false
				).set_delay(_duration)


## Sets the Bus Effect.
func _set_audio_effect(_from: AudioEffect, _to: AudioEffect) -> void:
	if _from.get_class() != _to.get_class():
		return push_error("From and To Audio Effects are different Audio Effects.")
	else:
		var audio_effect_properties = _from.get_property_list()
		for property in audio_effect_properties:
			if property["type"] == 2 or property["type"] == 3: # If the Property is a float or int,
				_from.set(property["name"], _to.get(property["name"]))

#endregion
