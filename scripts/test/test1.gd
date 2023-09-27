extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.connect("pressed", Global.goto_scene.bind("res://scenes/levels/test2.tscn"))
