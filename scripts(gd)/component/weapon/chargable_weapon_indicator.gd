class_name ChargableWeaponIndicatorComponent
extends MeshInstance3D
## Component Script that shows an indicator when the attached weapon is charging.

#region Variables

var indicator_shader_material: ShaderMaterial

## The chargable weapon this component is attached to.
var chargable_weapon: ChargableWeapon

#endregion

#region Functions

func _enter_tree() -> void:
	chargable_weapon = GeneralUtility.get_nearest_parent_of_class(self, ChargableWeapon)

func _ready() -> void:
	indicator_shader_material = material_override.duplicate() as ShaderMaterial
	material_override = indicator_shader_material
	
	chargable_weapon.on_charge_start.connect(
		func():
			visible = true
	)
	
	chargable_weapon.while_charging.connect(
		func(current_charge: float):
			indicator_shader_material.set_shader_parameter("charge", current_charge)
	)
	
	chargable_weapon.on_charge_end.connect(
		func():
			visible = false
	)


#endregion
