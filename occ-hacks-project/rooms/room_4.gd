extends Node2D

@export var code: Array[int] = [3, 1, 4]

@onready var darkness: CanvasModulate = $Darkness
@onready var player_light: PointLight2D = $PlayerLight
@onready var player: Node2D = $Player

var pumpkins: Array = []
var entered: Array[int] = []
var solved := false

func _ready() -> void:
	for child in get_children():
		if child.has_signal("lit"):
			pumpkins.append(child)
			child.lit.connect(_on_pumpkin_lit)

	pumpkins.sort_custom(func(a, b): return a.position.x < b.position.x)
	for i in pumpkins.size():
		pumpkins[i].number = i + 1

func _process(delta: float) -> void:
	player_light.global_position = player.global_position

func _on_pumpkin_lit(number: int) -> void:
	if solved:
		return
	entered.append(number)
	var i := entered.size() - 1

	if entered[i] != code[i]:
		print("Wrong! Resetting.")
		await get_tree().create_timer(0.6).timeout
		reset_pumpkins()
	elif entered.size() == code.size():
		print("Correct code!")
		solved = true

func reset_pumpkins() -> void:
	entered.clear()
	for p in pumpkins:
		p.reset()

func light_up() -> void:
	var tween := create_tween()
	tween.tween_property(darkness, "color", Color.WHITE, 2.0)
	tween.parallel().tween_property(player_light, "energy", 0.0, 2.0)
