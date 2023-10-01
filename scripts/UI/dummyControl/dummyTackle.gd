extends ADummyControl
class_name dummyTackle
## dummyTackle
##
## This script manage a dummy tackle
@export var actionTime: float = 0.2

func _animation():
	# do press
	displayButton.set_pressed_no_signal(true)
	timer.start(actionTime)
	await timer.timeout
	displayButton.set_pressed_no_signal(false)
	
	# Start move
	_dummyInput.spoofInput("tackle", true)
