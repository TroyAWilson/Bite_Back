extends Node2D

@export var player: CharacterBody2D 

func _ready() -> void:
	AudioController.play_bkg()

func _process(delta: float) -> void:
	var dir_input = round(Input.get_vector("move_left","move_right","move_up","move_down"))
	match dir_input:
		Vector2(0,1):
			if not GameController.downCheck:
				GameController.downCheck = true
				player._updateCheckIcon('down')
		Vector2(0,-1):
			if not GameController.upCheck:
				GameController.upCheck = true
				player._updateCheckIcon('up')
		Vector2(1,0):
			if not GameController.rightCheck:
				GameController.rightCheck = true
				player._updateCheckIcon('right')
		Vector2(-1,0):
			if not GameController.leftCheck:
				GameController.leftCheck = true
				player._updateCheckIcon('left')
			
	if Input.is_action_just_pressed("attack"):
		if not GameController.attackCheck:
			GameController.attackCheck = true
			player._updateCheckIcon('attack')
		
	if player.dashing == true:
		if not GameController.dashCheck:
			GameController.dashCheck = true
			player._updateCheckIcon('dash')
