extends CanvasLayer
## Autoload singleton that fades the screen out, swaps scenes, then fades back in.
## Register in Project Settings > Autoload with the EXACT name "Transition".

signal scene_changed  ## Emitted at the darkest point, after the new scene loads.

@export var fade_duration: float = 0.4
@export var fade_color: Color = Color.BLACK

var _rect: ColorRect
var _is_transitioning: bool = false

func _ready() -> void:
	layer = 128  # draw on top of everything
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep running even if the game is paused

	_rect = ColorRect.new()
	_rect.color = fade_color
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # don't eat clicks
	_rect.modulate.a = 0.0
	add_child(_rect)

## Call with a path: Transition.change_scene("res://Scenes/Level2.tscn")
func change_scene(path: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	await _fade(1.0)
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	scene_changed.emit()
	await _fade(0.0)

	_is_transitioning = false

## Call with a PackedScene (what TransitionTrigger uses):
## Transition.change_scene_to(target_scene)
func change_scene_to(packed: PackedScene) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	await _fade(1.0)
	get_tree().change_scene_to_packed(packed)
	await get_tree().process_frame
	scene_changed.emit()
	await _fade(0.0)

	_is_transitioning = false

func _fade(target_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", target_alpha, fade_duration)
	await tween.finished
