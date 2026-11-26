extends CharacterBody2D

@export var speed := 180.0
@export var step_interval := 0.32   # segundos entre um passo e outro

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction := "down"
var can_move := true

var _step_player: AudioStreamPlayer
var _step_timer := 0.0


func _ready() -> void:
	_step_player = AudioStreamPlayer.new()
	_step_player.stream = load("res://sounds/footstep.wav")
	_step_player.volume_db = -10.0
	add_child(_step_player)


func _physics_process(delta: float) -> void:

	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		sprite.play("idle_" + last_direction)
		_step_timer = 0.0
		return

	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed
	move_and_slide()

	update_animation(direction)
	_update_footsteps(delta)


func _update_footsteps(delta: float) -> void:
	if velocity.length() < 10.0:
		_step_timer = 0.0
		return
	_step_timer -= delta
	if _step_timer <= 0.0:
		_step_player.pitch_scale = randf_range(0.85, 1.15)
		_step_player.play()
		_step_timer = step_interval


func update_animation(direction: Vector2) -> void:

	if direction == Vector2.ZERO:
		sprite.play("idle_" + last_direction)
		return

	if abs(direction.x) > abs(direction.y):

		if direction.x > 0:
			last_direction = "right"
		else:
			last_direction = "left"

	else:

		if direction.y > 0:
			last_direction = "down"
		else:
			last_direction = "up"

	sprite.play("walk_" + last_direction)
