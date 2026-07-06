extends CharacterBody2D

const SPEED = 300.0

@onready var AP := $AnimationPlayer
@onready var playerSprite := $Sprite2D
@onready var dust := $GPUParticles2D
@onready var youDied := $you_died
@onready var youDied2 := $you_died2
@onready var restart := $Restart 

enum State {IDLE, ATTACKING, RUNNING, DEAD} #maybe add damaged later
var currentState = State.IDLE
var lastDirection : Vector2 #might be unnecessary

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if currentState == State.DEAD:
		return
	
	if currentState == State.ATTACKING:
		dust.emitting = false
		return
		
	var dir_input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	lastDirection = dir_input
	
	if Input.is_action_just_pressed("attack") and currentState != State.ATTACKING:
		velocity = Vector2(0,0)
		currentState = State.ATTACKING
		
		if not dir_input:
			dir_input = lastDirection
		
		match dir_input:
			Vector2(1,0):
				playAnimation('attack_R')
				AudioController.play_swing()
			Vector2(-1,0):
				playAnimation('attack_L')
				AudioController.play_swing()
			_:
				playAnimation('attack_L') #maybe if I have time add like a neural spin attk
		await AP.animation_finished
		currentState = State.IDLE
		
	if dir_input:
		if not AudioController.sfx_player.playing:
			AudioController.playFootsteps()
		currentState = State.RUNNING
		match dir_input:
			Vector2(0,1):
				playAnimation('run_down')
				dust.emitting = true
				dust.position.y = -10
				dust.process_material.gravity = Vector3(0,-50,0)
			Vector2(0,-1):
				playAnimation('run_up')
				dust.emitting = true
				dust.position.y = 10
				dust.process_material.gravity = Vector3(0,50,0)
			Vector2(1,0):
				dust.emitting = true
				dust.position.x = -10
				dust.process_material.gravity = Vector3(-50,0,0)
				if not playerSprite.flip_h:
					playerSprite.flip_h = true
				playAnimation('run_right')
			Vector2(-1,0):
				dust.emitting = true
				dust.position.x = 10
				dust.process_material.gravity = Vector3(50,0,0)
				if playerSprite.flip_h:
					playerSprite.flip_h = false	
				playAnimation('run_left')
		
		velocity = dir_input.normalized() * SPEED
	else:
		AudioController.stop_sfx()
		dust.emitting = false
		currentState = State.IDLE
		#Sort of arbitrarily using 2 here so that it slows faster
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * 10 * delta)
		if velocity == Vector2(0,0):
			playAnimation('idle')

	move_and_slide()

func playAnimation(animation: String) -> void:
	AP.play(animation)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method('_takeDamage'):
		body._takeDamage(1)
		AudioController.play_slash()
		
func takeDamage() -> void:
	currentState = State.DEAD
	playAnimation('die')
	youDied.visible = true
	youDied2.visible = true
	restart.visible = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
