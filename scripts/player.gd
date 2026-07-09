extends CharacterBody2D

const SPEED = 300.0

@onready var AP := $AnimationPlayer
@onready var playerSprite := $Sprite2D
@onready var dust := $GPUParticles2D
@onready var youDied := $you_died
@onready var youDied2 := $you_died2
@onready var restart := $Restart 

enum State {IDLE, ATTACKING, RUNNING, DASHING, DEAD} #maybe add damaged later
var currentState = State.IDLE
var lastDirection : Vector2 #might be unnecessary


@export var afterImageScene : PackedScene
var afterImageInterval := 0.35
var dashing := false
var canDash := true
var dashCooldown := 0.35
var dashDir := Vector2.ZERO
var dashTime := 0.2
var dashSpeed := 520
var afterImageTimer := 0.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if currentState == State.DEAD:
		return
	
	if currentState == State.ATTACKING:
		dust.emitting = false
		return
		
	var dir_input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	if dir_input != Vector2.ZERO:
		lastDirection = dir_input
	
	if Input.is_action_just_pressed("attack") and currentState != State.ATTACKING:
		velocity = Vector2.ZERO
		currentState = State.ATTACKING
		
		if not dir_input:
			dir_input = lastDirection
		
		match dir_input:
			Vector2(0,1):
				playAnimation('attack_D')
			Vector2(0,-1):
				playAnimation('attack_U')
			Vector2(1,0):
				playAnimation('attack_R')
			Vector2(-1,0):
				playAnimation('attack_L')
			_:
				playAnimation('attack_D') #maybe if I have time add like a neural spin attk
		AudioController.play_swing()
		await AP.animation_finished
		currentState = State.IDLE
		
	if dir_input and Input.is_action_just_pressed("ui_accept") and canDash:
		dash(dir_input)
		
	if dashing:
		afterImageTimer -= delta
		if afterImageTimer <= 0.0:
			spawnAfterImage()
			afterImageTimer = afterImageInterval
		velocity = dashDir * dashSpeed
		
	if dir_input and not dashing:
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
				playAnimation('run_right')
			Vector2(-1,0):
				dust.emitting = true
				dust.position.x = 10
				dust.process_material.gravity = Vector3(50,0,0)
				playAnimation('run_left')
		
		velocity = dir_input.normalized() * SPEED
	else:
		print(lastDirection, dir_input)
		match lastDirection:
			Vector2(0,1):
				playAnimation('idle')
			Vector2(0,-1):
				playAnimation('idle_U')
			Vector2(1,0):
				playAnimation('idle_R')
			Vector2(-1,0):
				playAnimation('idle_L')
			_:
				playAnimation('idle')
		
		AudioController.stop_sfx()
		dust.emitting = false
		currentState = State.IDLE
		#Sort of arbitrarily using 2 here so that it slows faster
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * 5 * delta)

	move_and_slide()

func playAnimation(animation: String) -> void:
	AP.play(animation)

func dash(dir_input: Vector2) -> void:
	if dir_input == Vector2.ZERO:
		return
	
	currentState = State.DASHING
	
	dashing = true	
	canDash = false
	dashDir = dir_input.normalized()
	afterImageTimer = 0.0
	await get_tree().create_timer(dashTime).timeout
	dashing = false
	
	await get_tree().create_timer(dashCooldown).timeout
	canDash = true

func spawnAfterImage() -> void:
	for i in range(3):
		var ghost = afterImageScene.instantiate()
		get_tree().current_scene.add_child(ghost)
		ghost.setup(playerSprite)
		await get_tree().create_timer(0.1).timeout

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
