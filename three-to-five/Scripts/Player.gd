extends CharacterBody2D

@export var speed := 180.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction := "down"

var can_move = true

func _physics_process(delta):

	if !can_move:
		velocity = Vector2.ZERO
		move_and_slide()
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

func update_animation(direction: Vector2):

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
