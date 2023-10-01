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

# moving caculation
var isMoving : bool = false

## === Multiplayer handling
enum ECurrentInputProvider {PLAYER1, PLAYER2, BOTH, SPOOF_ONLY}
## Listen to this player input 
@export var inputProvider : ECurrentInputProvider = ECurrentInputProvider.PLAYER1


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
signal iscurrentlyMoving()
## Emitted when a move started
signal moveStarted()
signal moveEnded()


## Check all inputs to send appropriate signals
func _process(_delta):
	# Check tackle and charge
	if Input.is_action_pressed(getAction("charge")):
		# Not charged yet, check 
		if not isCharging: 
			timeEllapsedSinceChargePress += _delta
			if timeEllapsedSinceChargePress >= delayBeforeCharge:
				# Enough time ellapsed : beginning charge
				isCharging = true
				chargeStart.emit()
	# When impulse is released, check if we emit a tackle or a charge end
	if Input.is_action_just_released(getAction("charge")):
		timeEllapsedSinceChargePress = 0.0
		if isCharging:
			chargeEnd.emit()
			isCharging = false
		else:
			tackleRequested.emit()
	
	## check guard
	if Input.is_action_just_pressed(getAction("guard")):
		guardStart.emit()
	if Input.is_action_just_released(getAction("guard")):
		guardEnd.emit()
	
	
	## check move
	var moveVector := Vector2(Input.get_axis(getAction("left"), getAction("right")),
	 Input.get_axis(getAction("up"), getAction("down")))
	if (moveVector != Vector2.ZERO):
		moveRequested.emit(moveVector.normalized())
		iscurrentlyMoving.emit()
		if not isMoving:
			moveStarted.emit()
			isMoving = true
	elif isMoving:
		moveEnded.emit()
		isMoving = false


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
		"setMove":
			if value:
				moveStarted.emit()
			else:
				moveEnded.emit()
		"tackle":
			tackleRequested.emit()


## Map given action for each player and return the new action string
func getAction(actionName : String):
	match inputProvider:
		ECurrentInputProvider.BOTH:
			return actionName
		ECurrentInputProvider.PLAYER1:
			return "p1_" + actionName
		ECurrentInputProvider.PLAYER2:
			return "p2_" + actionName
		ECurrentInputProvider.SPOOF_ONLY:
			return "no_action"
