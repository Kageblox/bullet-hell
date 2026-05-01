class_name SettingsMenu
extends MenuInstance
## Menu used for modifying settings.

#region Variables

@export_group("Settings Menu")
@export var master_slider: HSlider
@export var master_slider_label: Label

@export var music_slider: HSlider
@export var music_slider_label: Label

@export var sfx_slider: HSlider
@export var sfx_slider_label: Label

#endregion

#region Functions

func open(_params: Array[Variant] = [])-> void:
	master_slider.value = AudioManager.master * 100
	music_slider.value = AudioManager.music * 100
	sfx_slider.value = AudioManager.sfx * 100
	super()

func _on_master_slider_value_changed(value: float) -> void:
	master_slider_label.text = str(int(value))


func _on_music_slider_value_changed(value: float) -> void:
	music_slider_label.text = str(int(value))
	

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_slider_label.text = str(int(value))


func _on_restore_default_button_pressed() -> void:
	MenuManager.open_question_menu(
		"Restore Default?",
		{
			"Yes":
				func():
					SaveLoadUtility.delete_settings()
					var new_settings_data = SaveLoadUtility.load_settings()
					AudioManager.master = new_settings_data.audio_master
					AudioManager.music = new_settings_data.audio_music
					AudioManager.sfx = new_settings_data.audio_sfx
					
					master_slider.value = AudioManager.master * 100
					music_slider.value = AudioManager.music * 100
					sfx_slider.value = AudioManager.sfx * 100,
			"No":
				func():
					pass,
		},
	)


func _on_save_and_return_button_pressed() -> void:
	MenuManager.open_question_menu(
		"Save and Return?",
		{
			"Yes":
				func():
					AudioManager.master = master_slider.value/100
					AudioManager.music = music_slider.value/100
					AudioManager.sfx = sfx_slider.value/100
					
					var new_settings_data = SettingsDataResource.new(
						master_slider.value/100,
						music_slider.value/100,
						sfx_slider.value/100,
					)
					SaveLoadUtility.save_resource(new_settings_data, "settings")
					close(),
			"No":
				func():
					pass,
		},
	)

#endregion
