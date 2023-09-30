extends Node
class_name InputHandler
## InputHandler
##
## This script handle player input and convert them to signals.
## Those inputs can also be spoofed by calling appropriate functions

## Charge parameters
@export var delayBeforeCharge : float = 0.2
# time ellapsed since beginning of charge presse
var timeEllapsedSinceChargePress := 0.0
# are we charging right now
var isCharging : bool = false


# === Inputs Signals
## Emitted when a charge input is changed
signal chargeStart()
signal chargeEnd()
## Emitted when a tackle is requested
signal tackleRequested()
## Emitted when a guard input is changed
signal guardStart()
signal guardEnd()
## Emitted when a move is requested
signal moveRequested(dir : Vector2)
## Emitted when a move started
signal moveStarted()
signal moveEnded()


## Check all inputs to send appropriate signals
func _physics_process(_delta):
	# Check tackle and charge
	if Input.is_action_pressed("charge"):
		# Not charged yet, check 
		if not isCharging: 
			timeEllapsedSinceChargePress += _delta
			if timeEllapsedSinceChargePress >= delayBeforeCharge:
				# Enough time ellapsed : beginning charge
				isCharging = true
				chargeStart.emit()
	# When impulse is released, check if we emit a tackle or a charge end
	if Input.is_action_just_released("charge"):
		timeEllapsedSinceChargePress = 0.0
		if isCharging:
			chargeEnd.emit()
			isCharging = false
		else:
			tackleRequested.emit()
	
	## check guard
	if Input.is_action_just_pressed("guard"):
		guardStart.emit()
	if Input.is_action_just_released("guard"):
		guardEnd.emit()
	
	
	## check move
	var moveVector := Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if (moveVector != Vector2.ZERO):
		moveRequested.emit(moveVector)


## Function used to spoof a input signal
func spoofInput(inputName : String, value):
	match inputName:
		"charge":
			if value:
				chargeStart.emit()
			else:
				chargeEnd.emit()
		"guard":
			if value:
				guardStart.emit()
			else:
				guardEnd.emit()
		"move":
			moveRequested.emit(value)
		"tackle":
			tackleRequested.emit()
