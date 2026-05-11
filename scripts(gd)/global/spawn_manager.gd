class_name SpawnManagerGlobal
extends Node
## Global Script in charge of spawning things
##
## Manages spawnable things via object pooling.

const unused_position: Vector3 = Vector3(1000,1000,1000)

var all_pools: PackedScenePoolDictionaryResource = preload("res://resource(tres)/all_pools.tres") as PackedScenePoolDictionaryResource

func _ready() -> void:
	initialize_pools()
	
	SceneManager.on_scene_exit_end.connect(
		func(_scene: SceneInstance):
			set_all_unused()
			)


func initialize_pools() -> void:
	for child in get_children():
		child.queue_free()
	
	for pool_name in all_pools.packed_scene_pool_dictionary.keys():
		var pool_value = all_pools.packed_scene_pool_dictionary[pool_name]
		
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
			var new_instance = pool_value.packed_scene.instantiate()
			if new_instance is EntityInstance:
				new_instance.pool_name = pool_name
				new_instance.set_unused()
					
			new_pool_unused.add_child(new_instance)
			
			new_instance.global_position = unused_position
			
func set_all_unused() -> void:
	print("set all unused")
	for pool in get_children():
		for used in pool.get_node("used").get_children():
			used.set_unused()

func return_to_pool(pool_object: Node3D, pool_name: String) -> void:
	if all_pools.packed_scene_pool_dictionary.has(pool_name):
		pool_object.call_deferred("reparent", SpawnManager.get_node(pool_name + "/unused"))
		return
	else:
		if pool_object.scene_file_path:
			all_pools.packed_scene_pool_dictionary[pool_name] = PackedScenePoolResource.new(load(pool_object.scene_file_path))
		else:
			push_error("Unable to create new pool.")
			return
			
		var new_pool = Node.new()
		new_pool.name = pool_name
		add_child(new_pool)
		
		var new_pool_unused = Node.new()
		new_pool_unused.name = "unused"
		new_pool.add_child(new_pool_unused)
		
		var new_pool_used = Node.new()
		new_pool_used.name = "used"
		new_pool.add_child(new_pool_used)
		
		pool_object.call_deferred("reparent", new_pool_unused)

## Returns a pooled object from the specified pool.[br][br]
## Parameters:[br]
## - pool_name: The name of the pool the object is to be retrieved from.[br]
func get_from_pool(pool_name: String) -> Variant:
	if not all_pools.packed_scene_pool_dictionary.keys().has(pool_name):
		push_error("Pool of the given pool name does not exist.")

	var unused_pool = get_node(pool_name + "/unused")
	var used_pool = get_node(pool_name + "/used")
	var pooled_object = null

	if unused_pool.get_child_count() == 0:
		var packed_scene = all_pools.packed_scene_pool_dictionary[pool_name].packed_scene
		var new_instance = packed_scene.instantiate()
		unused_pool.add_child(new_instance)
		pooled_object = new_instance
	else:
		pooled_object = unused_pool.get_child(0)
	
	if pooled_object is EntityInstance:
		pooled_object.reparent(used_pool)
		pooled_object.set_used()

	return pooled_object
