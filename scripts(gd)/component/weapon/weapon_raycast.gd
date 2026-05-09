class_name WeaponRaycastComponent
extends RayCast3D
## Component Script that allows a weapon to raycast.

#region Variables

## The weapon this component is attached to.
var weapon: WeaponInstance

var target_global_positon: Vector3:
	get:
		return to_global(target_position)
		
#endregion

#region Functions

func _enter_tree() -> void:
	weapon = GeneralUtility.get_nearest_parent_of_class(self, WeaponInstance)


func get_hit() -> Dictionary:
	var result = {
		"entity" : null,
		"point": null,
		"normal": null,
	}
	if is_colliding():
		result["point"] = get_collision_point()
		result["normal"] = get_collision_normal()
		if get_collider() is EntityHitboxComponent:
			result["entity"] = get_collider().entity
	return result

#endregion
