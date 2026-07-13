extends CharacterBody2D

@export var player : CharacterBody2D

@onready var shadow := $shadow
@onready var hand := $hand
@onready var col := $CollisionShape2D
@onready var AP := $AnimationPlayer
@onready var dangerZone := $dangerZone

var SPEED := 100

var pursue := false
var looping := false
var enemyHealth := 10 # should be atleast 10
var dead := false
var playerCamera : Camera2D
var completedInitialAttack := false

const handPosition = -200

enum State {IDLE, ATTACKING, DEAD, PHASE2}
var enemyState = State.IDLE
var phase2 = false
var intervalSpeed = 2.0

func _ready() -> void:
	playerCamera = player.get_node("Camera2D")
	hand.visible = false
	shadow.modulate.a = 0.0
	col.disabled = true

func _physics_process(delta: float) -> void:
	if dead or enemyState == State.DEAD:

		return
		
	if GameController.playerReady and enemyState != State.ATTACKING:
		await get_tree().create_timer(intervalSpeed).timeout
		start_attack()
	
	if pursue:
		var dir = (player.global_position - global_position).normalized()
		if dir == Vector2.ZERO:
			return
		velocity = dir * SPEED
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func start_attack() -> void:	
	if dead or enemyState == State.DEAD or enemyState == State.ATTACKING:
		return
	else:
		enemyState = State.ATTACKING
	
	var atk := 0
	var tween := create_tween()
	
	if phase2:
		atk = randi_range(0,1)
		intervalSpeed = 1.0
	
	match atk:
		0:
			col.disabled = true
			pursue = true
			tween.tween_property(shadow, "modulate:a", 0.65, 1.0)
			tween.parallel().tween_property(shadow, "scale", Vector2(2.0, 2.0), 2.0)
			
			tween.tween_callback(_slam)
			tween.tween_interval(intervalSpeed)

			tween.tween_callback(_retract)
			tween.tween_interval(0.7)
		1:
			pursue = false
			tween.tween_callback(_swipe)
			tween.tween_interval(intervalSpeed)
			
	if enemyHealth <= 5 and SPEED < 130:
		phase2 = true
		SPEED = 130

func _slam() -> void:
	pursue = false
	
	hand.visible = true
	hand.position.y = handPosition
	
	AP.play('slam')
	screenShake() 
	await AP.animation_finished
	AP.play('idle')
	await get_tree().create_timer(2).timeout	
	enemyState = State.IDLE
	
func _swipe() -> void:
	pursue = false
	
	var AorB = randi_range(0,1)
	var dangerSign
	var swipeAnim
	position = Vector2.ZERO
	match AorB:
		0:
			dangerSign = player.get_node("dangerA")
			swipeAnim = "swipeA"
			dangerZone.position.y = 80
		1:
			dangerSign = player.get_node("dangerB")
			swipeAnim = "swipeB"
			dangerZone.position.y = -60
			
	print(dangerZone.position)
	print(hand.position)
	print(position)
	var swipe_tween := create_tween()
	swipe_tween.tween_property(hand,  "modulate:a", 1.0, 0.1)
	#hand.visible = true
	
	#danger sign
	dangerSign.visible = true
	dangerZone.visible = true
	await get_tree().create_timer(1.5).timeout
	dangerZone.visible = false
	dangerSign.visible = false
	
	#hand.position = Vector2.ZERO
	AP.play(swipeAnim)
	await AP.animation_finished
	hand.visible = false
	enemyState = State.IDLE
	
func _retract() -> void:
	var tween := create_tween()
	
	tween.tween_property(hand, "position:y", handPosition, 0.25)
	tween.tween_property(hand,  "modulate:a", 0.0, 1.0)
	
	col.disabled = true
	
	tween.parallel().tween_property(shadow, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(shadow, "scale", Vector2(0.0, 0.0), 1.0)

func _takeDamage(dmg:int) -> void:
	#color the hand
	var c = hand.modulate
	var tween = create_tween()
	tween.tween_property(hand, "modulate", Color(1, 0, 0, 1), 0.1)
	await get_tree().create_timer(0.2).timeout
	hand.modulate = c
	
	screenShake()
	
	#damage
	enemyHealth -= dmg
	if enemyHealth <= 0:
		_die()
		
func _die() -> void:
	player.playAnimation('idle')
	
	for tween in get_tree().get_processed_tweens():
		print(tween)
		if tween.is_valid():
				tween.kill()
	
	dead = true
	pursue = false
	velocity = Vector2.ZERO
	col.disabled = true
	playerCamera.applyLongShake() #might need to make this shake slightly less
	AudioController.stop_music()
	player.playerHasControl = false
	Engine.time_scale = 0.5
	AudioController.playBossDie()
	
	AP.play("die")
	await AP.animation_finished
	
	Engine.time_scale = 1
	player.playAnimation('victory')
	
	player.youWin.visible = true
	player.youWin2.visible = true
	
	player.restart.visible = true
	AudioController.play_music(AudioController.victory)
	#TODO I'd love a little spin and thumbs up animation of the player
	
	
	
	queue_free()
		
func screenShake() -> void:
	if not playerCamera:
		return
		
	if playerCamera.has_method("applyShake"):
		playerCamera.applyShake()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body == player:
		if player.has_method('takeDamage'):
			player.takeDamage()
