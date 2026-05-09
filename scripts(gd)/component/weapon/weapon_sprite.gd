class_name WeaponSpriteComponent
extends AnimatedSprite3D
## Component Script that gives a weapon an animated Sprite

#region Variables

## The weapon this component is attached to.
var weapon: WeaponInstance

#endregion

#region Functions

func _enter_tree() -> void:
	weapon = GeneralUtility.get_nearest_parent_of_class(self, WeaponInstance)

#endregion
