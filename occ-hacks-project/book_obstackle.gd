
extends StaticBody2D

@export var title_text: String = "We Love Math... RIGHT?"
@export_multiline var question_text: String = "Solve the math!!!"
@export var correct_answer: String = "25"

@export_multiline var hint_text: String = "Your math teacher is disappointed... Are you really sure you want another hint?"

@export_multiline var second_hint_text: String = ""

@export_multiline var success_text: String = "You passed the math, but not this room!"

@export var puzzle_texture: Texture2D
@export var hint_texture: Texture2D

@onready var block_shape: CollisionShape2D = $CollisionShape2D

var solved: bool = false


func _ready() -> void:
	print("BOOK READY: ", name)


func _input(event: InputEvent) -> void:
	if solved:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var rectangle: RectangleShape2D = block_shape.shape as RectangleShape2D

			if rectangle == null:
				print("ERROR: Book needs RectangleShape2D!")
				return

			var mouse_pos: Vector2 = block_shape.to_local(get_global_mouse_position())

			var half_size: Vector2 = rectangle.size / 2.0
			var click_rect: Rect2 = Rect2(-half_size, rectangle.size)

			if click_rect.has_point(mouse_pos):
				print("BOOK CLICKED: ", name)

				var popup: Node = get_tree().get_first_node_in_group("book_popup")

				if popup == null:
					print("ERROR: BookPopup not found!")
					return

				get_viewport().set_input_as_handled()
				popup.call("open_popup", self)


func solve_book() -> void:
	if solved:
		return

	solved = true
	print("BOOK SOLVED: ", name)

	block_shape.set_deferred("disabled", true)

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
