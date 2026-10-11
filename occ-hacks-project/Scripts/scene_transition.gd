extends CanvasLayer
## Autoload singleton that fades the screen out, swaps scenes, then fades back in.
## Also owns the HUD so it persists across all rooms.
## Register in Project Settings > Autoload with the EXACT name "SceneTransition".

signal scene_changed

@export var fade_duration: float = 0.4
@export var fade_color: Color = Color.BLACK

const HUD_SCENE_PATH := "res://Scenes/UI/HUD.tscn"
const HUD_HIDDEN_SCENES: Array[String] = [
	"res://Scenes/MainMenu.tscn",
	"res://Scenes/The_End.tscn",
]

var _rect: ColorRect
var _hud: CanvasLayer
var _is_transitioning: bool = false

func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS

	_rect = ColorRect.new()
	_rect.color = fade_color
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.modulate.a = 0.0
	add_child(_rect)

	# Do NOT preload the HUD here — load() at startup blocks the main thread.
	# Instead spawn it lazily the first time we enter a game scene.
	get_tree().root.child_order_changed.connect(_on_scene_changed)

func _on_scene_changed() -> void:
	call_deferred("_update_hud_visibility")

func _ensure_hud() -> void:
	if _hud != null:
		return
	var hud_scene := load(HUD_SCENE_PATH) as PackedScene
	if hud_scene:
		_hud = hud_scene.instantiate()
		add_child(_hud)

func _update_hud_visibility() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var scene := tree.current_scene
	if scene == null:
		return
	var path := scene.scene_file_path
	if path not in HUD_HIDDEN_SCENES:
		_ensure_hud()
	if _hud != null:
		_hud.visible = path not in HUD_HIDDEN_SCENES

func change_scene(path: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	await _fade(1.0)
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	scene_changed.emit()
	_update_hud_visibility()
	await _fade(0.0)
	_is_transitioning = false

func change_scene_to(packed: PackedScene) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	await _fade(1.0)
	get_tree().change_scene_to_packed(packed)
	await get_tree().process_frame
	scene_changed.emit()
	_update_hud_visibility()
	await _fade(0.0)
	_is_transitioning = false

func _fade(target_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", target_alpha, fade_duration)
	await tween.finished
