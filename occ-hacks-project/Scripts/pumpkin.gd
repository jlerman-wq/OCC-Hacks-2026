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

func _process(delta: float) -> void:
	if player_near and not is_lit and Input.is_action_just_pressed("Interact"):
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
