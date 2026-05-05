class_name SpawnPoolDictionary
extends Resource
## Resource Script that defines a dictionary of Spawn Pools

@export var spawn_pool_dictionary: Dictionary[String, SpawnPoolResource] = {}

func _init(
	_spawn_pool_dictionary: Dictionary[String, SpawnPoolResource] = {},
) -> void:
	spawn_pool_dictionary = _spawn_pool_dictionary
