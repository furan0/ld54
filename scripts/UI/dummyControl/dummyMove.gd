extends ADummyControl
class_name DummyMove
## DummyMove
##
## This script manage a dummy move
@export var movingTime: float = 5.0

func _animation():
	# Start move
	_dummyInput.spoofInput("setMove", true)
	displayButton.set_pressed_no_signal(true)

	timer.start(movingTime)
	await timer.timeout
	
	# Stop move
	_dummyInput.spoofInput("setMove", false)
	displayButton.set_pressed_no_signal(false)
