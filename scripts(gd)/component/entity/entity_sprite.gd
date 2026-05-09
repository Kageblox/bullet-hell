class_name EntitySpriteComponent
extends AnimatedSprite3D
## Component Script that gives an Entity a Sprite

#region Signals

signal on_animation_override_end(_animation_override: String) ## Emitted upon the end of the animation override.

#endregion

#region Variables

const flip_offset = -0.1;

enum SpriteMode {
	HORIZONTAL_FLIP_RIGIDBODY, # Flips horizontally to match the Entity's Rigid Body's Velocity.
	FOLLOW_AIM, # Follows Entity's Aim Component's global transform.
	INACTIVE # Does nothing
	}

@export var sprite_flipped: bool = false ## Whether the sprite is flipped by default.
	
var current_sprite_mode = SpriteMode.INACTIVE
var animation_override: String = "" ## The current non-looping animation.
var current_animation: String = "" ## The current looping animation.

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
			
	if animation_override != "":
		if animation != animation_override:
			play(animation_override)
		elif !is_playing():
			on_animation_override_end.emit(animation_override)
			animation_override = ""
	else:
		if current_animation != "" and animation != current_animation:
			play(current_animation)

#endregion
