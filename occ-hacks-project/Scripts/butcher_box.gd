extends Area2D
## Click the butcher's box (side view) to open the butcher puzzle as an overlay
## on top of the current room. The room pauses behind it; closing resumes.
## The box is tinted red while the puzzle is unsolved and green once solved,
## matching the Level 1 gate.

## The puzzle overlay scene to open (ButcherPuzzle.tscn).
@export var puzzle_scene: PackedScene
## Also allow opening with the Interact key while hovering the box.
@export var require_interact: bool = false
## Node to open() when the puzzle is solved -- e.g. the room's exit
## Transition_Trigger, so Room 3 is locked until the butcher is reassembled.
@export var gate: Node

@export_group("Solved state tint")
@export var use_tint: bool = true
@export var unsolved_tint: Color = Color(1.0, 0.3, 0.3)   # red
@export var solved_tint: Color = Color(0.4, 1.0, 0.4)     # green

var _open_instance: Node = null
var _hovered: bool = false
var solved: bool = false

func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(func() -> void: _hovered = true)
	mouse_exited.connect(func() -> void: _hovered = false)
	_apply_tint()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_open()

func _unhandled_input(event: InputEvent) -> void:
	if require_interact and _hovered and event.is_action_pressed("Interact"):
		_open()

func _open() -> void:
	if puzzle_scene == null:
		push_warning("ButcherBox has no puzzle_scene assigned.")
		return
	if is_instance_valid(_open_instance):
		return   # already open
	_open_instance = puzzle_scene.instantiate()
	if _open_instance.has_signal("solved"):
		_open_instance.solved.connect(_on_puzzle_solved)
	get_tree().current_scene.add_child(_open_instance)

func _on_puzzle_solved() -> void:
	solved = true
	_apply_tint()
	if gate and gate.has_method("open"):
		gate.open()   # unlock the exit to Room 3
	GameManager.puzzle_solved()
	SFX.play_door_open()
	var exit_sign := get_tree().current_scene.get_node_or_null("ExitSign")
	if exit_sign:
		exit_sign.visible = true

# Red while unsolved, green once solved (the box art is grayscale, so the
# tint reads clearly) -- same convention as the Level 1 gate.
func _apply_tint() -> void:
	if not use_tint:
		return
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr:
		spr.modulate = solved_tint if solved else unsolved_tint
