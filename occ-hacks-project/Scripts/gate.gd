@tool
extends AnimatedSprite2D
class_name Gate
## Attach to your "Graveyard Gate" AnimatedSprite2D.
## Closed: shows the closed animation, tinted red, and a barrier blocks the player.
## Call open() (from the lockbox's `solved` signal) to show the open animation,
## tint green, and drop the barrier so the player can walk through.

@export var is_open: bool = false
@export var closed_anim: StringName = &"Closed Gate"
@export var open_anim: StringName = &"Open Gate"

@export_group("Tint")
@export var use_tint: bool = true
@export var locked_tint: Color = Color(1.0, 0.3, 0.3)   # red
@export var open_tint: Color = Color(0.4, 1.0, 0.4)     # green

@export_group("Barrier")
## A StaticBody2D (with a CollisionShape2D) that blocks the player while closed.
@export var barrier: Node2D

var _player_ref: CharacterBody2D = null

func _ready() -> void:
	_apply()
	if not Engine.is_editor_hint():
		await get_tree().process_frame
		_player_ref = get_tree().get_first_node_in_group("player") as CharacterBody2D

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or is_open or not barrier or not _player_ref:
		return
	for i in _player_ref.get_slide_collision_count():
		var col := _player_ref.get_slide_collision(i)
		if col.get_collider() == barrier:
			SFX.play_door_locked()
			break

func _set(property: StringName, value: Variant) -> bool:
	if Engine.is_editor_hint() and property == &"is_open":
		is_open = value
		_apply()
		return true
	return false

func open() -> void:
	is_open = true
	_apply()
	if not Engine.is_editor_hint():
		SFX.play_door_open()

func close() -> void:
	is_open = false
	_apply()


func _apply() -> void:
	var a: StringName = open_anim if is_open else closed_anim
	if sprite_frames and sprite_frames.has_animation(a):
		animation = a
		frame = 0
	self_modulate = (open_tint if is_open else locked_tint) if use_tint else Color.WHITE
	if barrier:
		for c in barrier.get_children():
			if c is CollisionShape2D or c is CollisionPolygon2D:
				c.set_deferred("disabled", is_open)   # open -> no block
