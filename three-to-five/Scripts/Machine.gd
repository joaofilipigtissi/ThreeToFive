extends Node2D

@onready var label = $Label

var player_near = false

func _ready():
	label.visible = false

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_near = true
		label.visible = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_near = false
		label.visible = false

func _process(delta):

	if player_near and Input.is_action_just_pressed("interact"):
		open_machine()

func open_machine():

	label.visible = false

	var panel = get_tree().current_scene.get_node("UI/MachinePanel")

	panel.open_panel()

	var player = get_tree().current_scene.get_node("Player")

	player.can_move = false
