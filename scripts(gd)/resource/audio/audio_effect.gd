class_name ModifiedAudioEffect
extends Resource
## Modified Version of AudioEffect.

## Params that'll be loaded when the Audio Effect is active.
@export var active_params: AudioEffect = AudioEffectLowPassFilter.new()

@export var activate_transition : Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var activate_ease : Tween.EaseType = Tween.EaseType.EASE_OUT

## Params that the Audio Effect will interpolate to right before it's deactivated.
@export var inactive_params: AudioEffect = AudioEffectLowPassFilter.new()

@export var deactivate_transition : Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var deactivate_ease : Tween.EaseType = Tween.EaseType.EASE_IN

## The true Audio Effect
var true_params: AudioEffect = AudioEffectLowPassFilter.new()

func _init(
	_active_params: AudioEffect = AudioEffectLowPassFilter.new(),
	_inactive_params: AudioEffect = AudioEffectLowPassFilter.new(),
) -> void:
	active_params = _active_params
	inactive_params = _inactive_params
	true_params = _inactive_params.duplicate(true)
