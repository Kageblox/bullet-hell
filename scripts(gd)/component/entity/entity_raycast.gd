class_name EntityRaycastComponent
extends RayCast3D
## Component Script that allows an Entity to Raycast.

#region Variables

var entity: EntityInstance ## The entity this component is attached to.

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)
	
func get_obstacle(target_global_position: Vector3) -> Dictionary:
	
	target_position = to_local(target_global_position)
	
	force_raycast_update()

	var result = {
		"collider": null,
		"point": null,
		"normal": null,
	}
	if is_colliding():
		result["collider"] = get_collider()
		result["point"] = get_collision_point()
		result["normal"] = get_collision_normal()
	return result

#endregion
