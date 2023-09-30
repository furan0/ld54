@tool
extends Node
class_name StunHandler
## StunHandler
##
## This script handle player stun and stun exit

## Stun durations dict
@export var stunDurations : Dictionary :
	set(value):
		if (stunDurations != value):
			stunDurations = value
			update_configuration_warnings()


## verbose mode
@export var isVerbose : bool = false

## local stun tracking
var isCurrentlyStuned : bool = false
var timeSinceStartOfStun : float = 0.0
var currentStunDuration : float = 0.0

## signal called when a stun is started with its time
signal isStuned()
##Called when the current stun is completed
signal stunCompleted()

## Method to generate a stun from the given values
## If no stun with the name found, do nothing and throw an error
func stun(stunName : String):
	# Do nothing if in editor 
	if Engine.is_editor_hint():
		return
	
	var stunDuration = stunDurations[stunName]
	if (stunDuration == null) || (!is_instance_of(stunDuration, TYPE_FLOAT)):
		push_warning("Stun named " + stunName + " not found in database or of invalid type")
		return
	
	currentStunDuration = stunDuration
	isCurrentlyStuned = true
	isStuned.emit()
	_print("Stun " + stunName + " started for " + str(stunDuration) + "s")


## Generate a stun with a given duration instead of using the stun dictionnary
func stunFor(stunDuration : float):
	currentStunDuration = stunDuration
	isCurrentlyStuned = true
	isStuned.emit()
	_print("generic Stun started for " + str(stunDuration) + "s")


func _process(delta : float):
	if isCurrentlyStuned:
		timeSinceStartOfStun += delta
		if timeSinceStartOfStun >= currentStunDuration:
			# stun finished
			isCurrentlyStuned = false
			timeSinceStartOfStun = 0.0
			stunCompleted.emit()
			_print("Stun completed")


##Calles by editor to update configuration warning on the script
func _get_configuration_warnings():
	var warnings := []

	# === Check stunDurations dict values
	# Check dictionary keys
	for key in stunDurations.keys():
		if not is_instance_of(key, TYPE_STRING):
			warnings.append("stunDurations Keys shall be of type String")
		if key.is_empty():
			warnings.append("stunDurations Keys shall not be empty")
			
	# Check dictionary values
	for value in stunDurations.values():
		if not is_instance_of(value, TYPE_FLOAT):
			warnings.append("stunDurations Values shall be of type Float")
		if value == null:
			warnings.append("stunDurations values shall not be null")

	# Returning an empty array means "no warning".
	return warnings


func _print(text : String):
	if isVerbose:
		print(text)
