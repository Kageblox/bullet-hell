class_name EntitySpriteComponent
extends AnimatedSprite3D
## Component Script that gives an Entity a Sprite

#region Variables

const flip_offset = -0.1;

enum SpriteMode {
	HORIZONTAL_FLIP_RIGIDBODY, # Flips horizontally to match the Entity's Rigid Body's Velocity.
	FOLLOW_AIM, # Follows Entity's Aim Component's global transform.
	INACTIVE # Does nothing
	}

@export var sprite_flipped: bool = false ## Whether the sprite is flipped by default.
	
var current_sprite_mode = SpriteMode.INACTIVE
	
var entity: EntityInstance ## The entity this component is attached to.

#endregion

#region Functions

func _enter_tree() -> void:
	entity = GeneralUtility.get_nearest_parent_of_class(self, EntityInstance)
	

func _process(delta: float) -> void:
	match(current_sprite_mode):
		SpriteMode.HORIZONTAL_FLIP_RIGIDBODY:
			if entity.rigid_body_component != null:
				var rigid_body_horizontal_velocity = entity.rigid_body_component.linear_velocity.dot(global_transform.basis.x)
				if sprite_flipped:
					flip_h = rigid_body_horizontal_velocity > flip_offset
				else:
					flip_h = not rigid_body_horizontal_velocity > flip_offset
				
		SpriteMode.FOLLOW_AIM:
			if entity.aim_component != null:
				pass
		SpriteMode.INACTIVE:
			pass

#endregion
