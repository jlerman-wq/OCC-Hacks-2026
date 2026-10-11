extends Area2D
class_name TransitionTrigger

@export var target_scene: PackedScene
@export var require_interact: bool = false;
## While locked, entering/interacting does nothing. Call open() to unlock
## (e.g. from a puzzle's `solved` signal). Matches the Gate open() interface.
@export var locked: bool = false

var _player_in_range: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body:Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if require_interact:
		_player_in_range = true
	else:
		_use()

func _on_body_exited(body:Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
	
func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("Interact"):
		_use()
		
func _use() -> void:
	if locked:
		return
	if target_scene == null:
		push_warning("Transition Trigger has no target scene set.")
		return
	SceneTransition.change_scene_to(target_scene)

## Unlock the exit (called by a puzzle on solve). Named to match Gate.open().
func open() -> void:
	locked = false

func lock() -> void:
	locked = true
