extends ADummyControl
class_name dummyWrestle
## dummyWrestle
##
## This script manage a dummy wrestle
@export var actionTime: float = 0.1

func _animation():
	# Start move
	# TODO
	displayButton.set_pressed_no_signal(true)

	timer.start(actionTime)
	await timer.timeout
	
	# Stop move
	# TODO
	displayButton.set_pressed_no_signal(false)
