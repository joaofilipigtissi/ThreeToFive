class_name GameManager
extends Node

## Guarda o estado da partida: pontos, recorde, setores religados e tutorial.
## Também gera as rodadas de acordo com o setor atual.

signal score_changed(score: int, record: int)
signal sector_restored(sector_index: int)
signal factory_restored
signal progress_changed(hits_in_sector: int, sector_index: int)
signal tutorial_completed

const TARGET := 5
const HITS_PER_SECTOR := 5
const START_TIME := 10.0
const MIN_TIME := 3.0
const TIME_STEP := 0.5
const BASE_POINTS := 100
const BONUS_PER_SECOND := 10
const SAVE_PATH := "user://threetofive.cfg"

const SECTORS := [
	{"name": "Recepção", "info": "Só soma e subtração."},
	{"name": "Montagem", "info": "Agora entram * e /. Lembre: eles são feitos antes de + e -."},
	{"name": "Alta Produção", "info": "Contas misturadas e o tempo cada vez menor."},
	{"name": "Núcleo Central", "info": "Só uma combinação funciona em cada conta. Tempo no limite!"},
]

const OPS := ["+", "-", "*", "/"]

var score := 0
var record := 0
var total_hits := 0
var hits_in_sector := 0
var sector := 0               # setor sendo religado (0 a 3). 4 = fábrica toda religada
var tutorial_done := false
var round_time := START_TIME

var _pools := [[], [], [], []]
var _last_round := []


func _ready() -> void:
	randomize()
	record = load_record()
	_build_pools()


# ---------------------------------------------------------------- rodadas

func _build_pools() -> void:
	# Percorre todos os trios de 1 a 9 e separa por dificuldade.
	for a in range(1, 10):
		for b in range(1, 10):
			for c in range(1, 10):
				var solutions := []
				for op1 in OPS:
					for op2 in OPS:
						if is_target(evaluate_expression(a, op1, b, op2, c)):
							solutions.append([op1, op2])
				if solutions.is_empty():
					continue
				var has_plus_minus := false
				for s in solutions:
					if s[0] in ["+", "-"] and s[1] in ["+", "-"]:
						has_plus_minus = true
				var trio := [a, b, c]
				if has_plus_minus:
					_pools[0].append(trio)          # Recepção: resolve só com + e -
				else:
					_pools[1].append(trio)          # Montagem: exige * ou /
				_pools[2].append(trio)              # Alta Produção: qualquer conta com solução
				if solutions.size() == 1:
					_pools[3].append(trio)          # Núcleo Central: uma única solução


func next_round() -> Array:
	var pool: Array = _pools[min(sector, 3)]
	var trio: Array = pool.pick_random()
	if trio == _last_round and pool.size() > 1:
		trio = pool.pick_random()
	_last_round = trio
	return trio


static func is_target(value) -> bool:
	return abs(float(value) - TARGET) < 0.0001


static func evaluate_expression(a, op1: String, b, op2: String, c) -> float:
	# Respeita a precedência: * e / antes de + e -
	if op1 == "*" or op1 == "/":
		return calculate(calculate(a, op1, b), op2, c)
	elif op2 == "*" or op2 == "/":
		return calculate(a, op1, calculate(b, op2, c))
	return calculate(calculate(a, op1, b), op2, c)


static func calculate(x, op: String, y) -> float:
	match op:
		"+":
			return float(x) + float(y)
		"-":
			return float(x) - float(y)
		"*":
			return float(x) * float(y)
		"/":
			if float(y) == 0.0:
				return 0.0
			return float(x) / float(y)
	return 0.0


# ---------------------------------------------------------------- pontuação

## Registra um acerto. Retorna os pontos ganhos.
func register_hit(time_left: float) -> int:
	var points := BASE_POINTS + BONUS_PER_SECOND * int(max(time_left, 0.0))
	score += points
	total_hits += 1
	round_time = max(MIN_TIME, START_TIME - TIME_STEP * total_hits)

	if score > record:
		record = score
		save_record(record)
	score_changed.emit(score, record)

	if sector < SECTORS.size():
		hits_in_sector += 1
		if hits_in_sector >= HITS_PER_SECTOR:
			hits_in_sector = 0
			sector += 1
			sector_restored.emit(sector - 1)
			if sector >= SECTORS.size():
				factory_restored.emit()
		progress_changed.emit(hits_in_sector, sector)
	return points


func complete_tutorial() -> void:
	tutorial_done = true
	tutorial_completed.emit()


func is_factory_restored() -> bool:
	return sector >= SECTORS.size()


func sector_name(index: int) -> String:
	if index >= SECTORS.size():
		return "Fábrica religada"
	return SECTORS[index]["name"]


func reset() -> void:
	score = 0
	total_hits = 0
	hits_in_sector = 0
	sector = 0
	round_time = START_TIME
	score_changed.emit(score, record)
	progress_changed.emit(hits_in_sector, sector)


# ---------------------------------------------------------------- recorde

static func load_record() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return 0
	return int(cfg.get_value("score", "record", 0))


static func save_record(value: int) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("score", "record", value)
	cfg.save(SAVE_PATH)
