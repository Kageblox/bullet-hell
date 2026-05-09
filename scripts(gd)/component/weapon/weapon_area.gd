class_name WeaponAreaComponent
extends Area3D
## Component Script that gives a weapon an area component.

#region Variables

## The weapon this component is attached to.
var weapon: WeaponInstance

#endregion

#region Functions

func _enter_tree() -> void:
	weapon = GeneralUtility.get_nearest_parent_of_class(self, WeaponInstance)


func get_entities_in_area() -> Array[EntityInstance]:
	var result: Array[EntityInstance] = []
	for hitbox in get_overlapping_areas():
		if hitbox is EntityHitboxComponent:
			result.append(hitbox.entity)
	return result

#endregion
