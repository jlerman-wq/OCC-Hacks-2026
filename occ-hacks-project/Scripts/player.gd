extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

const SPEED = 800.0
const JUMP_VELOCITY = -400.0

const _FOOTSTEP_PATH := "res://Assets/SFX/Footstep.wav"
const _JUMP_PATH     := "res://Assets/SFX/Jump.wav"
const _LANDING_PATH  := "res://Assets/SFX/Landing.wav"

# How many seconds between each footstep sound
const FOOTSTEP_INTERVAL : float = 0.32

# Animation Facing
var current_facing = 1
var is_transitioning = false

# Sound state
var _was_on_floor    : bool  = false
var _footstep_timer  : float = 0.0

var _footstep_player : AudioStreamPlayer
var _jump_player     : AudioStreamPlayer
var _landing_player  : AudioStreamPlayer

func _ready() -> void:
	sprite.play("Move_Right_Animation")
	sprite.animation_finished.connect(_on_animation_finished)

	_footstep_player = _make_player(_FOOTSTEP_PATH)
	_jump_player     = _make_player(_JUMP_PATH)
	_landing_player  = _make_player(_LANDING_PATH)

func _make_player(path: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	add_child(p)
	return p

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Menu"):
		PauseMenu.toggle_pause()

	var on_floor_now := is_on_floor()

	# Gravity
	if not on_floor_now:
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("Jump") and on_floor_now:
		velocity.y = JUMP_VELOCITY
		_jump_player.play()

	# Movement
	var direction := Input.get_axis("Move_Left", "Move_Right")
	if direction:
		velocity.x = direction * SPEED
		if direction < 0 and current_facing == 1:
			trigger_direction_change(-1)
		elif direction > 0 and current_facing == -1:
			trigger_direction_change(1)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Landing detection — floor contact just became true
	if on_floor_now and not _was_on_floor:
		_landing_player.play()
		_footstep_timer = FOOTSTEP_INTERVAL  # slight delay before first step

	# Footstep: only while moving on the floor
	if on_floor_now and absf(velocity.x) > 10.0:
		_footstep_timer -= delta
		if _footstep_timer <= 0.0:
			_footstep_player.play()
			_footstep_timer = FOOTSTEP_INTERVAL
	else:
		_footstep_timer = 0.0

	_was_on_floor = on_floor_now

func trigger_direction_change(new_direction):
	current_facing = new_direction
	is_transitioning = true
	sprite.play("Turn_Transition_Animation")

func _on_animation_finished():
	if sprite.animation == "Turn_Transition_Animation":
		is_transitioning = false
		if current_facing == -1:
			sprite.play("Move_Left_Animation")
		else:
			sprite.play("Move_Right_Animation")
