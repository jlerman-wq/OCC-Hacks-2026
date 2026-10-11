
extends CollisionObject2D

# BOOK 3 - TUNG TUNG TUNG SAHUR
# Opens book3_popup.tscn when clicked

const BOOK3_POPUP = preload("res://book3_popup.tscn")

@onready var book_sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

var solved: bool = false
var popup_instance: CanvasLayer = null


func _ready() -> void:
	input_pickable = true

	print("BOOK 3 OBSTACLE READY!")
	print("Book 3 collision layer: ", collision_layer)
	print("Book 3 input pickable: ", input_pickable)


func _input_event(
	viewport: Viewport,
	event: InputEvent,
	_shape_idx: int
) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			print("BOOK 3 CLICK DETECTED!")

			if solved:
				print("Book 3 is already solved!")
				return

			viewport.set_input_as_handled()
			open_book3()


func open_book3() -> void:
	print("TRYING TO OPEN BOOK 3!")

	# Prevent opening multiple popups
	if is_instance_valid(popup_instance):
		if popup_instance.visible:
			print("Book 3 popup is already open!")
			return

		popup_instance.queue_free()
		popup_instance = null

	# Create popup
	popup_instance = BOOK3_POPUP.instantiate()

	if popup_instance == null:
		push_error("Cannot create Book 3 popup!")
		return

	# Add popup to the game
	get_tree().current_scene.add_child(popup_instance)

	print("BOOK 3 POPUP CREATED!")

	# Open popup
	popup_instance.open_popup(self)

	print("BOOK 3 POPUP OPENED!")


func solve_book() -> void:
	if solved:
		return

	solved = true

	print("BOOK 3 SOLVED!")

	# Disable collision
	collision_shape.set_deferred("disabled", true)

	# Hide Book 3 picture
	book_sprite.hide()

	# Hide separate Book3 node if present
	var extra_book = get_parent().get_node_or_null("Book3")

	if extra_book:
		extra_book.hide()

	print("BOOK 3 DISAPPEARING!")

	# Remove obstacle
	queue_free()
