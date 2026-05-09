class_name PackedScenePoolDictionaryResource
extends Resource
## Resource Script that defines a dictionary of PackedScenePoolResource.

#region Variables

@export var packed_scene_pool_dictionary: Dictionary[String, PackedScenePoolResource] = {}

#endregion

#region Functions

func _init(
	_packed_scene_pool_dictionary: Dictionary[String, PackedScenePoolResource] = {},
) -> void:
	packed_scene_pool_dictionary = _packed_scene_pool_dictionary

#endregion
