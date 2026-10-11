extends Control

@onready var close_button: Button = $PanelContainer/VBox/CloseButton

func _ready() -> void:
	close_button.pressed.connect(SFX.play_click)
	close_button.pressed.connect(hide)
	hide()

func show_panel() -> void:
	show()
	close_button.grab_focus()
