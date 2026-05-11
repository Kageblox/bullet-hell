class_name EntityInstance
extends Node3D
## Instance Script that controls a single entity.

#region Signals

signal on_set_used()
signal on_set_unused()

signal on_damaged(value: float) ## Emitted when the Entity takes damage.
signal on_healed(value: float) ## Emitted when the Entity is healed.
signal on_health_changed(value: float) ## Emitted whenever the Entity's HP changes
signal on_death() ## Emitted when the Entity dies.

#endregion

#region Variables

const hit_modulate_color = Color(1,0,0,0.5)
const hit_vibration_distance = 0.25
const hit_duration = 0.25

const invincible_color_lerp_frequency = 0.01
const invincible_color_1 = Color(1,1,1,0.25)
const invincible_color_2 = Color(1,1,1,0.75)

@export_group("Other Components")
@export var sprite: EntitySpriteComponent

@export_group("Stats")
@export var pool_name: String ## The name of the pool this Entity belongs to
var _health: float = 100
@export var health: float:
	get:
		return _health
	set(value):
		if not invincible:
			_health = clamp(value, 0, max_health)
			on_health_changed.emit(value)
		
@export var max_health: float = 100
@export var invincible: bool = false

var invincible_modulate_debounce: bool = false
var ongoing_hit_modulate_tween: Tween
var invincibility_timer: float = -1
var dying = false
var _sprite_initial_position: Vector3 = Vector3.ZERO
var _sprite_initial_captured: bool = false

#endregion

#region Functions

func _process(delta: float) -> void:
	if invincibility_timer > 0:
		invincibility_timer = invincibility_timer - delta
	else:
		invincibility_timer = -1
		invincible = false

	if invincible:
		invincible_modulate_debounce = false
		var invincible_lerp = remap(sin(Time.get_ticks_msec() * invincible_color_lerp_frequency), -1, 1, 0, 1)
		sprite.modulate = lerp(invincible_color_1, invincible_color_2, invincible_lerp)
	else:
		if not invincible_modulate_debounce:
			sprite.modulate = Color.WHITE
			invincible_modulate_debounce = true


func damage_entity(value: float, direction: Vector3) -> void:
	if not invincible:
		health = clamp(health - value, 0, max_health)

		if health == 0:
			entity_die()
			return

		if not _sprite_initial_captured:
			_sprite_initial_position = sprite.position
			_sprite_initial_captured = true

		if ongoing_hit_modulate_tween and ongoing_hit_modulate_tween.is_running():
			ongoing_hit_modulate_tween.kill()

		sprite.modulate = hit_modulate_color
		sprite.position = _sprite_initial_position + direction.normalized() * hit_vibration_distance
		ongoing_hit_modulate_tween = create_tween().set_parallel(true)
		ongoing_hit_modulate_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		ongoing_hit_modulate_tween.tween_property(sprite, "modulate", Color.WHITE, hit_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
		ongoing_hit_modulate_tween.tween_property(sprite, "position", _sprite_initial_position, hit_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)

		on_damaged.emit(value)


func heal_entity(value: float) -> void:
	health = clamp(health + value, 0, max_health)
	on_healed.emit(value)


func make_entity_invincible(duration: float = -1) -> void:
	invincible = true
	if duration > 0:
		invincibility_timer = duration


func entity_die() -> void:
	if not dying:
		dying = true
		on_death.emit()
		set_unused()


func set_used() -> void:
	dying = false
	invincible = false
	invincibility_timer = -1
	_health = max_health
	on_health_changed.emit(_health)
	on_set_used.emit()

	visible = true
	set_deferred("process_mode", Node.PROCESS_MODE_PAUSABLE)


func set_unused() -> void:
	on_set_unused.emit()
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	
	visible = false
	
	if pool_name.is_empty():
		return push_error("Entity has no valid pool name.")
	
	SpawnManager.return_to_pool(self, pool_name)

#endregion
