extends Node2D

@onready var _exit: Node = get_node_or_null("Transition_Trigger")
@onready var exit_sign: Sprite2D = $ExitSign
@onready var book3: Node = $Book3Obstackle

func _ready() -> void:
	MusicManager.play("level3")
	exit_sign.visible = false
	# Book3Obstackle calls solve_book() internally, but has no signal.
	# Poll via a deferred check after solve_book sets solved = true.
	# Instead, we override solve_book by connecting after the fact —
	# simplest: replace solve_book with a wrapper using set().
	# Cleanest: check each frame only until solved.
	set_process(true)

func _process(_delta: float) -> void:
	if book3 == null or not is_instance_valid(book3):
		# Book3 freed itself after solve — that means it was solved
		_on_book3_solved()
		set_process(false)
		return
	if book3.get("solved") == true:
		_on_book3_solved()
		set_process(false)

func _on_book3_solved() -> void:
	GameManager.puzzle_solved()
	exit_sign.visible = true
	SFX.play_door_open()
	if _exit and _exit.has_method("open"):
		_exit.open()
