extends Control

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var exit_button: Button = $CenterContainer/VBoxContainer/ExitButton
@onready var record_label: Label = $CenterContainer/VBoxContainer/RecordLabel
@onready var click_sound: AudioStreamPlayer = $ClickSound


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	record_label.text = "RECORDE: %d" % GameManager.load_record()
	play_button.grab_focus()   # Enter/Espaço também iniciam o jogo


func _on_play_pressed() -> void:
	click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_exit_pressed() -> void:
	click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
