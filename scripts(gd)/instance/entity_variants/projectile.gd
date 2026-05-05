class_name ProjectileInstance
extends EntityInstance
## Instance Script that defines a projectile.

#region Variables

@export_group("Other Components")
@export var area_component: EntityAreaComponent
@export var spawn_component: EntitySpawnComponent
@export var timer: Timer

@export_group("Variables")
@export var speed: float = 1.0
@export var lifetime: float = 1.0

#endregion

#region Functions

func _ready() -> void:
	
	area_component.body_entered.connect(
		func(body: Node3D):
			spawn_component.set_unused()
	)
	
	area_component.area_entered.connect(
		func(area: Area3D):
			spawn_component.set_unused()
	)
			
	spawn_component.on_set_used.connect(
		func():
			timer.start(lifetime)
			)

	
	timer.timeout.connect(
		func():
			spawn_component.set_unused()
			)
	

func _physics_process(delta: float) -> void:
	var forward_vector = -global_basis.z
	global_position = global_position + forward_vector * speed * delta

#endregion
