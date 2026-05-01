class_name MainMenuScene
extends SceneInstance
## The Main Menu Scene's Scene Instance.

#region Functions

func _ready() -> void:
	AudioManager.play_music("music")

func _on_start_game_button_pressed() -> void:
	SceneManager.goto_scene("res://scene(tscn)/scenes/another_scene.tscn")


func _on_settings_button_pressed() -> void:
	MenuManager.open_settings_menu()


func _on_quit_game_button_pressed() -> void:
	MenuManager.open_question_menu(
		"Quit Game?",
		{
			"Yes":
				func():
					get_tree().quit(),
			"No":
				func():
					pass,
		},
	)

#endregion
