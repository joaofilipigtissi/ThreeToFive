extends Control

@onready var play_button = $CenterContainer/VBoxContainer/PlayButton
@onready var exit_button = $CenterContainer/VBoxContainer/ExitButton
@onready var click_sound = $ClickSound

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	click_sound.play()

	await get_tree().create_timer(0.15).timeout

	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_exit_pressed():
	click_sound.play()

	await get_tree().create_timer(0.15).timeout

	get_tree().quit()
