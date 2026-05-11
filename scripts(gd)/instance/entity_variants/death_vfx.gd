class_name DeathVFX
extends EntityInstance

#region Functions

func _ready() -> void:
	sprite.on_animation_override_end.connect(
		func(_animation_override: String):
			set_unused()
	)


func set_used() -> void:
	super()
	sprite.stop()
	sprite.animation_override = "death_vfx"
	sprite.play("death_vfx")
	
#endregion
