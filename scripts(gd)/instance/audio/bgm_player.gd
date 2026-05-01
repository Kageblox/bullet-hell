class_name ModifiedAudioStreamPlayerInstance
extends AudioStreamPlayer
## Modified Version of the base AudioStreamPlayer, that allows for fading.
##
## Meant specifically for Music tracks.

#region Variables

var _audio_data: AudioDataResource
@export var audio_data: AudioDataResource: 
	get:
		return _audio_data
	set(value):
		_audio_data = value
		stream = audio_data.stream
		pitch_scale = audio_data.pitch_scale
		bus = audio_data.bus

var _from_vol = null
var _to_vol = null

var will_be_playing = false
var _timer: Timer

#endregion

#region Functions

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.autostart = false
	_timer.ignore_time_scale = true
	_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	_timer.timeout.connect(
		func():
			volume_db = _to_vol
			if not will_be_playing:
				stop()
	)
	add_child(_timer)

func _process(_delta: float) -> void:
	if _timer.time_left > 0:
		volume_db = lerp(_to_vol, _from_vol, (_timer.time_left/ _timer.wait_time))

func play_with_fade(fade_duration : float = 1.0) -> void:
	if not will_be_playing:
		will_be_playing = true
		
		_from_vol = audio_data.inactive_volume_db
		_to_vol =  audio_data.active_volume_db
		
		play()
		
		_timer.start(fade_duration)

func stop_with_fade(fade_duration : float = 1.0) -> void:
	if will_be_playing:
		will_be_playing = false
		
		_from_vol = audio_data.active_volume_db
		_to_vol =  audio_data.inactive_volume_db
		
		_timer.start(fade_duration)

#endregion
