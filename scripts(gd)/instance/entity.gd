class_name EntityInstance
extends Node
## Instance Script that controls a single entity.

@export_group("Movement")
var body: EntityBodyComponent
@export var move_speed: float = 7.5
@export var move_accel: float = 0.25
