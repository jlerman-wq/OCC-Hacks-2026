extends Area2D

signal lit(number: int)

@export var number := 1

var player_near := false
var is_lit := false

@onready var candle: PointLight2D = $Candle

func _ready() -> void:
	candle.enabled = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	input_event.connect(_on_input_event)

# Mouse: a click directly on THIS pumpkin lights only it. Consuming the event
# stops a pumpkin underneath (overlapping collision) from also firing, which
# was what lit two pumpkins from a single click.
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_lit:
			light()
		get_viewport().set_input_as_handled()

# Keyboard: press Interact (E) while standing next to a pumpkin. Matched as a
# key event rather than the Interact action (which is also bound to the mouse),
# so a click never triggers this proximity path on top of the direct click.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("Interact") and not event.is_echo():
		if player_near and not is_lit:
			light()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_near = false

func light() -> void:
	is_lit = true
	candle.enabled = true
	lit.emit(number)

func reset() -> void:
	is_lit = false
	candle.enabled = false

# Recolor the candle light (used for the green "solved" glow) and turn it on.
func set_light_color(c: Color) -> void:
	candle.color = c
	candle.enabled = true
