
extends CanvasLayer

# BOOK 1 - MATH POPUP

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

var current_book: Node = null
var answer_correct: bool = false
var showing_second_hint: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()
	hint_panel.hide()
	next_hint_button.hide()
	continue_button.hide()

	hint_button.pressed.connect(toggle_hint)
	next_hint_button.pressed.connect(show_second_hint)
	submit_button.pressed.connect(check_answer)
	answer_box.text_submitted.connect(_on_answer_submitted)
	continue_button.pressed.connect(continue_game)
	close_button.pressed.connect(close_popup)


func open_popup(book: Node) -> void:
	if book == null:
		return

	current_book = book
	answer_correct = false
	showing_second_hint = false

	# Load information from the clicked book
	title_label.text = book.title_text
	question_label.text = book.question_text

	puzzle_image.texture = book.puzzle_texture
	puzzle_image.visible = book.puzzle_texture != null

	hint_label.text = book.hint_text
	hint_image.texture = book.hint_texture
	hint_image.visible = book.hint_texture != null

	# Reset hints
	hint_panel.hide()
	next_hint_button.visible = book.second_hint_text != ""

	# Reset answer
	answer_box.text = ""
	answer_box.editable = true

	submit_button.disabled = false
	submit_button.show()

	result_label.text = ""
	continue_button.hide()

	# Show popup and pause game
	show()
	get_tree().paused = true
	answer_box.grab_focus()


func toggle_hint() -> void:
	if hint_panel.visible:
		hint_panel.hide()
	else:
		hint_panel.show()


func show_second_hint() -> void:
	if current_book == null:
		return

	showing_second_hint = true
	hint_label.text = current_book.second_hint_text
	next_hint_button.hide()


func _on_answer_submitted(_submitted: String) -> void:
	check_answer()


func check_answer() -> void:
	if current_book == null or answer_correct:
		return

	var player_answer: String = answer_box.text.strip_edges()
	var correct: String = str(current_book.correct_answer).strip_edges()

	if player_answer != correct:
		result_label.text = "Wrong answer! Try again!"
		return

	# Correct answer
	answer_correct = true

	answer_box.editable = false
	submit_button.disabled = true
	submit_button.hide()

	result_label.text = current_book.success_text

	continue_button.show()
	hint_panel.hide()


func continue_game() -> void:
	if answer_correct and is_instance_valid(current_book):
		current_book.call("solve_book")

	close_popup()


func close_popup() -> void:
	hide()
	hint_panel.hide()
	continue_button.hide()

	current_book = null
	answer_correct = false
	showing_second_hint = false

	get_tree().paused = false
