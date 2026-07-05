extends Area2D
class_name HurtBox

signal hurt()
signal died()

@export var health := 3

func get_damage(dmg: int) -> void:
	health -= dmg
	hurt.emit()
	
	if health <= 0:
		died.emit()
