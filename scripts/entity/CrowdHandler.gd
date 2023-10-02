extends Node2D
## Move et enflamme the crowd !

@export var maxTimeHappy : float = 5.0
@export var minTimeHappy : float = 2.3
	
## Move everyone
func moveTo(targetNb : int):
	if targetNb <= 0 || targetNb > 3:
		push_error("Target number invalid : " + str(targetNb))
		return
	
	for peon in get_children():
		var crowd = peon.get_node("Crowd")
		var target = peon.get_node("Target" + str(targetNb))
		crowd.move(target)


## Ressurect everyone. Halleluja !!
func ressurectCrowd():
	for peon in get_children():
		peon.get_node("Crowd").setCrowdState(Crowd.ECrowdState.IDLE)


##Everyone is HAPPPPPPY
func superHappy():
	for peon in get_children():
		peon.get_node("Crowd").forceHappy(randf_range(minTimeHappy, maxTimeHappy))
