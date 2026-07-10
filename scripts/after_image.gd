extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

@export var fade_time := 0.25

func setup(source_sprite: Sprite2D):
	global_position = source_sprite.global_position
	global_rotation = source_sprite.global_rotation
	scale = source_sprite.global_scale

	sprite.texture = source_sprite.texture
	sprite.region_enabled = source_sprite.region_enabled
	sprite.region_rect = source_sprite.region_rect
	sprite.flip_h = source_sprite.flip_h
	sprite.flip_v = source_sprite.flip_v
	sprite.hframes = source_sprite.hframes
	sprite.vframes = source_sprite.vframes
	sprite.frame = source_sprite.frame 


	sprite.modulate = Color(0.4, 0.8, 1.0, 0.45)

	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, fade_time)
	tween.tween_callback(queue_free)
