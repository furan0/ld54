extends Camera2D

@export var decay = 0.8  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
@export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

var force = 0.0  # Current shake strength.
var force_power = 2  # Trauma exponent. Use [2, 3].

func doShake(amount):
	force = min(force + amount, 1.0)

func shake():
	var amount = pow(force, force_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)

func _process(delta):
	if force:
		force = max(force - decay * delta, 0)
		shake()
