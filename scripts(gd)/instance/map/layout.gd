class_name MapLayout
extends Node3D

# Uses component/map/gen.gd

@export var map_width: int = 100
@export var map_height: int = 100
@export var starting_width: int = 15
@export var starting_height: int = 15
@export var steps: int = 2000
@export var min_size: int = 6
@export var max_size: int = 22
@export var variance: int = 2

func _ready() -> void:
	var layout := Gen.Generator.Run(
		map_width,
		map_height,
		starting_width,
		starting_height,
		steps,
		min_size,
		max_size,
		variance
	)
	layout.Print()
