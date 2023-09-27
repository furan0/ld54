extends CanvasLayer
## Loading UI manager
##
## This script handle loading UI for scene transition

@export_group("Required references")
## Loading Bar
@export var loadingBar : Range

@export_group("Animation Params")
## Animation delays
@export var showDelay := 0.7
@export var hideDelay := 0.7

## Var used to display/hide this UI (can't override show()/hide()...)
var display : bool = false :
	set (value):
		if (value):
			displayUI()
		else:
			hideUI()

var loadPercent : float = 0 : 
	set (value):
		setValue(value)
	get:
		return loadingBar.value

# Called when the node enters the scene tree for the first time.
func _ready():
	# hide first without calling associated signals
	self.hide()
	

## Show the loading panel with the associated animation
func displayUI() -> void:
	$Panel.modulate = Color.TRANSPARENT
	show()
	var tween := get_tree().create_tween()
	tween.tween_property($Panel, "modulate", Color.WHITE, showDelay)


## Hide the loading panel after the associated animation
func hideUI() -> void:
	# Hide with a tween
	var tween := get_tree().create_tween()
	tween.tween_property($Panel, "modulate", Color.TRANSPARENT, hideDelay)
	# After tween is complete, really hide the canvasLayer
	await get_tree().create_timer(hideDelay).timeout
	hide()

## This function shall be called to update the progress bar/Range
func setValue(value: float) -> void:
	loadingBar.value = value
