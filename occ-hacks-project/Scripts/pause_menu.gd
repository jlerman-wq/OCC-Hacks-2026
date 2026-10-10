extends CanvasLayer

@onready var resume_button: Button = $Control/VBoxContainer/Resume_Button
@onready var options_button: Button = $Control/VBoxContainer/Options_Button
@onready var quit_button: Button = $Control/VBoxContainer/Quit_Button

@onready var control: Control = $Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Keep the CanvasLayer itself visible, but hide the internal control container
	visible = true
	control.hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Menu"):
		toggle_pause()

var last_toggle_time: int = 0

func toggle_pause() -> void:
	var current_time = Time.get_ticks_msec()
	if current_time - last_toggle_time < 250:
		return
	last_toggle_time = current_time

	var is_paused: bool = not get_tree().paused
	get_tree().paused = is_paused
	
	# Toggle the internal control node instead of the CanvasLayer
	control.visible = is_paused
	
	if is_paused:
		# Focus on the first button for keyboard navigation (deferred to avoid focus errors)
		resume_button.call_deferred("grab_focus")

func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_options_button_pressed() -> void:
	print("Open Options Sub-menu")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
