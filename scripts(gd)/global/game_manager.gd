class_name GameManagerGlobal
extends Node
## Global Script that manages gameplay.

var pause_active: bool = false
var hitstop_active: bool = false

var player: PlayerEntity

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(delta: float) -> void:
	get_tree().paused = pause_active or hitstop_active
