extends Node2D

@export var code: Array[int] = [3, 1, 4]
## Candle colour applied to every pumpkin once the code is solved.
@export var solved_light_color: Color = Color(0.4, 1.3, 0.45)

@onready var darkness: CanvasModulate = $Darkness
@onready var player_light: PointLight2D = $PlayerLight
@onready var player: Node2D = $Player
@onready var _exit: Node = get_node_or_null("Transition_Trigger")

var pumpkins: Array = []
var entered: Array[int] = []
var solved := false

func _ready() -> void:
	# Lock the exit to The End until the pumpkin code is solved.
	if _exit and _exit.has_method("lock"):
		_exit.lock()

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
		light_up()
		_glow_pumpkins_green()
		if _exit and _exit.has_method("open"):
			_exit.open()   # unlock the exit to The End

# Turn every pumpkin's candle green as the solved state.
func _glow_pumpkins_green() -> void:
	for p in pumpkins:
		if p.has_method("set_light_color"):
			p.set_light_color(solved_light_color)

func reset_pumpkins() -> void:
	entered.clear()
	for p in pumpkins:
		p.reset()

func light_up() -> void:
	var tween := create_tween()
	tween.tween_property(darkness, "color", Color.WHITE, 2.0)
	tween.parallel().tween_property(player_light, "energy", 0.0, 2.0)
