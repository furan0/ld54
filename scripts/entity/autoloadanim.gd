extends AnimationPlayer

@export var anim_toplay : String 
var onapajoue = true
# Called when the node enters the scene tree for the first time.

func _process(_delta):
	if(onapajoue):
		onapajoue = false
		play(anim_toplay)
