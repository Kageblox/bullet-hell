class_name PlayerAimComponent
extends EntityAimComponent
## Component Script that controls Player Aiming.

#region Variables

@export_group("Other Components")
@export var cam: Camera3DModified

@export_group("Advanced")
@export var ray_length: float = 1000
@export_flags_2d_physics var ray_collide_layers: int

var player: PlayerInstance

var distance_curve: Curve = preload("res://resource(tres)/curves/player_aim_distance_curve.tres") as Curve

#endregion

#region Functions

func _enter_tree() -> void:
	super()
	player = get_node("../../") as PlayerInstance
	
func _process(delta: float) -> void:
	super(delta)
	
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end, ray_collide_layers)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	var raw_aim_vector = result["position"] - global_position # The vector that points from the player to the aimed position.
	var clamped_aim_vector = raw_aim_vector.limit_length(player.aim_max_distance)
	aim_position = clamped_aim_vector + global_position
	
	var aim_lerp = distance_curve.sample(clamped_aim_vector.length()/player.aim_max_distance)
	cam.target_position = lerp(global_position, aim_position, aim_lerp) + Vector3(0, player.aim_height, 0)

#endregion
