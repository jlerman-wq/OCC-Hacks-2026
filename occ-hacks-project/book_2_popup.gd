
extends CanvasLayer

# BOOK 2 - SCUBA PUZZLE
# Keep the S Cu Ba cards and periodic table.
# Correct answer: 162956
# Show a static SCUBA drawing after success.

@onready var title_label = $Control/TitleLabel
@onready var question_label = $Control/QuestionLabel
@onready var puzzle_image = $Control/PuzzleImage

@onready var hint_button = $Control/HintButton
@onready var hint_panel = $Control/HintPanel
@onready var hint_label = $Control/HintPanel/HintLabel
@onready var hint_image = $Control/HintPanel/HintImage
@onready var next_hint_button = $Control/HintPanel/NextHintButton

@onready var answer_box = $Control/AnswerBox
@onready var submit_button = $Control/SubmitButton
@onready var result_label = $Control/ResultLabel
@onready var continue_button = $Control/ContinueButton
@onready var close_button = $Control/CloseButton

# PERIODIC TABLE ZOOM
@onready var periodic_button = $Control/PeriodicTableButton
@onready var zoom_overlay = $Control/ZoomOverlay
@onready var zoom_table = $Control/ZoomOverlay/ZoomTable
@onready var zoom_close_button = $Control/ZoomOverlay/ZoomCloseButton

# SCUBA SUCCESS SCREEN
@onready var success_overlay = $Control/SuccessOverlay
@onready var success_image = $Control/SuccessOverlay/SuccessImage
@onready var success_text = $Control/SuccessOverlay/SuccessText
@onready var success_continue_button = $Control/SuccessOverlay/SuccessContinueButton

const CORRECT_ANSWER: String = "162956"

var current_book: Node = null
var answer_correct: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()
	hint_panel.hide()
	next_hint_button.hide()
	continue_button.hide()
	zoom_overlay.hide()
	success_overlay.hide()

	# Hide old animation permanently
	var old_animation = get_node_or_null(
		"Control/SuccessOverlay/SuccessAnimation"
	)

	if old_animation != null:
		old_animation.hide()

	# Allow clicking through the decorative cards
	puzzle_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	periodic_button.mouse_filter = Control.MOUSE_FILTER_STOP

	# Connect buttons
	hint_button.pressed.connect(toggle_hint)
	periodic_button.pressed.connect(open_table_zoom)
	zoom_close_button.pressed.connect(close_table_zoom)

	submit_button.pressed.connect(check_answer)
	answer_box.text_submitted.connect(_on_answer_submitted)

	close_button.pressed.connect(close_popup)
	continue_button.pressed.connect(continue_game)
	success_continue_button.pressed.connect(continue_game)


func open_popup(book: Node) -> void:
	if book == null:
		return

	current_book = book
	answer_correct = false

	# KEEP the pictures already assigned in the scene
	# Do not replace their textures with obstacle values
	puzzle_image.show()
	periodic_button.show()

	puzzle_image.modulate.a = 1.0
	periodic_button.modulate.a = 1.0

	# SCUBA hint
	hint_label.text = "SCUBA!"

	# Reset popup
	hint_panel.hide()
	hint_image.hide()
	next_hint_button.hide()
	zoom_overlay.hide()
	success_overlay.hide()

	answer_box.text = ""
	answer_box.editable = true

	submit_button.disabled = false
	submit_button.show()

	result_label.text = ""
	continue_button.hide()

	show()

	get_tree().paused = true
	answer_box.grab_focus()


# HINT
func toggle_hint() -> void:
	hint_panel.visible = not hint_panel.visible


# PERIODIC TABLE ZOOM
func open_table_zoom() -> void:
	hint_panel.hide()

	zoom_overlay.show()
	zoom_overlay.move_to_front()

	zoom_close_button.grab_focus()


func close_table_zoom() -> void:
	zoom_overlay.hide()
	periodic_button.grab_focus()


# SUBMIT USING ENTER
func _on_answer_submitted(_submitted: String) -> void:
	check_answer()


# CHECK ANSWER
func check_answer() -> void:
	if current_book == null or answer_correct:
		return

	var player_answer: String = answer_box.text.strip_edges()

	if player_answer != CORRECT_ANSWER:
		result_label.text = "Wrong answer! Try again!"
		return

	answer_correct = true

	answer_box.editable = false
	submit_button.disabled = true
	submit_button.hide()

	result_label.text = ""

	hint_panel.hide()
	zoom_overlay.hide()

	show_success()


# SCUBA SUCCESS DRAWING
func show_success() -> void:
	success_text.text = "SCUBA!!! YOU DID IT!"

	success_overlay.show()
	success_overlay.move_to_front()

	success_image.show()
	success_continue_button.show()

	success_continue_button.grab_focus()


# CONTINUE GAME
func continue_game() -> void:
	if answer_correct and is_instance_valid(current_book):
		if current_book.has_method("solve_book"):
			current_book.call("solve_book")

	close_popup()


# CLOSE POPUP
func close_popup() -> void:
	success_overlay.hide()
	zoom_overlay.hide()
	hint_panel.hide()

	hide()

	current_book = null
	answer_correct = false

	get_tree().paused = false
