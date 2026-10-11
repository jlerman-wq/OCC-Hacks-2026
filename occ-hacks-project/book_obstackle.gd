
extends StaticBody2D

@export var title_text: String = "Book 1"
@export_multiline var question_text: String = "Solve the puzzle!"
@export var correct_answer: String = "25"
@export_multiline var hint_text: String = "Hint here"
@export_multiline var success_text: String = "Correct!"
@export var puzzle_texture: Texture2D
@export var hint_texture: Texture2D

@onready var click_area = $ClickArea
@onready var block_shape = $CollisionShape2D
@onready var click_shape = $ClickArea/CollisionShape2D

func _ready() -> void:
	click_area.input_pickable = true
	click_area.input_event.connect(on_book_clicked)


func on_book_clicked(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("BOOK CLICKED!")

			var popup = get_tree().get_first_node_in_group("book_popup")
			print("Popup found: ", popup)

			if popup != null:
				popup.open_popup(self)


func solve_book() -> void:
	block_shape.set_deferred("disabled", true)
	click_shape.set_deferred("disabled", true)

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
