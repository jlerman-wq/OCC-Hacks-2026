
extends CanvasLayer

@onready var title_label = $Control/TitleLabel
@onready var question_label = $Control/QuestionLabel
@onready var puzzle_image = $Control/PuzzleImage

@onready var hint_button = $Control/HintButton
@onready var hint_panel = $Control/HintPanel
@onready var hint_label = $Control/HintPanel/HintLabel
@onready var hint_image = $Control/HintPanel/HintImage


@onready var answer_box: LineEdit = $Control/AnswerBox
@onready var submit_button = $Control/SubmitButton
@onready var result_label = $Control/ResultLabel
@onready var continue_button = $Control/ContinueButton
@onready var close_button = $Control/CloseButton

var current_book: Node = null
var correct_answer: String = ""
var answer_correct: bool = false

func _ready() -> void:
	add_to_group("book_popup")
	process_mode = Node.PROCESS_MODE_ALWAYS

	visible = false
	hint_panel.hide()
	continue_button.hide()

	hint_button.pressed.connect(show_hint)
	submit_button.pressed.connect(check_answer)
	continue_button.pressed.connect(continue_game)
	close_button.pressed.connect(close_popup)

func open_popup(book: Node) -> void:
	current_book = book
	correct_answer = book.correct_answer
	answer_correct = false

	title_label.text = book.title_text
	question_label.text = book.question_text
	puzzle_image.texture = book.puzzle_texture

	hint_label.text = book.hint_text
	hint_image.texture = book.hint_texture
	hint_image.visible = book.hint_texture != null

	answer_box.text = ""
	answer_box.editable = true
	result_label.text = ""

	submit_button.disabled = false
	continue_button.hide()
	hint_panel.hide()

	show()
	get_tree().paused = true
	answer_box.grab_focus()

func show_hint() -> void:
	hint_panel.visible = !hint_panel.visible

func check_answer() -> void:
	if current_book == null:
		return



	var answer: String = answer_box.text.strip_edges().to_lower()

	if answer == correct_answer.strip_edges().to_lower():
		result_label.text = current_book.success_text
		answer_correct = true
		submit_button.disabled = true
		answer_box.editable = false
		continue_button.show()
	else:
		result_label.text = "Wrong answer! Try again!"

		result_label.text = "Wrong answer! Try again!"

func continue_game() -> void:
	if answer_correct and is_instance_valid(current_book):
		current_book.solve_book()

	close_popup()

func close_popup() -> void:
	hide()
	current_book = null
	get_tree().paused = false
