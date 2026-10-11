extends CanvasLayer
## Butcher puzzle overlay (opened on top of Level 2 by ButcherBox).
##
## Every piece is drawn in its correct spot on the shared 3200x3200 artist
## canvas, so when a piece sits at the silhouette's position it lines up
## perfectly. The pieces start scattered; drag each onto the silhouette and it
## snaps home. When all are home, the puzzle is solved.
##
## Pieces are any Sprite2D in the "puzzle_piece" group under this overlay.

signal solved

## How close (screen px) a piece must be dropped to the silhouette to snap home.
@export var snap_distance: float = 50.0
## Pause the room (and player) while the puzzle is open.
@export var pause_game: bool = true

@export_group("Hand cursor")
## Scale of the pointing-hand cursor. Big enough that the arm runs off-screen.
@export var cursor_scale: float = 0.25
## The fingertip pixel in the cursor texture -- the click point / hotspot.
@export var cursor_tip: Vector2 = Vector2(1792, 150)

const CURSOR_PATH := "res://Assets/Artwork/butcher puzzle cursor.png"

@onready var _silhouette: Sprite2D = $Board/Silhouette

var _pieces: Array[Sprite2D] = []
var _dragging: Sprite2D = null
var _drag_offset: Vector2 = Vector2.ZERO
var _placed: int = 0
var _cursor: Sprite2D = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # keep working while the room is paused
	if pause_game:
		get_tree().paused = true
	for n in get_tree().get_nodes_in_group("puzzle_piece"):
		if n is Sprite2D and n != _silhouette:
			_pieces.append(n)
	_make_cursor()

# Pointing-hand cursor: the fingertip tracks the mouse and the arm trails
# off the bottom of the screen. The OS pointer is hidden while open.
func _make_cursor() -> void:
	var tex := load(CURSOR_PATH) as Texture2D
	if tex == null:
		return
	_cursor = Sprite2D.new()
	_cursor.texture = tex
	_cursor.centered = false
	_cursor.offset = -cursor_tip                  # fingertip sits on the node origin
	_cursor.scale = Vector2(cursor_scale, cursor_scale)
	_cursor.z_index = 200                         # above everything in the overlay
	_cursor.z_as_relative = false
	add_child(_cursor)
	_cursor.position = _mouse()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	if _cursor:
		_cursor.position = _mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var p := _pick_piece(_mouse())
			if p:
				_dragging = p
				_drag_offset = p.position - _mouse()
				p.z_index = 100
		elif _dragging:
			_release()
	elif event is InputEventMouseMotion and _dragging:
		_dragging.position = _mouse() + _drag_offset
	elif event.is_action_pressed("ui_cancel"):
		close()

func _mouse() -> Vector2:
	return get_viewport().get_mouse_position()

# Topmost piece under the cursor. Prefer a piece whose actual (opaque) art is
# under the cursor; fall back to the topmost whose bounds contain it, so an
# unreadable texture can never make a piece ungrabbable.
func _pick_piece(pos: Vector2) -> Sprite2D:
	var bbox_hit: Sprite2D = null
	for i in range(_pieces.size() - 1, -1, -1):
		var s := _pieces[i]
		if s.get_meta("placed", false):
			continue
		if not _in_bounds(s, pos):
			continue
		if bbox_hit == null:
			bbox_hit = s
		if _opaque_at(s, pos):
			return s
	return bbox_hit

func _local_px(s: Sprite2D, pos: Vector2) -> Vector2:
	return (pos - s.position) / s.scale

func _in_bounds(s: Sprite2D, pos: Vector2) -> bool:
	if s.texture == null:
		return false
	var half: Vector2 = s.texture.get_size() * 0.5
	var local := _local_px(s, pos)
	return absf(local.x) <= half.x and absf(local.y) <= half.y

func _opaque_at(s: Sprite2D, pos: Vector2) -> bool:
	var local := _local_px(s, pos)
	return s.is_pixel_opaque(Vector2i(roundi(local.x), roundi(local.y)))

func _release() -> void:
	var s := _dragging
	_dragging = null
	s.z_index = 0
	if s.position.distance_to(_silhouette.position) <= snap_distance:
		s.position = _silhouette.position
		s.set_meta("placed", true)
		_placed += 1
		if _placed >= _pieces.size():
			_on_solved()

func _on_solved() -> void:
	var lbl := get_node_or_null("Solved") as Label
	if lbl:
		lbl.visible = true
	solved.emit()

func close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if pause_game and is_inside_tree():
		get_tree().paused = false
	queue_free()

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_close_button_pressed() -> void:
	close()
