extends Control
class_name TextUI

@export var animationName : String = ""
@onready var animator : AnimationPlayer = $AnimationPlayer

signal animationFinished

# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(_displayedUpdated)
	animator.animation_finished.connect(_onAnimationFinished)


func _displayedUpdated():
	if visible:
		animator.play(animationName)

func _onAnimationFinished(_name):
	animationFinished.emit()
