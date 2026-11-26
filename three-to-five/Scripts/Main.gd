extends Node2D

## Cena da fábrica: cria as paredes da sala, controla o HUD
## e "acende" a fábrica conforme os setores são religados.

## Área onde o operário pode andar, em fração da imagem de fundo
## (0 = borda esquerda/topo, 1 = borda direita/base).
@export var walk_left := 0.14
@export var walk_right := 0.86
@export var walk_top := 0.07
@export var walk_bottom := 0.97

const DARK := Color(0.45, 0.45, 0.55)
const WALL_THICKNESS := 400.0

@onready var background: Sprite2D = $Background
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var player: CharacterBody2D = $Player
@onready var gm: GameManager = $GameManager
@onready var panel: Control = $UI/MachinePanel
@onready var sector_sound: AudioStreamPlayer = $Audio/SectorSound

@onready var hud_score: Label = $UI/HUD/StatusPanel/VBox/ScoreLabel
@onready var hud_record: Label = $UI/HUD/StatusPanel/VBox/RecordLabel
@onready var hud_sector: Label = $UI/HUD/StatusPanel/VBox/SectorLabel
@onready var hud_objective: Label = $UI/HUD/ObjectiveLabel


func _ready() -> void:
	var room := _room_rect()
	_build_walls(room)
	_limit_camera(room)

	sector_sound.stream = load("res://sounds/sector_up.wav")
	canvas_modulate.color = DARK

	gm.score_changed.connect(_on_score_changed)
	gm.sector_restored.connect(_on_sector_restored)
	gm.tutorial_completed.connect(_update_objective)
	_on_score_changed(gm.score, gm.record)
	_update_objective()


func _unhandled_input(event: InputEvent) -> void:
	# ESC fora do painel volta ao menu
	if event.is_action_pressed("ui_cancel") and not panel.visible:
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


# ---------------------------------------------------------------- sala

func _room_rect() -> Rect2:
	var r := background.get_rect()
	var top_left := background.to_global(r.position)
	var bottom_right := background.to_global(r.end)
	return Rect2(top_left, bottom_right - top_left)


func _build_walls(room: Rect2) -> void:
	var inner := Rect2(
		room.position + room.size * Vector2(walk_left, walk_top),
		room.size * Vector2(walk_right - walk_left, walk_bottom - walk_top)
	)
	var t := WALL_THICKNESS
	var walls := StaticBody2D.new()
	walls.name = "Walls"
	add_child(walls)
	# esquerda, direita, cima, baixo
	_add_wall(walls, Rect2(inner.position.x - t, inner.position.y - t, t, inner.size.y + 2 * t))
	_add_wall(walls, Rect2(inner.end.x, inner.position.y - t, t, inner.size.y + 2 * t))
	_add_wall(walls, Rect2(inner.position.x, inner.position.y - t, inner.size.x, t))
	_add_wall(walls, Rect2(inner.position.x, inner.end.y, inner.size.x, t))


func _add_wall(body: StaticBody2D, rect: Rect2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = rect.get_center()
	body.add_child(collision)


func _limit_camera(room: Rect2) -> void:
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return
	camera.limit_left = int(room.position.x)
	camera.limit_top = int(room.position.y)
	camera.limit_right = int(room.end.x)
	camera.limit_bottom = int(room.end.y)


# ---------------------------------------------------------------- HUD e progresso

func _on_score_changed(score: int, record: int) -> void:
	hud_score.text = "PONTOS: %d" % score
	hud_record.text = "RECORDE: %d" % record


func _on_sector_restored(sector_index: int) -> void:
	sector_sound.play()
	var restored := sector_index + 1
	var target_color := DARK.lerp(Color.WHITE, float(restored) / GameManager.SECTORS.size())
	create_tween().tween_property(canvas_modulate, "color", target_color, 1.5)
	_update_objective()


func _update_objective() -> void:
	var restored: int = min(gm.sector, GameManager.SECTORS.size())
	hud_sector.text = "SETORES RELIGADOS: %d/%d" % [restored, GameManager.SECTORS.size()]
	if not gm.tutorial_done:
		hud_objective.text = "OBJETIVO: vá até a máquina e aperte E"
	elif gm.is_factory_restored():
		hud_objective.text = "FÁBRICA RELIGADA! Continue jogando para bater o recorde"
	else:
		hud_objective.text = "OBJETIVO: religar o setor %d - %s" % [gm.sector + 1, gm.sector_name(gm.sector)]
