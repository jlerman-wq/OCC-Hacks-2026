extends Control

const LEVEL_1 := "res://Scenes/Levels/Level 1/Level_1.tscn"

func _ready() -> void:
	# By the time we get here the threaded request was already kicked off
	# by menu.gd's _ready(). Just poll and swap.
	_poll()

func _poll() -> void:
	while true:
		var status := ResourceLoader.load_threaded_get_status(LEVEL_1)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var packed := ResourceLoader.load_threaded_get(LEVEL_1) as PackedScene
			get_tree().change_scene_to_packed(packed)
			return
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			# Fallback: synchronous load
			get_tree().change_scene_to_file(LEVEL_1)
			return
		await get_tree().process_frame
