extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Animation Facing
var current_facing = 1;
var is_transitioning = false;

func _ready() -> void:
	# Start the initial animation
	sprite.play("Move_Right_Animation")
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Menu"):
		PauseMenu.toggle_pause()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("Move_Left", "Move_Right")
	if direction:
		velocity.x = direction * SPEED
		
		# check for player direction for animation
		if direction < 0 and current_facing == 1:
			trigger_direction_change(-1)
		elif direction > 0 and current_facing == -1:
			trigger_direction_change(1)
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
 

	
	

func trigger_direction_change(new_direction):
	current_facing = new_direction;
	is_transitioning = true;
	
	# Play Animation
	sprite.play("Turn_Transition_Animation")
	
func _on_animation_finished():
	# once the animation ends, switch to final direction.
	if sprite.animation == "Turn_Transition_Animation":
		is_transitioning = false;
		if current_facing == -1:
			sprite.play("Move_Left_Animation")
		else:
			sprite.play("Move_Right_Animation")
