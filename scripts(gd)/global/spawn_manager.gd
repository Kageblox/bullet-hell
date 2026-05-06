class_name SpawnManagerGlobal
extends Node
## Global Script in charge of spawning things
##
## Manages spawnable things via object pooling.

const unused_position: Vector3 = Vector3(1000,1000,1000)

var all_pools: SpawnPoolDictionary = preload("res://resource(tres)/all_pools.tres") as SpawnPoolDictionary

func _ready() -> void:
	initialize_pools()

func initialize_pools() -> void:
	for child in get_children():
		child.queue_free()
	
	for pool_name in all_pools.spawn_pool_dictionary.keys():
		var pool_value = all_pools.spawn_pool_dictionary[pool_name]
		
		var new_pool = Node.new()
		new_pool.name = pool_name
		add_child(new_pool)
		
		var new_pool_unused = Node.new()
		new_pool_unused.name = "unused"
		new_pool.add_child(new_pool_unused)
		
		var new_pool_used = Node.new()
		new_pool_used.name = "used"
		new_pool.add_child(new_pool_used)
		
		for i in pool_value.initial_count:
			var new_instance = pool_value.entity_instance.instantiate()
			if new_instance is EntityInstance:
				if new_instance.spawn_component:
					new_instance.spawn_component.pool_name = pool_name
					new_instance.spawn_component.set_unused()
					
			new_pool_unused.add_child(new_instance)
			
			new_instance.global_position = unused_position
			
			
func get_unused_instances(pool_name: String, count: int = 1) -> Array[Variant]:
	
	var to_be_used = []
	var unused_pool = get_node(pool_name + "/unused")
	var used_pool = get_node(pool_name + "/used")

	if count > unused_pool.get_child_count():
		var entity_instance = all_pools.spawn_pool_dictionary[pool_name].entity_instance
		while unused_pool.get_child_count() < count:
			var new_instance = entity_instance.instantiate()
			unused_pool.add_child(new_instance)

	for i in count:
		var to_be_used_instance = unused_pool.get_child(0)
		to_be_used_instance.reparent(used_pool)
		to_be_used.append(to_be_used_instance)
		if to_be_used_instance is EntityInstance:
			if to_be_used_instance.spawn_component:
				to_be_used_instance.spawn_component.pool_name = pool_name
				to_be_used_instance.spawn_component.set_used()

	return to_be_used
