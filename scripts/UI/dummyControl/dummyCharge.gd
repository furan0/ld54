extends ADummyControl
class_name dummyCharge
## dummyTackle
##
## This script manage a dummy tackle
@export var actionTime: float = 0.8
var pressDelay : float = 0.2

func _animation():
	# do press
	displayButton.set_pressed_no_signal(true)
	
	# Wait for switch from tackle to charge
	timer.start(pressDelay)
	await timer.timeout
	_dummyInput.spoofInput("charge", true)
	
	timer.start(actionTime)
	await timer.timeout
	
	# Start move
	_dummyInput.spoofInput("charge", false)
	displayButton.set_pressed_no_signal(false)
