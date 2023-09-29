@tool
@icon("res://assets/icons/music.png")
extends Resource
class_name SoundDB
## SoundDB
##
## This class define a ressource containing various sound with their associated call string

## The sound database. The key shall be of String type and the Value of AudioStream or Array[AudioStream].
@export var sounds : Dictionary

## this function is used to retrieved a sound. return Null if sound not found
func getSound(key : String) -> AudioStream:
	if not sounds.has(key):
		return null
	
	var dictValue = sounds[key]
	if is_instance_of(dictValue, AudioStream):
		##Single sound associated -> send it
		return dictValue
	elif is_instance_of(dictValue, TYPE_ARRAY) && not (dictValue as Array).is_empty():
		## Array not empty => chose a random one
		var array = dictValue as Array
		var rngIndex = randi() % array.size()
		var result = array[rngIndex]
		if is_instance_of(result, AudioStream):
			return result
			
	push_warning("Registered sound " + key + " is of an incorrect type. Should be AudioStream or Array<AudioStream>")
	return null
	

##This function is used to check if a sound is available in the DB
func has(key : String) -> bool:
	return sounds.has(key)

##Setup for checks
func _init():
	changed.connect(_checkDB)
	
## This function checks the provided BD for any inconsistencies
func _checkDB():
	# Check dictionary keys
	for key in sounds.keys():
		if not is_instance_of(key, TYPE_STRING):
			push_error("Sounds Keys shall be of type String")
		if key.is_empty():
			push_error("Sounds Keys shall not be empty")
			
	# Check dictionary values
	for value in sounds.values():
		if not is_instance_of(value, AudioStream):
			if is_instance_of(value, TYPE_ARRAY):
				# Add a check that array value is also AudioStream... I was lazy.
				pass
			else:
				push_error("Sounds Values shall be AudioStream or Array<AudioStream>")
		if value == null:
			push_error("Sounds values shall not be null")
