class_name WeaponSpawnerComponent
extends Node3D
## Component Script that spawns an Entity whenever the weapon is fired.

@export var pool_name: String # The Pool to pull the spawned Entity from.

## The weapon this component is attached to.
var weapon: WeaponInstance

func _enter_tree() -> void:
	weapon = GeneralUtility.get_nearest_parent_of_class(self, WeaponInstance)
	
	weapon.on_fired.connect(
		func():
			# Retrieve an object from the specified pool,
			var spawned = SpawnManager.get_from_pool(pool_name)
			
			# And update its global transform to match the spawner.
			spawned.global_transform = global_transform
			)
	
