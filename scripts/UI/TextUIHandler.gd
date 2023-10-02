extends CanvasLayer

@onready var uis : Dictionary = {
	"ready":$Ready,
	"fight":$Fight,
	"victory":$Victory,
	"defeat":$Defeat,
	"nextMatch":$NextMatch,
	"gameLost":$EndGameLost,
	"gameWon":$EndGameWon}

@onready var player : AnimationPlayer = $AnimationPlayer
	
signal animationCompleted

func _ready():
	for ui in uis.values():
		ui.hide()
	player.animation_finished.connect(_onAnimationCompleted)

func showUI(uiName : String, hideWhenFinished : bool = false):
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


func showUIAfterDelay(uiName : String, delay : float):
	await get_tree().create_timer(delay).timeout
	showUI(uiName)

func hideAllUi():
	for ui in uis.keys():
		hideUI(ui)
