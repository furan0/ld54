extends ADummyControl
class_name dummyWrestle
## dummyWrestle
##
## This script manage a dummy wrestle
@export var actionTime: float = 0.1

@onready var rig = dummy.get_node("2D_character_rig")
@onready var animButton = dummy.get_node("Smashbutton")

func _ready():
	if rig != null:
		_startAnimDefered.call_deferred()

func _startAnimDefered():
	rig.signal_to_anim("wsl")

func _animation():
	# Start move
	displayButton.set_pressed_no_signal(true)

	timer.start(actionTime)
	await timer.timeout
	
	# Stop move
	displayButton.set_pressed_no_signal(false)
