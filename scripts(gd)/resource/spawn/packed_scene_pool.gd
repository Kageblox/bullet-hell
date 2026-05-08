class_name PackedScenePoolResource
extends Resource
## Resource Script that defines a Pool of a single Packed Scene type.

#region Variables

@export var packed_scene: PackedScene = null ## The Packed Scene that this Pool manages.
@export var initial_count: int = 1  ## The initial number of Packed Scenes pooled at the start.

func _init(
	_packed_scene: PackedScene = null,
	_initial_count: int = 1,
) -> void:
	packed_scene = _packed_scene
	initial_count = _initial_count

#endregion
