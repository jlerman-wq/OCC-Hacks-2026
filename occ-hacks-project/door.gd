
extends Area2D

@export_file("*.tscn") var next_scene: String = ""
@export var locked: bool = false

var player_near: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false

func _unhandled_input(event: InputEvent) -> void:
	if not player_near:
		return

	if event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.echo:
			if locked:
				print("Solve all 5 books first!")
			elif next_scene != "":
				get_tree().change_scene_to_file(next_scene)

func unlock() -> void:
	locked = false
