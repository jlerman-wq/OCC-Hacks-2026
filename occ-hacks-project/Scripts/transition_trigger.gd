extends Area2D
class_name TransitionTrigger

## Path to the next scene, e.g. "res://Scenes/Levels/Level 2/Level_2.tscn"
## Use a String instead of PackedScene so the target is NOT loaded as an
## ext_resource — that would chain-load every level at startup.
@export_file("*.tscn") var target_scene_path: String = ""
@export var require_interact: bool = false
@export var locked: bool = false

var _player_in_range: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if require_interact:
		_player_in_range = true
	else:
		_use()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("Interact"):
		_use()

func _use() -> void:
	if locked:
		return
	if target_scene_path == "":
		push_warning("TransitionTrigger has no target_scene_path set.")
		return
	SceneTransition.change_scene(target_scene_path)

func open() -> void:
	locked = false

func lock() -> void:
	locked = true
