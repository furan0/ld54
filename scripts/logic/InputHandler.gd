extends Node
class_name InputHandler
## InputHandler
##
## This script handle player input and convert them to signals.
## Those inputs can also be spoofed by calling appropriate functions

# === Inputs Signals
## Emitted when a charge/tackle input is changed
signal chargeStatusUpdated(status : bool)
## Emitted when a guard input is changed
signal guardStatusUpdated(status : bool)
## Emitted when a move is requested
signal moveRequested(dir : Vector2)


## Check all inputs to send appropriate signals
func _process(_delta):
	## check charge
	if Input.is_action_just_pressed("charge"):
		chargeStatusUpdated.emit(true)
	if Input.is_action_just_released("charge"):
		chargeStatusUpdated.emit(false)
	
	## check guard
	if Input.is_action_just_pressed("guard"):
		guardStatusUpdated.emit(true)
	if Input.is_action_just_released("guard"):
		guardStatusUpdated.emit(false)
	
	
	## check move
	var moveVector := Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if (moveVector != Vector2.ZERO):
		moveRequested.emit(moveVector)


## Function used to spoof a input signal
func spoofInput(inputName : String, value):
	match inputName:
		"charge":
			chargeStatusUpdated.emit(value)
		"guard":
			guardStatusUpdated.emit(value)
		"move":
			moveRequested.emit(value)
