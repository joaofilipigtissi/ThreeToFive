extends Node2D

## Máquina da fábrica: mostra "Pressione E", abre o painel e
## mostra o progresso com 4 luzes de setor e o som do motor.

const LAMP_OFF := Color(0.35, 0.08, 0.08)
const LAMP_ON := Color(0.3, 1.0, 0.35)

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D

var player_near := false
var lamps: Array[ColorRect] = []
var hum: AudioStreamPlayer2D


func _ready() -> void:
	label.visible = false
	_create_lamps()
	_create_hum()

	var gm: GameManager = null
	if owner:
		gm = owner.get_node_or_null("GameManager") as GameManager
	if gm:
		gm.sector_restored.connect(_on_sector_restored)
	update_power(0)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_near = false


func _process(_delta: float) -> void:
	var panel := _get_panel()
	var panel_open := panel != null and panel.visible
	label.visible = player_near and not panel_open

	if player_near and not panel_open and Input.is_action_just_pressed("interact"):
		open_machine()


func open_machine() -> void:
	var panel = _get_panel()
	if panel:
		panel.open_panel()


func _get_panel() -> Control:
	if owner == null:
		return null
	return owner.get_node_or_null("UI/MachinePanel") as Control


# ---------------------------------------------------------------- luzes e som

func _create_lamps() -> void:
	for i in 4:
		var lamp := ColorRect.new()
		lamp.size = Vector2(8, 8)
		lamp.position = Vector2(-22 + i * 12, -60)
		lamp.color = LAMP_OFF
		add_child(lamp)
		lamps.append(lamp)


func _create_hum() -> void:
	hum = AudioStreamPlayer2D.new()
	hum.stream = load("res://sounds/machine_hum.wav")
	hum.max_distance = 1400.0
	add_child(hum)
	hum.finished.connect(hum.play)   # repete o som em loop
	hum.play()


## restored = quantos setores já foram religados (0 a 4)
func update_power(restored: int) -> void:
	var power := float(restored) / 4.0
	sprite.modulate = Color(0.55, 0.55, 0.6).lerp(Color.WHITE, power)
	hum.pitch_scale = lerp(0.7, 1.1, power)
	hum.volume_db = lerp(-20.0, -8.0, power)


func _on_sector_restored(sector_index: int) -> void:
	var lamp := lamps[sector_index]
	var tween := create_tween()
	for i in 3:
		tween.tween_property(lamp, "color", LAMP_ON, 0.12)
		tween.tween_property(lamp, "color", LAMP_OFF, 0.12)
	tween.tween_property(lamp, "color", LAMP_ON, 0.12)
	update_power(sector_index + 1)
