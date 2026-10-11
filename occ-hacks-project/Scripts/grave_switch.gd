@tool
extends Area2D
class_name GraveSwitch
## A grave switch.
##   Art (3 states) shows which option is active: ivy / top / bottom.
##   Tooltips show the full PHRASES (phrase_a on top, phrase_b on bottom).
##   Only the single WORD (word_a / word_b) is sent to the lockbox.
##
## State 0 = ivy (uncleared, no word). First click/E clears it -> state 1 (top).
## Further clicks/E toggle 1 <-> 2. Tooltips appear on hover once uncleared.
## Click the stone, or press Interact while hovering it or standing on it.

signal switched(slot_index: int, word: String)

## Position in the 6th grave's phrase (0-based).
@export var slot_index: int = 0

@export_group("Words (sent to the lockbox)")
@export var word_a: String = ""       # the TOP option's word, e.g. "NO"
@export var word_b: String = ""       # the BOTTOM option's word

@export_group("Phrases (shown in tooltips)")
@export_multiline var phrase_a: String = ""   # top tooltip
@export_multiline var phrase_b: String = ""   # bottom tooltip

@export_group("Textures (art states)")
@export var tex_ivy: Texture2D        # state 0
@export var tex_top: Texture2D        # state 1
@export var tex_bottom: Texture2D     # state 2

@export_group("Layout")
@export var gap: float = 10.0
@export var padding: Vector2 = Vector2(8, 8)
@export var tip_max_width: float = 280.0

var _state: int = 0           # 0 ivy, 1 top (A), 2 bottom (B)
var _hovered: bool = false
var _player_in_range: bool = false
var _style_active: StyleBoxFlat
var _style_dim: StyleBoxFlat

func _ready() -> void:
	_build_styles()
	_setup_labels()
	_set_tip_text()
	_apply_state()
	_apply_highlight()
	_hide_tips()
	if Engine.is_editor_hint():
		return
	add_to_group("grave_switch")
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func current_word() -> String:
	if _state == 1:
		return word_a
	elif _state == 2:
		return word_b
	return ""

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_set_tip_text()
		_apply_state()
		_apply_highlight()

# --- input ------------------------------------------------------------------

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		return   # mouse clicks are handled by _on_input_event (avoids double-toggle)
	if (_hovered or _player_in_range) and event.is_action_pressed("Interact"):
		_toggle()

func _toggle() -> void:
	if _state == 0:
		_state = 1                 # knock the ivy away, pick the top option
	else:
		_state = 3 - _state        # toggle 1 <-> 2
	_apply_state()
	_apply_highlight()
	if _hovered:
		_show_tips()
	switched.emit(slot_index, current_word())

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false

func _on_mouse_entered() -> void:
	_hovered = true
	if _state != 0:
		_show_tips()

func _on_mouse_exited() -> void:
	_hovered = false
	_hide_tips()

# --- art state --------------------------------------------------------------

func _apply_state() -> void:
	var anim := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if anim:
		anim.frame = _state
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
	if tex:
		spr.texture = tex
	_fit_sprite(spr)

# --- tooltips ---------------------------------------------------------------

func _setup_labels() -> void:
	for p in ["TopTip/Label", "BottomTip/Label"]:
		var l := get_node_or_null(p) as Label
		if l:
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.custom_minimum_size = Vector2(tip_max_width, 0)

func _set_tip_text() -> void:
	var a := get_node_or_null("TopTip/Label") as Label
	var b := get_node_or_null("BottomTip/Label") as Label
	if a:
		a.text = phrase_a
	if b:
		b.text = phrase_b

func _show_tips() -> void:
	var top := get_node_or_null("TopTip") as Control
	var bottom := get_node_or_null("BottomTip") as Control
	if top:
		top.visible = true
	if bottom:
		bottom.visible = true
	_apply_highlight()
	_position_tips()

func _hide_tips() -> void:
	var top := get_node_or_null("TopTip") as Control
	var bottom := get_node_or_null("BottomTip") as Control
	if top:
		top.visible = false
	if bottom:
		bottom.visible = false

func _apply_highlight() -> void:
	var top := get_node_or_null("TopTip") as PanelContainer
	var bottom := get_node_or_null("BottomTip") as PanelContainer
	if top:
		_style_panel(top, _state == 1)
	if bottom:
		_style_panel(bottom, _state == 2)

func _style_panel(p: PanelContainer, active: bool) -> void:
	p.add_theme_stylebox_override("panel", _style_active if active else _style_dim)
	p.modulate = Color(1, 1, 1, 1) if active else Color(1, 1, 1, 0.55)
	var l := p.get_node_or_null("Label") as Label
	if l:
		l.add_theme_color_override("font_color", Color(1, 0.92, 0.55) if active else Color(0.82, 0.82, 0.86))

func _build_styles() -> void:
	_style_dim = StyleBoxFlat.new()
	_style_dim.bg_color = Color(0.09, 0.09, 0.13, 0.92)
	_style_dim.set_corner_radius_all(6)
	_style_dim.set_content_margin_all(10)
	_style_dim.border_color = Color(0.5, 0.5, 0.55, 0.4)
	_style_dim.set_border_width_all(1)

	_style_active = StyleBoxFlat.new()
	_style_active.bg_color = Color(0.15, 0.13, 0.07, 0.96)
	_style_active.set_corner_radius_all(6)
	_style_active.set_content_margin_all(10)
	_style_active.border_color = Color(1.0, 0.82, 0.35, 0.95)
	_style_active.set_border_width_all(2)
	_style_active.shadow_color = Color(0, 0, 0, 0.4)
	_style_active.shadow_size = 5

func _position_tips() -> void:
	var sprite := _get_sprite()
	if sprite == null or sprite.texture == null:
		return
	var r: Rect2 = sprite.get_rect()
	var cx: float = sprite.position.x + (r.position.x + r.size.x * 0.5) * sprite.scale.x
	var top_y: float = sprite.position.y + r.position.y * sprite.scale.y
	var bot_y: float = sprite.position.y + (r.position.y + r.size.y) * sprite.scale.y
	var top := get_node_or_null("TopTip") as Control
	var bottom := get_node_or_null("BottomTip") as Control
	if top:
		var sz_t := top.get_combined_minimum_size()
		top.size = sz_t
		top.position = Vector2(cx - sz_t.x * 0.5, top_y - sz_t.y - gap)
	if bottom:
		var sz_b := bottom.get_combined_minimum_size()
		bottom.size = sz_b
		bottom.position = Vector2(cx - sz_b.x * 0.5, bot_y + gap)

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

func _get_sprite() -> Sprite2D:
	var s := get_node_or_null("Sprite2D") as Sprite2D
	if s:
		return s
	for child in get_children():
		if child is Sprite2D and child.name != "Ivy":
			return child
	return null
