class_name SpawnPoolResource
extends Resource
## Resource Script that defines an Object Pool.

#region Variables

@export var entity_instance: PackedScene ## The entity that the pool manages.
@export var initial_count: int = 10  ## The initial number of objects pooled at the start.

#endregion
