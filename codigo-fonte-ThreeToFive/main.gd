extends Node2D

var number1 = 0
var number2 = 0
var number3 = 0

var target = 5

var score = 0
var time_left = 10
var round_time = 10

@onready var target_label = $UI/MachinePanel/TargetLabel
@onready var result_label = $UI/MachinePanel/ResultLabel
@onready var score_label = $UI/MachinePanel/ScoreLabel
@onready var timer_label = $UI/MachinePanel/TimerLabel
@onready var machine_panel = $UI/MachinePanel
@onready var number1_label1 = $UI/MachinePanel/Number1Label1
@onready var number2_label2 = $UI/MachinePanel/Number2Label2
@onready var number3_label3 = $UI/MachinePanel/Number3Label3

@onready var operator1 = $UI/MachinePanel/Operator1
@onready var operator2 = $UI/MachinePanel/Operator2

@onready var confirm_button = $UI/MachinePanel/ConfirmButton

@onready var round_timer = $RoundTimer

@onready var click_sound = $ClickSound
@onready var success_sound = $SuccessSound
@onready var error_sound = $ErrorSound
@onready var gameover_sound = $GameOverSound

func _ready():

	randomize()

	confirm_button.pressed.connect(check_expression)

	round_timer.timeout.connect(update_timer)

	operator1.item_selected.connect(update_expression_display)
	operator2.item_selected.connect(update_expression_display)

	start_new_round()

func start_new_round():

	var possible_rounds = [

		[2, 5, 5],
		[1, 1, 5],
		[9, 4, 1],
		[3, 1, 2],
		[5, 5, 5],
		[8, 2, 1],
		[7, 1, 2],
		[6, 2, 1],
		[4, 2, 1],
		[8, 1, 2],
		[6, 1, 1],
		[9, 1, 3],
		[7, 2, 1],
		[8, 3, 1],
		[2, 2, 1],
		[3, 3, 1],
		[4, 4, 3],
		[7, 3, 1],
		[9, 2, 2],
		[1, 9, 4],
		[2, 6, 7],
		[4, 2, 3],
		[5, 1, 1]
	]

	var selected = possible_rounds.pick_random()

	number1 = selected[0]
	number2 = selected[1]
	number3 = selected[2]

	number1_label1.text = str(number1)
	number2_label2.text = str(number2)
	number3_label3.text = str(number3)

	result_label.text = "Resultado:"

	time_left = round_time

	timer_label.text = "Tempo: " + str(time_left)

	operator1.select(0)
	operator2.select(0)

	round_timer.start()

func update_expression_display(index = 0):

	var op1 = operator1.get_item_text(operator1.selected)
	var op2 = operator2.get_item_text(operator2.selected)

func update_timer():

	time_left -= 1

	timer_label.text = "Tempo: " + str(time_left)

	if time_left <= 0:

		gameover_sound.play()

		result_label.text = "Tempo esgotado!"

		round_timer.stop()

		await get_tree().create_timer(2).timeout

		start_new_round()

func check_expression():

	round_timer.stop()

	var op1 = operator1.get_item_text(operator1.selected)
	var op2 = operator2.get_item_text(operator2.selected)

	var expression = str(number1) + op1 + str(number2) + op2 + str(number3)

	var result = evaluate_expression(number1, op1, number2, op2, number3)

	result_label.text = expression + " = " + str(result)

	if result == target:

		success_sound.play()

		result_label.text += "  ✔ CORRETO"

		result_label.modulate = Color.GREEN

		success_effect()

		result_bounce()

		score += 100

		score_label.text = "Pontos: " + str(score)
		
		if round_time > 3:
			round_time -= 0.5

	else:

		error_sound.play()

		result_label.text += "  ❌ ERRADO"

		result_label.modulate = Color.RED
		
		shake_panel()

	await get_tree().create_timer(2).timeout

	start_new_round()
	
func evaluate_expression(a, op1, b, op2, c):

	var first_result

	# PRIORIDADE MATEMÁTICA
	if op1 == "*" or op1 == "/":

		first_result = calculate(a, op1, b)

		return calculate(first_result, op2, c)

	elif op2 == "*" or op2 == "/":

		first_result = calculate(b, op2, c)

		return calculate(a, op1, first_result)

	else:

		first_result = calculate(a, op1, b)

		return calculate(first_result, op2, c)
		
func calculate(x, op, y):

	match op:

		"+":
			return x + y

		"-":
			return x - y

		"*":
			return x * y

		"/":

			if y == 0:
				return 0

			return float(x) / float(y)

	return 0

func shake_panel():

	var tween = create_tween()

	var original_position = machine_panel.position

	tween.tween_property(
		machine_panel,
		"position",
		original_position + Vector2(10, 0),
		0.05
	)

	tween.tween_property(
		machine_panel,
		"position",
		original_position + Vector2(-10, 0),
		0.05
	)

	tween.tween_property(
		machine_panel,
		"position",
		original_position,
		0.05
	)

func success_effect():

	var tween = create_tween()

	machine_panel.modulate = Color.WHITE

	tween.tween_property(
		machine_panel,
		"modulate",
		Color(0.5, 1, 0.5),
		0.1
	)

	tween.tween_property(
		machine_panel,
		"modulate",
		Color.WHITE,
		0.2
	)

func result_bounce():

	var tween = create_tween()

	result_label.scale = Vector2(1, 1)

	tween.tween_property(
		result_label,
		"scale",
		Vector2(1.3, 1.3),
		0.1
	)

	tween.tween_property(
		result_label,
		"scale",
		Vector2(1, 1),
		0.1
	)

func _on_confirm_button_mouse_entered():

	var tween = create_tween()

	tween.tween_property(
		confirm_button,
		"scale",
		Vector2(1.1, 1.1),
		0.1
	)

func _on_confirm_button_mouse_exited():

	var tween = create_tween()

	tween.tween_property(
		confirm_button,
		"scale",
		Vector2(1, 1),
		0.1
	)

func _on_confirm_button_pressed():

	click_sound.play()

	var tween = create_tween()

	tween.tween_property(
		confirm_button,
		"scale",
		Vector2(0.9, 0.9),
		0.05
	)

	tween.tween_property(
		confirm_button,
		"scale",
		Vector2(1.1, 1.1),
		0.05
	)
