extends Control

const LEVEL_1 := "res://Scenes/Levels/Level 1/Level_1.tscn"

@onready var options_panel : Control = $OptionsPanel
@onready var about_panel   : Control = $AboutPanel

func _ready() -> void:
	MusicManager.play("menu")
	_connect_buttons(self)

func _connect_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			child.pressed.connect(SFX.play_click)
		_connect_buttons(child)

func _on_play_button_pressed() -> void:
	GameManager.start_timer()
	get_tree().change_scene_to_file(LEVEL_1)

func _on_options_button_pressed() -> void:
	options_panel.show_panel()

func _on_about_button_pressed() -> void:
	about_panel.show_panel()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
