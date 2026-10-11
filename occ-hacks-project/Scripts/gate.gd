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

func _ready() -> void:
	_apply()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply()

func open() -> void:
	is_open = true
	_apply()

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
