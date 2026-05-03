class_name PlayerInstance
extends EntityInstance
## Instance Script that oversees the player.

func _process(delta: float) -> void:
	body.target_velocity = Vector3(
		InputManager.move_input.x * move_speed,
		 0.0,
		-InputManager.move_input.y * move_speed
	)
