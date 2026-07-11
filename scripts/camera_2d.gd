extends Camera2D

@export var randomStrength := 5.0
@export var shakeFade := 5.0

var rng = RandomNumberGenerator.new()

var shakeStrength := 0.0

func _process(delta: float) -> void:
	if shakeStrength > 0:
		shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
		
		offset = randomOffset()

func applyShake() -> void:
	shakeStrength = randomStrength
	
func applyLongShake() -> void:
	shakeStrength = randomStrength
	shakeFade = 3 #higher value, shorter shake
	
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
