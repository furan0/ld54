extends ADummyControl
class_name dummyDeath
## dummyDeath
##
## This script manage a dummy death

@onready var rig = dummy.get_node("2D_character_rig")

func _ready():
	if rig != null:
		_startAnimDefered.call_deferred()

func _startAnimDefered():
	rig.signal_to_anim("dead")

func _animation():
	# Nothing to animate
	pass
