extends Control

## Painel da máquina: mostra a conta, confere a resposta e conduz
## o tutorial (fala da máquina + rodada de calibração sem tempo).

const CALIBRATION_ROUND := [6, 2, 1]   # 6 - 2 + 1 = 5 (só + e -)
const ROUND_PAUSE := 1.2               # pausa entre uma rodada e outra

@onready var score_label: Label = $UI/Screen/VBox/TopBar/ScoreLabel
@onready var target_label: Label = $UI/Screen/VBox/TopBar/TargetLabel
@onready var timer_label: Label = $UI/Screen/VBox/TopBar/TimerLabel
@onready var sector_label: Label = $UI/Screen/VBox/SectorLabel
@onready var sector_bar: ProgressBar = $UI/Screen/VBox/SectorBar

@onready var number1_label1: Label = $UI/Screen/VBox/Expression/Number1Label1
@onready var number2_label2: Label = $UI/Screen/VBox/Expression/Number2Label2
@onready var number3_label3: Label = $UI/Screen/VBox/Expression/Number3Label3
@onready var operator1: OptionButton = $UI/Screen/VBox/Expression/Operator1
@onready var operator2: OptionButton = $UI/Screen/VBox/Expression/Operator2

@onready var confirm_button: Button = $UI/Screen/VBox/ConfirmButton
@onready var result_label: Label = $UI/Screen/VBox/ResultLabel
@onready var screen: Control = $UI/Screen

@onready var dialog_box: Panel = $UI/Screen/DialogBox
@onready var dialog_title: Label = $UI/Screen/DialogBox/DialogVBox/DialogTitle
@onready var dialog_text: Label = $UI/Screen/DialogBox/DialogVBox/DialogText
@onready var dialog_button: Button = $UI/Screen/DialogBox/DialogVBox/DialogButtons/DialogButton
@onready var dialog_button2: Button = $UI/Screen/DialogBox/DialogVBox/DialogButtons/DialogButton2

@onready var round_timer: Timer = $RoundTimer
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var success_sound: AudioStreamPlayer = $SuccessSound
@onready var error_sound: AudioStreamPlayer = $ErrorSound
@onready var gameover_sound: AudioStreamPlayer = $GameOverSound

var gm: GameManager

var number1 := 0
var number2 := 0
var number3 := 0
var time_left := 0.0

## true só enquanto a rodada aceita resposta. Corrige o bug do placar:
## depois de um acerto ou do tempo esgotado, CONFIRMAR não pontua mais.
var round_active := false
var calibrating := false
var calibration_errors := 0

## Muda a cada vez que o painel abre/fecha. Esperas (await) antigas
## comparam esse número e são ignoradas se o painel já foi fechado.
var session := 0

var _dialog_lines: Array = []
var _dialog_index := 0
var _dialog_done: Callable
var _dialog_alt: Callable
var _dialog_done_text := "CONTINUAR"


func _ready() -> void:
	visible = false
	# owner = cena Main (o painel é instanciado dentro dela)
	gm = owner.get_node("GameManager") as GameManager

	confirm_button.pressed.connect(_on_confirm_pressed)
	confirm_button.mouse_entered.connect(_on_confirm_button_mouse_entered)
	confirm_button.mouse_exited.connect(_on_confirm_button_mouse_exited)
	round_timer.timeout.connect(_on_timer_tick)
	dialog_button.pressed.connect(_on_dialog_button_pressed)
	dialog_button2.pressed.connect(_on_dialog_button2_pressed)
	operator1.item_selected.connect(_on_operator_selected)
	operator2.item_selected.connect(_on_operator_selected)

	# Itens da lista dos seletores também maiores
	for op in [operator1, operator2]:
		op.get_popup().add_theme_font_size_override("font_size", 40)

	gm.score_changed.connect(_on_score_changed)
	gm.progress_changed.connect(_on_progress_changed)
	_on_score_changed(gm.score, gm.record)
	_on_progress_changed(gm.hits_in_sector, gm.sector)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_panel()


# ---------------------------------------------------------------- abrir / fechar

func open_panel() -> void:
	if visible:
		return
	session += 1
	visible = true
	_set_player_can_move(false)

	if not gm.tutorial_done:
		_start_tutorial()
	else:
		start_new_round()


func close_panel() -> void:
	session += 1
	round_active = false
	round_timer.stop()
	dialog_box.visible = false
	visible = false
	_set_player_can_move(true)


func _set_player_can_move(value: bool) -> void:
	var player = owner.get_node_or_null("Player")
	if player:
		player.can_move = value


# ---------------------------------------------------------------- tutorial

