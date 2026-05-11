class_name PauseMenu
extends MenuInstance
## Menu that pops up when pausing the game.

#region Functions

func open(_params: Array[Variant] = [])-> void:
	AudioManager.activate_bus_effect("Music", "LowPassFilter")
	GameManager.pause_active = true
	super()


func close() -> void:
	AudioManager.deactivate_bus_effect("Music", "LowPassFilter")
	super()
	on_close_end.connect(
		func():
			GameManager.pause_active = false
	)


func _on_settings_button_pressed() -> void:
	MenuManager.open_settings_menu()
	

func _on_restart_button_pressed() -> void:
	MenuManager.open_question_menu(
		"Restart Game?",
		{
			"Yes":
				func():
					SceneManager.goto_scene("res://scene(tscn)/scenes/game.tscn"),
			"No":
				func():
					pass,
		},
	)


func _on_main_menu_button_pressed() -> void:
	MenuManager.open_question_menu(
		"Return to Main Menu?",
		{
			"Yes":
				func():
					SceneManager.goto_scene("res://scene(tscn)/scenes/main_menu_scene.tscn"),
			"No":
				func():
					pass,
		},
	)


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


func _on_resume_button_pressed() -> void:
	close()
	
#endregion
