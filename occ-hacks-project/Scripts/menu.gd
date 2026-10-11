extends Control

const LEVEL_1 := "res://Scenes/Levels/Level 1/Level_1.tscn"

func _on_play_button_pressed() -> void:
	GameManager.start_timer()
	get_tree().change_scene_to_file(LEVEL_1)

func _on_options_button_pressed() -> void:
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()
