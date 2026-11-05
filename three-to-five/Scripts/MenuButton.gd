extends Button

@export var hover_scale: float = 1.08
@export var animation_speed: float = 0.10

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_mouse_entered():
	animate_scale(Vector2(hover_scale, hover_scale))

func _on_mouse_exited():
	animate_scale(Vector2.ONE)

func _on_button_down():
	animate_scale(Vector2(hover_scale - 0.05, hover_scale - 0.05))

func _on_button_up():
	if is_hovered():
		animate_scale(Vector2(hover_scale, hover_scale))
	else:
		animate_scale(Vector2.ONE)

func animate_scale(target_scale: Vector2):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", target_scale, animation_speed)
