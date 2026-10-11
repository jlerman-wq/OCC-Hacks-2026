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

@export_group("Art (base grave + ivy overlays)")
@export var tex_base: Texture2D        # the grave headstone, always shown
@export var tex_top_ivy: Texture2D     # ivy over the TOP of the grave
@export var tex_bottom_ivy: Texture2D  # ivy over the BOTTOM of the grave

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
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr == null:
		return
	# Base grave headstone is always visible.
	if tex_base:
		spr.texture = tex_base
	# Ivy overlays. State 0 = both cover the grave; clearing the top option
	# (state 1) strips the TOP ivy, the bottom option (state 2) strips the BOTTOM.
	var top_ivy := get_node_or_null("TopIvy") as Sprite2D
	var bottom_ivy := get_node_or_null("BottomIvy") as Sprite2D
	if top_ivy:
		if tex_top_ivy:
			top_ivy.texture = tex_top_ivy
		_match_ivy_scale(top_ivy, spr)
		top_ivy.visible = (_state != 1)
	if bottom_ivy:
		if tex_bottom_ivy:
			bottom_ivy.texture = tex_bottom_ivy
		_match_ivy_scale(bottom_ivy, spr)
		bottom_ivy.visible = (_state != 2)
	_fit_sprite(spr)

# Scale an ivy overlay to the base grave's footprint, whatever the ivy art's
# source resolution (e.g. 3200px ivy sitting on a 770px grave). Enforced in
# code so a scene re-save can't drop it.
func _match_ivy_scale(ivy: Sprite2D, base: Sprite2D) -> void:
	if ivy.texture == null or base.texture == null:
		return
	var iw: float = float(ivy.texture.get_width())
	if iw <= 0.0:
		return
	ivy.scale = base.scale * (float(base.texture.get_width()) / iw)

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
	# Show only the active option's tooltip; the inactive one stays hidden.
	var top := get_node_or_null("TopTip") as Control
	var bottom := get_node_or_null("BottomTip") as Control
	if top:
		top.visible = (_state == 1)
	if bottom:
		bottom.visible = (_state == 2)
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

# Whichever option is currently active, or null in the ivy state.
func _active_tip() -> Control:
	if _state == 1:
		return get_node_or_null("TopTip") as Control
	elif _state == 2:
		return get_node_or_null("BottomTip") as Control
	return null

func _position_tips() -> void:
	var tip := _active_tip()
	if tip == null:
		return
	var sprite := _get_sprite()
	if sprite == null or sprite.texture == null:
		return
	var r: Rect2 = sprite.get_rect()
	var cx: float = sprite.position.x + (r.position.x + r.size.x * 0.5) * sprite.scale.x
	var top_y: float = sprite.position.y + r.position.y * sprite.scale.y
	# The grave is instanced at a small scale (e.g. 0.15), which would shrink
	# the tooltip text with it. Counter the node's global scale so the text
	# renders at a readable on-screen size regardless of the instance scale.
	var gs: Vector2 = global_scale
	tip.scale = Vector2(1.0 / gs.x, 1.0 / gs.y) if gs.x != 0.0 and gs.y != 0.0 else Vector2.ONE
	var sz := tip.get_combined_minimum_size()
	tip.size = sz
	var drawn: Vector2 = sz * tip.scale   # on-screen footprint in local units
	# Centered horizontally, sitting just above the top of the art.
	tip.position = Vector2(cx - drawn.x * 0.5, top_y - drawn.y - gap)

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
		if child is Sprite2D and child.name != "TopIvy" and child.name != "BottomIvy":
			return child
	return null
