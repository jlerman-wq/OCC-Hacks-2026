@tool
extends Area2D
class_name Lockbox
## The 6th grave. Hint box + live assembled-words box stack above the stone.
## Click the stone or press Interact while on it: correct combination opens the
## gate (if assigned) and emits `solved`; wrong -> click + warning.

signal solved

@export_multiline var hint_text: String = "Only the truth will open the box."
## Correct word for each slot, in order. Its length = number of switches.
@export var solution: Array[String] = []
## The gate to open when solved (any node with an open() method). Optional.
@export var gate: Node
@export var gap: float = 10.0
@export var padding: Vector2 = Vector2(24, 24)   # roomier so the player can reach it
@export var target_sprite: Sprite2D
@export var click_sound: AudioStream             # optional: wrong-combo click
@export var open_sound: AudioStream              # optional: success

var _current: Array[String] = []
var _player_in_range: bool = false
var _is_open: bool = false
var _style: StyleBoxFlat

func _ready() -> void:
	_build_style()
	_fit_to_sprite()
	_apply_style()
	if Engine.is_editor_hint():
		_refresh_display()
		_position_tips()
		return
	_current.resize(solution.size())
	for i in _current.size():
		_current[i] = ""
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	input_event.connect(_on_input_event)
	call_deferred("_setup_switches")   # deferred so every switch has entered the tree
	_refresh_display()

func _setup_switches() -> void:
	for s in get_tree().get_nodes_in_group("grave_switch"):
		if not s.switched.is_connected(_on_switch_changed):
			s.switched.connect(_on_switch_changed)
		if s.slot_index >= 0 and s.slot_index < _current.size():
			_current[s.slot_index] = s.current_word()   # seed starting word
	_refresh_display()

func _on_switch_changed(slot: int, word: String) -> void:
	if slot >= 0 and slot < _current.size():
		_current[slot] = word
	_refresh_display()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_fit_to_sprite()
		_apply_style()
		_refresh_display()
		_position_tips()

# --- interaction ------------------------------------------------------------

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_open:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_solve()

func _unhandled_input(event: InputEvent) -> void:
	if _is_open or not _player_in_range:
		return
	if event is InputEventMouseButton:
		return   # mouse clicks are handled by _on_input_event (avoids double-fire)
	if event.is_action_pressed("Interact"):
		_try_solve()

func _try_solve() -> void:
	if _current == solution:
		_open()
	else:
		_wrong()

func _open() -> void:
	_is_open = true
	if open_sound:
		$Audio.stream = open_sound
		$Audio.play()
	_show_message("The lock clicks open. The gate groans apart.")
	if gate and gate.has_method("open"):
		gate.open()          # drop the barrier / swap to open art
	solved.emit()
	GameManager.puzzle_solved()
	SFX.play_door_open()
	var exit_sign := get_tree().current_scene.get_node_or_null("ExitSign")
	if exit_sign:
		exit_sign.visible = true

func _wrong() -> void:
	if click_sound:
		$Audio.stream = click_sound
		$Audio.play()
	_show_message("*click* ... You feel something is wrong with the combination.")

# --- display ----------------------------------------------------------------

func _refresh_display() -> void:
	var hint := get_node_or_null("HintTip/Label") as Label
	var words := get_node_or_null("WordsTip/Label") as Label
	if hint:
		hint.text = hint_text
	if words:
		var shown: Array[String] = []
		for w in _current:
			shown.append(w if w != "" else "____")
		words.text = " ".join(shown)
	_position_tips()
	if not Engine.is_editor_hint() and is_inside_tree():
		_reposition_soon()

func _reposition_soon() -> void:
	await get_tree().process_frame   # let the boxes compute their real size
	_position_tips()

func _show_message(msg: String) -> void:
	var m := get_node_or_null("MessageTip") as Control
	var ml := get_node_or_null("MessageTip/Label") as Label
	if m == null or ml == null:
		return
	ml.text = msg
	m.reset_size()
	_position_tips()
	m.visible = true
	m.modulate.a = 1.0
	await get_tree().create_timer(2.5).timeout
	var tw := create_tween()
	tw.tween_property(m, "modulate:a", 0.0, 0.4)
	await tw.finished
	m.visible = false

func _position_tips() -> void:
	# Stack the boxes above the stone: words just above it, hint above words,
	# message above the hint.
	var sprite := _get_sprite()
	if sprite == null or sprite.texture == null:
		return
	var r: Rect2 = sprite.get_rect()
	var cx: float = sprite.position.x + (r.position.x + r.size.x * 0.5) * sprite.scale.x
	var top_y: float = sprite.position.y + r.position.y * sprite.scale.y
	var cursor_y: float = top_y - gap
	for node in [get_node_or_null("WordsTip"), get_node_or_null("HintTip"), get_node_or_null("MessageTip")]:
		var c := node as Control
		if c == null:
			continue
		var sz := c.get_combined_minimum_size()
		c.size = sz
		c.position = Vector2(cx - sz.x * 0.5, cursor_y - sz.y)
		cursor_y = c.position.y - gap

# --- style & collision ------------------------------------------------------

func _build_style() -> void:
	_style = StyleBoxFlat.new()
	_style.bg_color = Color(0.09, 0.09, 0.13, 0.94)
	_style.set_corner_radius_all(6)
	_style.set_content_margin_all(10)
	_style.border_color = Color(0.82, 0.82, 0.88, 0.55)
	_style.set_border_width_all(1)
	_style.shadow_color = Color(0, 0, 0, 0.45)
	_style.shadow_size = 6

func _apply_style() -> void:
	for n in ["HintTip", "WordsTip", "MessageTip"]:
		var p := get_node_or_null(n) as PanelContainer
		if p:
			p.add_theme_stylebox_override("panel", _style)

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