func _start_tutorial() -> void:
	_show_dialog([
		"ALERTA! A linha de produção parou. Meus circuitos perderam a calibração.",
		"Você é o operário de plantão. Para religar a fábrica, cada conta do painel precisa dar exatamente 5.",
		"Eu mostro 3 números. Voce escolhe as 2 operações entre eles (+  -  *  /) e aperta CONFIRMAR.",
		"Atenção: * e / são calculados ANTES de + e -. Exemplo: 1 * 9 - 4 = 5.",
		"Vamos calibrar sem pressa: esta primeira conta NÃO tem tempo.",
	], _start_calibration)


func _start_calibration() -> void:
	calibrating = true
	calibration_errors = 0
	_set_numbers(CALIBRATION_ROUND)
	timer_label.text = "TEMPO: --"
	sector_label.text = "CALIBRAÇÃO (SEM TEMPO)"
	_reset_round_ui()
	round_active = true


func _finish_calibration() -> void:
	calibrating = false
	gm.complete_tutorial()
	_show_dialog([
		"Calibração concluída! Senti a energia voltar.",
		"A fábrica tem 4 setores. A cada %d acertos eu religo um setor. Começamos pela %s: só soma e subtração." % [GameManager.HITS_PER_SECTOR, gm.sector_name(0)],
		"Agora o relógio está valendo. Acertos rapidos dao pontos extras. Boa sorte, operário!",
	], start_new_round)


# ---------------------------------------------------------------- rodadas

func start_new_round() -> void:
	if not visible:
		return
	_set_numbers(gm.next_round())
	_reset_round_ui()
	time_left = gm.round_time
	_update_timer_label()
	_on_progress_changed(gm.hits_in_sector, gm.sector)
	round_active = true
	round_timer.start()


func _set_numbers(trio: Array) -> void:
	number1 = trio[0]
	number2 = trio[1]
	number3 = trio[2]
	number1_label1.text = str(number1)
	number2_label2.text = str(number2)
	number3_label3.text = str(number3)


func _reset_round_ui() -> void:
	operator1.select(0)
	operator2.select(0)
	result_label.text = "Escolha as operações e confirme"
	result_label.modulate = Color.WHITE
	confirm_button.disabled = false


func _on_timer_tick() -> void:
	if not round_active:
		round_timer.stop()
		return
	time_left = max(time_left - round_timer.wait_time, 0.0)
	_update_timer_label()
	if time_left <= 0.0:
		_on_time_up()


func _update_timer_label() -> void:
	timer_label.text = "TEMPO: %.1f" % time_left
	timer_label.modulate = Color(1, 0.4, 0.4) if time_left <= 3.0 else Color.WHITE


func _on_time_up() -> void:
	round_active = false
	round_timer.stop()
	confirm_button.disabled = true
	gameover_sound.play()
	result_label.text = "TEMPO ESGOTADO! A conta era possível, tente a próxima."
	result_label.modulate = Color(1, 0.6, 0.2)
	shake_panel()
	_next_round_after_pause()


func _on_confirm_pressed() -> void:
	# Trava do placar: só aceita resposta com a rodada ativa.
	if not round_active:
		return
	click_sound.play()
	_press_animation()

	var op1 := operator1.get_item_text(operator1.selected)
	var op2 := operator2.get_item_text(operator2.selected)
	var result := GameManager.evaluate_expression(number1, op1, number2, op2, number3)
	var expression := "%d %s %d %s %d = %s" % [number1, op1, number2, op2, number3, _format_number(result)]

	if GameManager.is_target(result):
		round_active = false          # trava ANTES de qualquer espera
		round_timer.stop()
		confirm_button.disabled = true
		success_sound.play()
		result_label.modulate = Color.GREEN
		success_effect()
		result_bounce()

		if calibrating:
			result_label.text = expression + "  CORRETO!"
			var calib_session := session
			await _wait(ROUND_PAUSE)
			if _is_current(calib_session):
				_finish_calibration()
			return

		var sector_before := gm.sector
		var points := gm.register_hit(time_left)
		result_label.text = expression + "  CORRETO! +%d" % points

		if gm.sector != sector_before:
			_announce_sector(sector_before)
		else:
			_next_round_after_pause()
	else:
		error_sound.play()
		result_label.text = expression + "  ERRADO, tente de novo"
		result_label.modulate = Color.RED
		shake_panel()
		if calibrating:
			calibration_errors += 1
			if calibration_errors >= 2:
				result_label.text += "\nDica: só precisa de + e -"


func _next_round_after_pause() -> void:
	var my_session := session
	await _wait(ROUND_PAUSE)
	if _is_current(my_session):
		start_new_round()


