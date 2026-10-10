extends Node2D

@onready var darkness: CanvasModulate = $Darkness
@onready var player_light: PointLight2D = $PlayerLight
@onready var player: Node2D = $Player

#moves light to where player is (follows)
func _process(delta: float) -> void:
	player_light.global_position = player.global_position

#tween animation
func light_up() -> void:
	var tween := create_tween()
	tween.tween_property(darkness, "color", Color.WHITE, 2.0)
	tween.parallel().tween_property(player_light, "energy", 0.0, 2.0)
