extends CharacterBody2D

@export var player : CharacterBody2D

@onready var shadow := $shadow
@onready var hand := $hand
@onready var col := $CollisionShape2D
@onready var AP := $AnimationPlayer

const SPEED := 100

var pursue := false
var looping := false
var enemyHealth := 10
var dead := false
var playerCamera : Camera2D

func _ready() -> void:
	playerCamera = player.get_node("Camera2D")
	hand.visible = false
	shadow.modulate.a = 0.0
	start_attack()

func _physics_process(delta: float) -> void:
	if dead:
		print('you win')
	
	if pursue:
		var dir = (player.global_position - global_position).normalized()
		
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
	hand.position.y = -300
	
	col.disabled = false
	
	var slam_tween := create_tween()
	slam_tween.tween_property(hand, "position:y", 0, 0.08)
	slam_tween.tween_property(hand,  "modulate:a", 1.0, 0.1)
	
	AP.play('slam')
	screenShake() 
	await AP.animation_finished
	AP.play('idle')
	
func _retract() -> void:
	var tween := create_tween()
	
	tween.tween_property(hand, "position:y", -300, 0.25)
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
		dead = true
		
func screenShake() -> void:
	if not playerCamera:
		return
		
	if playerCamera.has_method("applyShake"):
		playerCamera.applyShake()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body == player:
		if player.has_method('takeDamage'):
			player.takeDamage()
