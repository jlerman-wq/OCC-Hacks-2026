extends Node
## GameManager — autoload singleton.
## Tracks the 8-minute countdown timer and the player's score.

signal timer_updated(seconds_left: int)
signal score_updated(new_score: int)
signal game_won(final_score: int)

const TOTAL_TIME        : float = 480.0   # 8 minutes in seconds
const POINTS_PER_PUZZLE : int   = 2500
const DRAIN_RATE        : int = 10    # points lost per second

var time_left : float = TOTAL_TIME
var score     : float = 0.0
var _running  : bool  = false
var _finished : bool  = false

# ── public API ───────────────────────────────────────────────────────

func start_timer() -> void:
	time_left = TOTAL_TIME
	score     = 0.0
	_running  = true
	_finished = false
	score_updated.emit(int(score))
	timer_updated.emit(int(time_left))

func stop_timer() -> void:
	_running = false

func puzzle_solved() -> void:
	score += float(POINTS_PER_PUZZLE)
	score_updated.emit(int(score))

func win() -> void:
	## Called when the player reaches the exit. Ends the game immediately.
	if _finished:
		return
	_finished = true
	_running  = false
	game_won.emit(int(score))
	SceneTransition.change_scene("res://Scenes/The_End.tscn")

# ── internal tick ───────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if not _running or _finished:
		return

	# Tick the timer down
	time_left = maxf(time_left - delta, 0.0)
	timer_updated.emit(int(time_left))

	# Drain score — floor at 0, never goes negative
	score = maxf(score - DRAIN_RATE * delta, 0.0)
	score_updated.emit(int(score))

	# Game ends when timer hits zero
	if time_left <= 0.0:
		_finished = true
		_running  = false
		game_won.emit(int(score))
		SFX.play_out_of_time()
		SceneTransition.change_scene("res://Scenes/The_End.tscn")
