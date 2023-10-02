extends CanvasLayer

@onready var uis : Dictionary = {
	"ready":$Ready,
	"fight":$Fight}

@onready var player : AnimationPlayer = $AnimationPlayer
	
signal animationCompleted

func _ready():
	for ui in uis.values():
		ui.hide()
	player.animation_finished.connect(_onAnimationCompleted)

func showUI(uiName : String, hideWhenFinished : bool):
	if uis.has(uiName):
		uis[uiName].show()
		print("Show " + uiName)
		if player.has_animation(uiName):
			player.play(uiName)
			if hideWhenFinished:
				await player.animation_finished
				hideUI(uiName)

func hideUI(uiName : String):
	player.seek(0.0, false)
	if uis.has(uiName):
		uis[uiName].hide()

func _onAnimationCompleted(_name):
	animationCompleted.emit()
