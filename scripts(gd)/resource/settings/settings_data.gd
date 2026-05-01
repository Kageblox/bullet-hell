class_name SettingsDataResource
extends Resource
## Resource script that defines Settings Data.

@export_group("Audio")
@export_range(0,1) var audio_master: float = 0.5
@export_range(0,1) var audio_music: float = 0.5
@export_range(0,1) var audio_sfx: float = 0.5

func _init(
	_audio_master: float = 0.5,
	_audio_music: float = 0.5,
	_audio_sfx: float = 0.5,
) -> void:
	audio_master = _audio_master
	audio_music = _audio_music
	audio_sfx = _audio_sfx