func _announce_sector(restored_index: int) -> void:
	var my_session := session
	await _wait(ROUND_PAUSE)
	if not _is_current(my_session):
		return

	if gm.is_factory_restored():
		_show_dialog([
			"FÁBRICA RELIGADA! Todos os 4 setores voltaram a produzir.",
			"Pontuação final: %d   |   Recorde: %d" % [gm.score, gm.record],
		], _continue_endless, "JOGAR MAIS", "MENU", _go_to_menu)
		return

	var next_index := restored_index + 1
	_show_dialog([
		"Setor %d - %s religado! As luzes dele voltaram." % [restored_index + 1, gm.sector_name(restored_index)],
		"Próximo: setor %d - %s. %s" % [next_index + 1, gm.sector_name(next_index), GameManager.SECTORS[next_index]["info"]],
	], start_new_round)


func _continue_endless() -> void:
	start_new_round()


func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_operator_selected(_index: int) -> void:
	click_sound.play()


# ---------------------------------------------------------------- HUD do painel

func _on_score_changed(score: int, _record: int) -> void:
	score_label.text = "PONTOS: %d" % score


func _on_progress_changed(hits: int, sector_index: int) -> void:
	if calibrating:
		return
	if sector_index >= GameManager.SECTORS.size():
		sector_label.text = "FÁBRICA RELIGADA - MODO INFINITO"
		sector_bar.value = sector_bar.max_value
		return
	sector_label.text = "SETOR %d/4 - %s   (%d/%d acertos)" % [sector_index + 1, gm.sector_name(sector_index).to_upper(), hits, GameManager.HITS_PER_SECTOR]
	sector_bar.max_value = GameManager.HITS_PER_SECTOR
	sector_bar.value = hits


# ---------------------------------------------------------------- caixa de fala

func _show_dialog(lines: Array, on_done: Callable, done_text := "CONTINUAR", alt_text := "", on_alt := Callable()) -> void:
	round_active = false
	round_timer.stop()
	_dialog_lines = lines
	_dialog_index = 0
	_dialog_done = on_done
	_dialog_alt = on_alt
	_dialog_done_text = done_text
	dialog_title.text = "MÁQUINA"
	dialog_button2.text = alt_text
	dialog_button2.visible = false
	dialog_box.visible = true
	_show_dialog_line()


func _show_dialog_line() -> void:
	dialog_text.text = _dialog_lines[_dialog_index]
	var is_last := _dialog_index == _dialog_lines.size() - 1
	dialog_button.text = _dialog_done_text if is_last else "CONTINUAR"
	dialog_button2.visible = is_last and _dialog_alt.is_valid()
	dialog_button.grab_focus()


func _on_dialog_button_pressed() -> void:
	click_sound.play()
	_dialog_index += 1
	if _dialog_index < _dialog_lines.size():
		_show_dialog_line()
		return
	dialog_box.visible = false
	if _dialog_done.is_valid():
		_dialog_done.call()


func _on_dialog_button2_pressed() -> void:
	click_sound.play()
	dialog_box.visible = false
	if _dialog_alt.is_valid():
		_dialog_alt.call()


# ---------------------------------------------------------------- utilitários

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _is_current(my_session: int) -> bool:
	return visible and my_session == session


func _format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return "%.2f" % value


# ---------------------------------------------------------------- animações

func shake_panel() -> void:
	var tween := create_tween()
	var original_position := screen.position
	tween.tween_property(screen, "position", original_position + Vector2(10, 0), 0.05)
	tween.tween_property(screen, "position", original_position + Vector2(-10, 0), 0.05)
	tween.tween_property(screen, "position", original_position, 0.05)


func success_effect() -> void:
	var tween := create_tween()
	screen.modulate = Color.WHITE
	tween.tween_property(screen, "modulate", Color(0.5, 1, 0.5), 0.1)
	tween.tween_property(screen, "modulate", Color.WHITE, 0.2)


func result_bounce() -> void:
	var tween := create_tween()
	result_label.pivot_offset = result_label.size / 2
	result_label.scale = Vector2.ONE
	tween.tween_property(result_label, "scale", Vector2(1.15, 1.15), 0.1)
	tween.tween_property(result_label, "scale", Vector2.ONE, 0.1)


func _press_animation() -> void:
	var tween := create_tween()
	confirm_button.pivot_offset = confirm_button.size / 2
	tween.tween_property(confirm_button, "scale", Vector2(0.92, 0.92), 0.05)
	tween.tween_property(confirm_button, "scale", Vector2.ONE, 0.05)


func _on_confirm_button_mouse_entered() -> void:
	confirm_button.pivot_offset = confirm_button.size / 2
	create_tween().tween_property(confirm_button, "scale", Vector2(1.05, 1.05), 0.1)


func _on_confirm_button_mouse_exited() -> void:
	create_tween().tween_property(confirm_button, "scale", Vector2.ONE, 0.1)
