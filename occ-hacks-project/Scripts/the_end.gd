extends Control
## End screen: shows final score, leaderboard (2-col, 10 slots), name entry, play again.

@onready var score_label    : Label         = $VBox/ScoreLabel
@onready var name_entry     : VBoxContainer = $VBox/NameEntry
@onready var name_input     : LineEdit      = $VBox/NameEntry/NameInput
@onready var submit_button  : Button        = $VBox/NameEntry/SubmitButton
@onready var lb_left        : VBoxContainer = $VBox/LeaderboardRow/LeftCol
@onready var lb_right       : VBoxContainer = $VBox/LeaderboardRow/RightCol
@onready var play_again_btn : Button        = $VBox/PlayAgainButton

var _final_score: int = 0

func _ready() -> void:
	_final_score = int(GameManager.score)
	score_label.text = "Final Score: %d" % _final_score

	name_entry.visible = HighScores.qualifies(_final_score)
	play_again_btn.visible = true

	_build_leaderboard()

	submit_button.pressed.connect(SFX.play_click)
	submit_button.pressed.connect(_on_submit)
	play_again_btn.pressed.connect(SFX.play_click)
	play_again_btn.pressed.connect(_on_play_again)

func _build_leaderboard() -> void:
	for child in lb_left.get_children():
		child.queue_free()
	for child in lb_right.get_children():
		child.queue_free()

	for i in 10:
		var e: Dictionary = HighScores.entries[i] if i < HighScores.entries.size() else {}
		var name_str : String = e.get("name", "---")
		# Cast to int — JSON loads numbers as float, which would show decimals
		var score_str: String = "%d" % int(e.get("score", 0)) if e.has("score") else "---"
		var row := Label.new()
		row.text = "%d. %-10s %s" % [i + 1, name_str, score_str]
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		if i < 5:
			lb_left.add_child(row)
		else:
			lb_right.add_child(row)

func _on_submit() -> void:
	var player_name := name_input.text.strip_edges()
	if player_name == "":
		player_name = "Anonymous"
	HighScores.submit(player_name, _final_score)
	name_entry.visible = false
	_build_leaderboard()

func _on_play_again() -> void:
	GameManager.start_timer()
	get_tree().change_scene_to_file("res://Scenes/Levels/Level 1/Level_1.tscn")
