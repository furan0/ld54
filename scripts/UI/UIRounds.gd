extends CanvasLayer

@export var uiRound1 : Control
@export var uiRound2 : Control
@export var uiRound3 : Control

@export var tweenTime : float = 0.2

func setRound(isPlayerVictory : bool):
	var currentRound : int = %GameManager.currentRoundNumber
	match currentRound:
		0:
			setRoundColor(uiRound1, isPlayerVictory)
		1:
			setRoundColor(uiRound2, isPlayerVictory)
		2:
			setRoundColor(uiRound3, isPlayerVictory)

func setRoundColor(ui : Control, isPlayerVictory : bool):
	if isPlayerVictory:
		var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
		tween.tween_property(ui.get_node("player"), "modulate", Color(1, 1, 1, 1), tweenTime)
	else:
		var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
		tween.tween_property(ui.get_node("enemy"), "modulate", Color(1, 1, 1, 1), tweenTime)

func resetRound():
	var tween1 = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween1.tween_property(uiRound1.get_node("player"), "modulate", Color(1, 1, 1, 0), tweenTime)
	var tween2 = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween2.tween_property(uiRound2.get_node("player"), "modulate", Color(1, 1, 1, 0), tweenTime)
	var tween3 = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween3.tween_property(uiRound3.get_node("player"), "modulate", Color(1, 1, 1, 0), tweenTime)
