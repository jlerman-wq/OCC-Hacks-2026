extends Area2D

func _ready() -> void:
	#player enters
	body_entered.connect(_on_body_entered)
#when player goes into exit
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Congratulations you have escaped the haunted house..")
