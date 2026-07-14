extends Node2D

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _ready() -> void:
	AudioController.play_music(AudioController.menu, -35)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("dash"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")
