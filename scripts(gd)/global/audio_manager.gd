class_name AudioManagerGlobal
extends Node
## Global Script that manages all Audio

#region Variables

var all_audio: AudioDataCollectionResource = preload("res://resource(tres)/audio/all_audio.tres")
var audio_effects: AudioEffectCollectionResource = preload("res://resource(tres)/audio/audio_effects.tres")

var _master: float = 0.5
var master: float:
	get:
		return _master
	set(value):
		_master = value
		AudioServer.set_bus_volume_linear(0, value)

var _music: float = 0.5
var music: float:
	get:
		return _music
	set(value):
		_music = value
		AudioServer.set_bus_volume_linear(1, value)

var _sfx: float = 0.5
var sfx: float:
	get:
		return _sfx
	set(value):
		_sfx = value
		AudioServer.set_bus_volume_linear(2, value)

#endregion

#region Functions

func _enter_tree() -> void:
	var current_settings = SaveLoadUtility.load_settings()
	master = current_settings.audio_master
	music = current_settings.audio_music
	sfx = current_settings.audio_sfx
	
	for bus_index in AudioServer.bus_count:
		var bus_name = AudioServer.get_bus_name(bus_index)
		
		var bus_holder = Node.new()
		bus_holder.name = bus_name
		add_child(bus_holder)

		var players_holder = Node.new()
		players_holder.name = "Players"
		bus_holder.add_child(players_holder)

		var effects_holder = Node.new()
		effects_holder.name = "Effects"
		bus_holder.add_child(effects_holder)

	for audio_name in all_audio.audio_data_collection.keys():
		var audio_data = all_audio.audio_data_collection[audio_name]
		var audio_player = ModifiedAudioStreamPlayerInstance.new()
		audio_player.name = audio_name
		audio_player.audio_data = audio_data
		get_node(audio_data.bus + "/Players").add_child(audio_player)

	for effect_name in audio_effects.master_effects.keys():
		var effect = audio_effects.master_effects[effect_name]
		var effect_controller = AudioEffectControllerInstance.new()
		effect_controller.effect = effect
		effect_controller.name = effect_name
		get_node("Master/Effects").add_child(effect_controller)
		AudioServer.add_bus_effect(0, effect.true_params)
		AudioServer.set_bus_effect_enabled(0, AudioServer.get_bus_effect_count(0) - 1, false)

	for effect_name in audio_effects.music_effects.keys():
		var effect = audio_effects.music_effects[effect_name]
		var effect_controller = AudioEffectControllerInstance.new()
		effect_controller.effect = effect
		effect_controller.name = effect_name
		get_node("Music/Effects").add_child(effect_controller)
		AudioServer.add_bus_effect(1, effect.true_params)
		AudioServer.set_bus_effect_enabled(1, AudioServer.get_bus_effect_count(1) - 1, false)

	for effect_name in audio_effects.sfx_effects.keys():
		var effect = audio_effects.sfx_effects[effect_name]
		var effect_controller = AudioEffectControllerInstance.new()
		effect_controller.effect = effect
		effect_controller.name = effect_name
		get_node("SFX/Effects").add_child(effect_controller)
		AudioServer.add_bus_effect(2, effect.true_params)
		AudioServer.set_bus_effect_enabled(2, AudioServer.get_bus_effect_count(2) - 1, false)

func play_music(music_name: String, fade_duration: float = 1.0) -> void:
	var music_player = get_node("Music/Players/" + music_name) as ModifiedAudioStreamPlayerInstance
	music_player.play_with_fade(fade_duration)


func stop_music(music_name: String, fade_duration: float = 1.0) -> void:
	var music_player = get_node("Music/Players/" + music_name) as ModifiedAudioStreamPlayerInstance
	music_player.stop_with_fade(fade_duration)


func stop_all_bgm(fade_duration: float = 1.0) -> void:
	for music_player in get_node("Music/Players").get_children():
		if music_player is ModifiedAudioStreamPlayerInstance:
			music_player.stop_with_fade(fade_duration)


func play_sfx(sfx_name: String) -> void:
	var sfx_player = get_node("SFX/Players/" + sfx_name) as ModifiedAudioStreamPlayerInstance
	sfx_player.play()


func activate_bus_effect(bus_name: String, effect_name: String, fade_duration: float = 1.0) -> void:
	var effect_controller = get_node(bus_name + "/Effects/" + effect_name) as AudioEffectControllerInstance
	effect_controller.activate(fade_duration)


func deactivate_bus_effect(bus_name: String, effect_name: String, fade_duration: float = 1.0) -> void:
	var effect_controller = get_node(bus_name + "/Effects/" + effect_name) as AudioEffectControllerInstance
	effect_controller.deactivate(fade_duration)

#endregion
