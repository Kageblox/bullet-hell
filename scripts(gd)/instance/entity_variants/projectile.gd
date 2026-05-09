class_name ProjectileEntity
extends EntityInstance
## Instance Script that defines a projectile.

#region Variables

@export_group("Other Components")
@export var area_component: EntityAreaComponent
@export var hitbox_component: EntityHitboxComponent

@export_group("Variables")
@export var speed: float = 1.0
@export var lifetime: float = 1.0
@export var damage: float = 10.0

var _lifetime_timer: float = 0
var moving = true

#endregion

#region Functions

func _ready() -> void:
	
	# When the Projectile hits a hitbox
	area_component.area_entered.connect(
		func(area: Area3D):
			if area is EntityHitboxComponent:
				area.entity.damage_entity(damage, area.global_position - area_component.global_position)
				entity_die()
	)
	
	# When the Projectile hits a collider
	area_component.body_entered.connect(
		func(body: Node3D):
			entity_die()
	)
	
	sprite.on_animation_override_end.connect(
		func(_animation_override: String):
			if _animation_override == "bullet_explosion":
				on_death.emit()
				set_unused()
	)


func _process(delta: float) -> void:
	super(delta)
	if _lifetime_timer > 0:
		_lifetime_timer = _lifetime_timer - delta
	else:
		entity_die()


func set_used() -> void:
	super()
	_lifetime_timer = lifetime
	
	area_component.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	hitbox_component.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	
	moving = true
	dying = false
	
	sprite.animation = "bullet_normal"

func entity_die() -> void:
	if not dying:
		dying = true
		area_component.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		hitbox_component.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)

		moving = false

		sprite.animation_override = "bullet_explosion"
	
func _physics_process(delta: float) -> void:
	if moving:
		var forward_vector = (-global_basis.z).normalized()
		global_position = global_position + forward_vector * speed * delta

#endregion
