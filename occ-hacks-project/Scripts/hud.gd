extends CanvasLayer
## HUD — displays the score (top-left) and countdown timer (top-right).
## Add this as a CanvasLayer child of your level scene and it auto-connects
## to GameManager signals.

@onready var score_label : Label = $ScoreLabel
@onready var timer_label : Label = $TimerLabel

func _ready() -> void:
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.timer_updated.connect(_on_timer_updated)
	# Seed display with current values
	_on_score_updated(int(GameManager.score))
	_on_timer_updated(int(GameManager.time_left))

func _on_score_updated(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_timer_updated(seconds_left: int) -> void:
	var mins : int = int(seconds_left / 60)
	var secs : int = int(seconds_left % 60)
	timer_label.text = "%d:%02d" % [mins, secs]
	# Flash red in last 30 seconds
	if seconds_left <= 30:
		timer_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	else:
		timer_label.remove_theme_color_override("font_color")
