@tool
extends Area2D
class_name GraveSwitch
## A grave switch with three visual states:
##   state 0 = ivy (uncleared)      -> contributes no word
##   state 1 = top word selected    -> contributes word_a
##   state 2 = bottom word selected -> contributes word_b
## First click clears the ivy (0 -> 1); further clicks toggle 1 <-> 2.
##
## Visual is driven two ways (use whichever you set up):
##   A) three Texture2D slots below, swapped on a child "Sprite2D"
##   B) a child "AnimatedSprite2D" whose frames 0/1/2 are ivy/top/bottom
## If an AnimatedSprite2D child exists it takes priority.

signal switched(slot_index: int, word: String)

## Which position in the 6th grave's phrase this switch fills (0-based).
@export var slot_index: int = 0
## The actual word strings used by the lockbox (what the art shows).
@export var word_a: String = ""   # the TOP-highlighted option
@export var word_b: String = ""   # the BOTTOM-highlighted option

@export_group("Textures (Sprite2D mode)")
@export var tex_ivy: Texture2D        # state 0
@export var tex_top: Texture2D        # state 1
@export var tex_bottom: Texture2D     # state 2

@export_group("Fit")
@export var padding: Vector2 = Vector2(8, 8)

# 0 = ivy, 1 = word A (top), 2 = word B (bottom)
var _state: int = 0

func _ready() -> void:
	_apply_state()
	if Engine.is_editor_hint():
		return
	add_to_group("grave_switch")
	input_event.connect(_on_input_event)

func current_word() -> String:
	match _state:
		1: return word_a
		2: return word_b
		_: return ""          # state 0 contributes nothing yet

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply_state()        # live preview while editing

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _state == 0:
			_state = 1        # knock the ivy away, select the top word
		else:
			_state = 3 - _state  # toggle 1 <-> 2
		_apply_state()
		switched.emit(slot_index, current_word())

# --- visuals ----------------------------------------------------------------

func _apply_state() -> void:
	var anim := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if anim:
		anim.frame = _state           # frame 0 = ivy, 1 = top, 2 = bottom
		_fit_anim(anim)
		return
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr == null:
		return
	var tex: Texture2D = tex_ivy
	if _state == 1:
		tex = tex_top
	elif _state == 2:
		tex = tex_bottom
	if tex:                            # don't blank the sprite if a slot is empty
		spr.texture = tex
	_fit_sprite(spr)

# --- collision auto-fit -----------------------------------------------------

func _fit_sprite(spr: Sprite2D) -> void:
	var cs := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if spr == null or spr.texture == null or cs == null:
		return
	if not (cs.shape is RectangleShape2D):
		cs.shape = RectangleShape2D.new()
	var r: Rect2 = spr.get_rect()
	(cs.shape as RectangleShape2D).size = r.size * spr.scale + padding
	cs.position = spr.position + (r.position + r.size * 0.5) * spr.scale

func _fit_anim(anim: AnimatedSprite2D) -> void:
	var cs := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs == null or anim.sprite_frames == null:
		return
	var tex := anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
	if tex == null:
		return
	if not (cs.shape is RectangleShape2D):
		cs.shape = RectangleShape2D.new()
	(cs.shape as RectangleShape2D).size = tex.get_size() * anim.scale + padding
	cs.position = anim.position
