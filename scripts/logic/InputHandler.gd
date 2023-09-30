extends Node
class_name InputHandler
## InputHandler
##
## This script handle player input and convert them to signals.
## Those inputs can also be spoofed by calling appropriate functions

# === Inputs Signals
## Emitted when a charge input is changed
signal chargeStarted()
signal chargeEnded()
## Emitted when a tackle is requested
signal tackleRequested()
## Emitted when a guard input is changed
signal guardStarted()
signal guardEnded()
## Emitted when a move is requested
signal moveRequested(dir : Vector2)


# ==== tackle detection mechanism
## delay between a tackle input & a charge start signal, in s
@export var chargeDelay : float = 0.2
# count the number of s since tchargeDelayhe beginning of the tackle/charge press
var ellapsedTackleTime := 0.0
# set to true when a charge is ongoing
var chargeOnGoing : bool = false

## verbose log
@export var isVerbose : bool = false

## Check all inputs to send appropriate signals
func _physics_process(delta):
	## check charge & tackle
	if chargeOnGoing:
		# a charge is ongoing, only check for release t osend charge stop
		if Input.is_action_just_released("charge"):
			_print("Charge ended")
			chargeEnded.emit()
			chargeOnGoing = false
			ellapsedTackleTime = 0.0
	elif Input.is_action_pressed("charge"):
		#input pressed but not yet in charge
		ellapsedTackleTime += delta
		if (ellapsedTackleTime >= chargeDelay):
			# it is not a tackle anymore, but the start of a charge !
			chargeOnGoing = true
			chargeStarted.emit()
			_print("Charge started")
	elif Input.is_action_just_released("charge"):
		# Charge button released before entering charge -> tackle
		tackleRequested.emit()
		ellapsedTackleTime = 0.0
		_print("Tackle requested")
	
	
	## check guard
	if Input.is_action_just_pressed("guard"):
		guardStarted.emit()
		_print("Guard started")
	if Input.is_action_just_released("guard"):
		guardEnded.emit()
		_print("Guard ended")
	
	
	## check move
	var moveVector := Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if (moveVector != Vector2.ZERO):
		moveRequested.emit(moveVector)


## Function used to spoof a input signal
func spoofInput(inputName : String, value):
	match inputName:
		"charge":
			if value:
				chargeStarted.emit()
			else:
				chargeEnded.emit()
		"guard":
			if value:
				guardStarted.emit()
			else:
				guardStarted.emit()
		"move":
			moveRequested.emit(value)
		"tackle":
			tackleRequested.emit()

func _print(text : String):
	if isVerbose:
		print(text)
