
extends CanvasLayer

# BOOK 3 - TUNG TUNG TUNG SAHUR
# Correct answer: sahur

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

const CORRECT_ANSWER = "sahur"

var current_book: Node = null
var answer_correct: bool = false


func _ready() -> void:
	add_to_group("book_popup")
	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()
	hint_panel.hide()
	continue_button.hide()

	title_label.text = "Book 3"
	question_label.text = "TUNG TUNG TUNG..."

	hint_button.pressed.connect(show_hint)
	next_hint_button.pressed.connect(show_second_hint)
	submit_button.pressed.connect(check_answer)
	continue_button.pressed.connect(continue_game)
	close_button.pressed.connect(close_popup)

	print("BOOK 3 POPUP READY!")


func open_popup(book: Node) -> void:
	print("OPENING BOOK 3!")

	current_book = book
	answer_correct = false

	title_label.text = "Book 3"
	question_label.text = "TUNG TUNG TUNG..."

	# Keep the classmate's drawing
	puzzle_image.show()

	# Keep the hint picture from the Inspector
	hint_label.text = "Do you recognize this character?"
	hint_image.show()

	next_hint_button.show()
	hint_panel.hide()

	# Reset answer
	answer_box.text = ""
	answer_box.editable = true

	result_label.text = ""

	submit_button.disabled = false
	continue_button.hide()

	show()
	get_tree().paused = true
	answer_box.grab_focus()


func show_hint() -> void:
	hint_panel.visible = not hint_panel.visible


func show_second_hint() -> void:
	hint_label.text = "The answer starts with S and has 5 letters."
	next_hint_button.hide()


func check_answer() -> void:
	var answer: String = answer_box.text.strip_edges().to_lower()

	if answer == CORRECT_ANSWER:
		result_label.text = "Correct! TUNG TUNG TUNG SAHUR!"

		answer_correct = true

		submit_button.disabled = true
		answer_box.editable = false

		continue_button.show()

	else:
		result_label.text = "Wrong answer! Try again!"


func continue_game() -> void:
	if answer_correct and is_instance_valid(current_book):
		if current_book.has_method("solve_book"):
			current_book.call("solve_book")

	close_popup()


func close_popup() -> void:
	hide()

	current_book = null
	answer_correct = false

	get_tree().paused = false
