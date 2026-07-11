extends CharacterBody2D

@export var player : CharacterBody2D

@onready var shadow := $shadow
@onready var hand := $hand
@onready var col := $CollisionShape2D
@onready var AP := $AnimationPlayer

var SPEED := 200

var pursue := false
var looping := false
var enemyHealth := 1 # should be atleast 10
var dead := false
var playerCamera : Camera2D
var completedInitialAttack := false

const handPosition = -200

func _ready() -> void:
	playerCamera = player.get_node("Camera2D")
	hand.visible = false
	shadow.modulate.a = 0.0
	#start_attack()

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	if GameController.playerReady and not completedInitialAttack:
		completedInitialAttack = true
		await get_tree().create_timer(1).timeout
		start_attack()
	
	if pursue:
		var dir = (player.global_position - global_position).normalized()
		if dir == Vector2.ZERO:
			return
		print(dir)
		velocity = dir * SPEED
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _atk_loop() -> void:
	looping = true
	while not dead:
		await get_tree().create_timer(8.0).timeout
		start_attack()

func start_attack() -> void:
	if dead:
		return	
	
	if enemyHealth <= int(enemyHealth/2) and SPEED < 250:
		SPEED = 250
	
	pursue = true
	
	var playerLocation = player.global_position
	global_position = playerLocation
	
	var tween := create_tween()
	
	tween.tween_property(shadow, "modulate:a", 0.65, 1.0)
	tween.parallel().tween_property(shadow, "scale", Vector2(2.0, 2.0), 2.0)

	tween.tween_callback(_slam)
	tween.tween_interval(3.0)

	tween.tween_callback(_retract)
	tween.tween_interval(0.7)
	
	if not looping:
		_atk_loop()

func _slam() -> void:
	pursue = false
	
	hand.visible = true
	hand.position.y = handPosition
	
	col.disabled = false
	
	var slam_tween := create_tween()
	slam_tween.tween_property(hand, "position:y", -25, 0.08)
	slam_tween.tween_property(hand,  "modulate:a", 1.0, 0.1)
	
	AP.play('slam')
	screenShake() 
	await AP.animation_finished
	AP.play('idle')
	
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
