
extends CanvasLayer

# BOOK 4 - OCC HACKATHON
# Correct answer: hackathon
# Hint: Cat meme picture only

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
var correct_answer: String = "hackathon"
var second_hint_text: String = ""
var success_text: String = "Correct!"
var answer_correct: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()
	hint_panel.hide()
	continue_button.hide()

	# Hide unused Book 2 features
	var periodic = get_node_or_null("Control/PeriodicTableButton")
	if periodic:
		periodic.hide()

	var zoom = get_node_or_null("Control/ZoomOverlay")
	if zoom:
		zoom.hide()

	var success = get_node_or_null("Control/SuccessOverlay")
	if success:
		success.hide()

	hint_button.pressed.connect(show_hint)
	next_hint_button.pressed.connect(show_second_hint)
	submit_button.pressed.connect(check_answer)
	continue_button.pressed.connect(continue_game)
	close_button.pressed.connect(close_popup)

	print("BOOK 4 POPUP READY!")


func open_popup(book: Node) -> void:
	print("OPENING BOOK 4!")

	current_book = book
	answer_correct = false

	# Information from Book4Obsta Inspector
	title_label.text = str(book.get("title_text"))
	question_label.text = str(book.get("question_text"))
	correct_answer = str(book.get("correct_answer"))
	second_hint_text = str(book.get("second_hint_text"))
	success_text = str(book.get("success_text"))

	# Puzzle image - optional for Book 4
	var new_puzzle: Texture2D = book.get("puzzle_texture") as Texture2D

	if new_puzzle != null:
		puzzle_image.texture = new_puzzle
		puzzle_image.show()
	else:
		puzzle_image.hide()

	# Hint text - optional
	hint_label.text = str(book.get("hint_text"))

	if hint_label.text.strip_edges().is_empty():
		hint_label.hide()
	else:
		hint_label.show()

	# Hint picture - cat meme
	var new_hint: Texture2D = book.get("hint_texture") as Texture2D

	if new_hint != null:
		hint_image.texture = new_hint

	hint_image.visible = hint_image.texture != null

	next_hint_button.visible = not second_hint_text.is_empty()
	hint_panel.hide()

	# Reset answer
	answer_box.text = ""
	answer_box.editable = true
	submit_button.disabled = false
	result_label.text = ""
	continue_button.hide()

	show()
	get_tree().paused = true
	answer_box.grab_focus()


func show_hint() -> void:
	hint_panel.visible = not hint_panel.visible


func show_second_hint() -> void:
	hint_label.text = second_hint_text
	hint_label.show()
	next_hint_button.hide()


func check_answer() -> void:
	var answer: String = answer_box.text.strip_edges().to_lower()

	if answer == correct_answer.strip_edges().to_lower():
		answer_correct = true
		result_label.text = success_text

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
