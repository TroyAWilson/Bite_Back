extends CharacterBody2D

@export var player : CharacterBody2D
const SPEED := 100

@onready var shadow := $shadow
@onready var hand := $hand
@onready var col := $CollisionShape2D

var pursue := false
var looping := false
var enemyHealth := 10
var dead := false

func _ready() -> void:
	hand.visible = false
	shadow.modulate.a = 0.0
	#_atk_loop()
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
	while true:
		if dead:
			break
		
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
	
func _retract() -> void:
	var tween := create_tween()
	
	tween.tween_property(hand, "position:y", -300, 0.25)
	
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
	
	#deal damage
	enemyHealth -= dmg
	if enemyHealth <= 0:
		dead = true
