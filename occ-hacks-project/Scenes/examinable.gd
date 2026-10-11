@tool
extends Area2D
class_name examinable

## Emitted whenever the player clicks this object. `state_index` is the
## tooltip state it just switched to. Hook a switch/puzzle to this later.
signal examined(state_index: int)

## Single-state text. Used when `tooltip_states` is left empty.
@export_multiline var tooltip_text: String = ""
## Multi-state text. Fill this (2+ entries) to make the object cycle
## tooltips on each click. Takes priority over tooltip_text when non-empty.
@export var tooltip_states: Array[String] = []
## Extra nudge applied after the tooltip is placed above the sprite.
## Y is the gap above the art; more negative = higher.
@export var popup_offset: Vector2 = Vector2(0, -12)
@export var padding: Vector2 = Vector2(8, 8)
@export var target_sprite: Sprite2D

var _state: int = 0

func _ready() -> void:
	_fit_to_sprite()
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	_refresh_text()
	$Tooltip.visible = false

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_fit_to_sprite()

# --- Tooltip text / state ---------------------------------------------------

func _states() -> Array:
	if tooltip_states.size() > 0:
		return tooltip_states
	return [tooltip_text]

func _current_text() -> String:
	var s := _states()
	if s.is_empty():
		return ""
	return str(s[clamp(_state, 0, s.size() - 1)])

func _refresh_text() -> void:
	var label := get_node_or_null("Tooltip/Label") as Label
	if label:
		label.text = _current_text()

# --- Click to cycle state ---------------------------------------------------

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance_state()

func _advance_state() -> void:
	var count: int = max(_states().size(), 1)
	_state = (_state + 1) % count
	_refresh_text()
	if $Tooltip.visible:
		_position_tooltip()   # size may have changed with the new text
	examined.emit(_state)

# --- Show / hide / place ----------------------------------------------------

func _on_mouse_entered() -> void:
	_show_tooltip()

func _on_mouse_exited() -> void:
	$Tooltip.visible = false

func _show_tooltip() -> void:
	var tip: Control = $Tooltip
	_refresh_text()
	tip.visible = true
	_position_tooltip()
	# pop-in: fade + rise
	var end_pos: Vector2 = tip.position
	tip.modulate.a = 0.0
	tip.position = end_pos + Vector2(0, 8)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(tip, "modulate:a", 1.0, 0.12)
	tw.tween_property(tip, "position", end_pos, 0.12)

func _position_tooltip() -> void:
	var tip: Control = $Tooltip
	tip.reset_size()   # shrink to fit current text
	var sprite := _get_sprite()
	var center_x: float = 0.0
	var top_y: float = 0.0
	if sprite and sprite.texture:
		var r: Rect2 = sprite.get_rect()
		center_x = sprite.position.x + (r.position.x + r.size.x * 0.5) * sprite.scale.x
		top_y = sprite.position.y + r.position.y * sprite.scale.y
	# centered horizontally, sitting just above the top of the art
	tip.position = Vector2(center_x - tip.size.x * 0.5, top_y - tip.size.y) + popup_offset

# --- Collision auto-fit -----------------------------------------------------

func _fit_to_sprite() -> void:
	var sprite := _get_sprite()
	var cs := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if sprite == null or sprite.texture == null or cs == null:
		return
	if not (cs.shape is RectangleShape2D):
		cs.shape = RectangleShape2D.new()
	var r: Rect2 = sprite.get_rect()
	(cs.shape as RectangleShape2D).size = r.size * sprite.scale + padding
	cs.position = sprite.position + (r.position + r.size * 0.5) * sprite.scale

func _get_sprite() -> Sprite2D:
	if target_sprite:
		return target_sprite
	for child in get_children():
		if child is Sprite2D:
			return child
	return null
