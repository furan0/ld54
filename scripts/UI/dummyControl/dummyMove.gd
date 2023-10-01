extends ADummyControl
class_name DummyMove
## DummyMove
##
## This script manage a dummy move
@export var movingTime: float = 5.0

func _animation():
	# Start move
	_dummyInput.spoofInput("setMove", true)

	timer.start(movingTime)
	await timer.timeout
	
	# Stop move
	_dummyInput.spoofInput("setMove", false)
