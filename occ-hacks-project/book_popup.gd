
extends CanvasLayer

@onready var title_label = $Control/TitleLabel
@onready var question_label = $Control/QuestionLabel
@onready var puzzle_image = $Control/PuzzleImage

@onready var hint_button: Button = $Control/HintButton
@onready var hint_panel = $Control/HintPanel
@onready var hint_label: Label = $Control/HintPanel/HintLabel
@onready var hint_image: TextureRect = $Control/HintPanel/HintImage

@onready var answer_box: LineEdit = $Control/AnswerBox
@onready var submit_button: Button = $Control/SubmitButton
@onready var result_label: Label = $Control/ResultLabel
@onready var continue_button: Button = $Control/ContinueButton
@onready var close_button: Button = $Control/CloseButton

var current_book: Node = null
var correct_answer: String = ""
var answer_correct: bool = false

func _ready() -> void:
	add_to_group("book_popup")
	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()
	hint_panel.hide()
	continue_button.hide()

	hint_button.pressed.connect(show_hint)
	submit_button.pressed.connect(check_answer)
	continue_button.pressed.connect(continue_game)
	close_button.pressed.connect(close_popup)

	print("BookPopup READY!")

func open_popup(book: Node) -> void:
	print("OPENING BOOK POPUP!")

	current_book = book
	correct_answer = str(book.get("correct_answer"))
	answer_correct = false

	title_label.text = str(book.get("title_text"))
	question_label.text = str(book.get("question_text"))
	puzzle_image.texture = book.get("puzzle_texture") as Texture2D

	hint_label.text = str(book.get("hint_text"))
	hint_image.texture = book.get("hint_texture") as Texture2D
	hint_image.visible = hint_image.texture != null

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
	hint_panel.visible = not hint_panel.visible

func check_answer() -> void:
	if current_book == null:
		return

	var answer: String = answer_box.text.strip_edges().to_lower()

	if answer == correct_answer.strip_edges().to_lower():
		result_label.text = str(current_book.get("success_text"))
		answer_correct = true
		submit_button.disabled = true
		answer_box.editable = false
		continue_button.show()
	else:
		result_label.text = "Wrong answer! Try again!"

func continue_game() -> void:
	if answer_correct and is_instance_valid(current_book):
		current_book.call("solve_book")

	close_popup()

func close_popup() -> void:
	hide()
	current_book = null
	get_tree().paused = false
