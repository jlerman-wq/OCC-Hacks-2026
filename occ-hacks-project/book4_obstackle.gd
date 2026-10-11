
extends StaticBody2D

# BOOK 4 - OCC HACKATHON
# Correct answer: hackathon

@export var title_text: String = "Book 4"
@export_multiline var question_text: String = "What's the best event at OCC?"
@export var correct_answer: String = "hackathon"

@export_multiline var hint_text: String = ""
@export_multiline var second_hint_text: String = ""
@export_multiline var success_text: String = "Correct!"

@export var puzzle_texture: Texture2D
@export var hint_texture: Texture2D

@onready var block_shape: CollisionShape2D = $CollisionShape2D

var solved: bool = false


func _ready() -> void:
	print("BOOK 4 READY: ", name)


func _input(event: InputEvent) -> void:
	if solved or get_tree().paused:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			var rectangle: RectangleShape2D = block_shape.shape as RectangleShape2D

			if rectangle == null:
				return

			if block_shape.disabled:
				return

			var mouse_pos: Vector2 = block_shape.to_local(get_global_mouse_position())
			var half_size: Vector2 = rectangle.size / 2.0
			var click_rect: Rect2 = Rect2(-half_size, rectangle.size)

			if click_rect.has_point(mouse_pos):

				print("BOOK 4 CLICKED!")

				var popup: Node = get_parent().get_node_or_null("Book4Popup")

				if popup == null:
					print("ERROR: Cannot find Book4Popup!")
					return

				if not popup.has_method("open_popup"):
					print("ERROR: Book4Popup missing open_popup!")
					return

				print("OPENING BOOK 4!")

				get_viewport().set_input_as_handled()
				popup.call("open_popup", self)


func solve_book() -> void:
	if solved:
		return

	solved = true
	print("BOOK 4 SOLVED!")

	block_shape.set_deferred("disabled", true)

	# Hide separate Book4 picture if present
	var extra_book = get_parent().get_node_or_null("Book4")

	if extra_book:
		extra_book.hide()

	# Fade out Book 4
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
