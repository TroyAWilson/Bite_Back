extends Node2D

@export var player: CharacterBody2D 

func _ready() -> void:
	AudioController.play_bkg()

func _process(delta: float) -> void:
	var dir_input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	match dir_input:
		Vector2(0,1):
			if not GameController.downCheck:
				GameController.downCheck = true
				player._updateCheckIcon('down')
				print('down')
		Vector2(0,-1):
			if not GameController.upCheck:
				GameController.upCheck = true
				player._updateCheckIcon('up')
				print('up')
		Vector2(1,0):
			if not GameController.rightCheck:
				GameController.rightCheck = true
				player._updateCheckIcon('right')
				print('right')
		Vector2(-1,0):
			if not GameController.leftCheck:
				GameController.leftCheck = true
				player._updateCheckIcon('left')
				print('left')
			
	if Input.is_action_just_pressed("attack"):
		if not GameController.attackCheck:
			GameController.attackCheck = true
			player._updateCheckIcon('attack')
			print('attack')
		
	if Input.is_action_just_pressed("ui_accept") :
		if not GameController.dashCheck:
			GameController.dashCheck = true
			player._updateCheckIcon('dash')
			print('dash')
