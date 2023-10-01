extends ADummyControl
class_name dummyGuard
## dummyGuard
##
## This script manage a dummy guard
@export var actionTime: float = 2.0

func _animation():
	# Start move
	_dummyInput.spoofInput("guard", true)
	displayButton.set_pressed_no_signal(true)

	timer.start(actionTime)
	await timer.timeout
	
	# Stop move
	_dummyInput.spoofInput("guard", false)
	displayButton.set_pressed_no_signal(false)
