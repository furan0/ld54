@tool
extends Control
class_name ADummyControl
## Abstract DummyControl
##
## This script manage a dummy and a button to show controls

## Dummy to control
@export var dummy : Node2D :
	set(value):
		if (dummy != value):
			dummy = value
			update_configuration_warnings()
## input handler used by child
@onready var _dummyInput : InputHandler = dummy.get_node("%InputHandler") as InputHandler

## Button to display the control
@export var displayButton : BaseButton :
	set(value):
		if (displayButton != value):
			displayButton = value
			update_configuration_warnings()
			
## show animation
@export var isPlaying : bool = true :
	set(value):
		if (value && (isPlaying != value)):
			# Start anim
			isPlaying = value
			_doAnimation()
		elif (!value && (isPlaying != value)):
			isPlaying = value

## Delay in between two anim
@export var delayInBetween : float = 0.5
@onready var timer : Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return
		
	if (displayButton == null):
		if is_instance_of($Button, BaseButton):
			displayButton = $Button as BaseButton
		else:
			push_error("displayButton must be set or a child called $Button must exist")
	#displayButton.disabled = true
	displayButton.toggle_mode = true
	
	##handle timer
	add_child(timer)
	timer.one_shot = true
	
	##If already started, start animation coroutine
	if isPlaying:
		_doAnimation()


func _doAnimation():
	while isPlaying:
		# Start anim
		await _animation()
		
		# Wait for in between delay
		if !isPlaying:
			break
		await _waitForNextAnim()

##Shall Be implemented by Child !
func _animation():
	pass

func _waitForNextAnim():
	timer.start(delayInBetween)
	await timer.timeout

##Calles by editor to update configuration warning on the script
func _get_configuration_warnings():
	var warnings := []

	# === Check panels dict values
	if dummy == null:
		warnings.append("Dummy shall be set")
	else:
		if dummy.get_node("%InputHandler") == null:
			warnings.append("Dummy InputHandler not found")
		
	if (displayButton == null) && !(is_instance_of($Button, BaseButton)):
		warnings.append("displayButton must be set or a child called $Button must exist")

	# Returning an empty array means "no warning".
	return warnings
