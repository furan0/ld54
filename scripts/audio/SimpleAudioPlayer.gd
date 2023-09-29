@tool
extends Node
class_name SimpleAudioPlayer
## SimpleAudioPlayer
##
## This class handle a library of sound and play them when requested

## Library of playable sound
@export var soundsDatabase : Array[SoundDB] :
	set(value):
		if (soundsDatabase != value):
			soundsDatabase = value
			update_configuration_warnings()
			
## Audio Stream Player. If not set, try to take a child named "AudioStreamPlayer"
@export var audioPlayer : Node :
	set(value):
		if (value != audioPlayer):
			audioPlayer = value
			update_configuration_warnings()

func _ready():
	# if in editor, do nothing
	if Engine.is_editor_hint():
		return
		
	# If no Audio player set, will take its child named AudioStreamPlayer
	if (audioPlayer == null):
		audioPlayer = $AudioStreamPlayer
	# Check if child found
	if (audioPlayer == null):
			push_error("No Audio player found.")
			return
	
	audioPlayer.stop()
	
	
## Play the given sound
func playSound(soundName : String):
	# Play no sound if in editor
	if Engine.is_editor_hint():
		return
		
	# Check if sound exist in DB
	if !_has(soundName):
		push_warning("Sound not found : " + soundName + ". Doing nothing.")
		return
	
	print("Play sound : " + soundName)
	audioPlayer.stream = _getSound(soundName)
	audioPlayer.play()


# Check if a sound exist in the provided BD
func _has(soundName : String) -> bool:
	for db in soundsDatabase:
		var result = db.has(soundName)
		if result:
			return true
	return false


# Retrieve a sound from various BD. if not found, retur null
func _getSound(soundName : String) -> AudioStream:
	for db in soundsDatabase:
		var result  := db.getSound(soundName)
		if result != null:
			return result
	return null


##Calles by editor to update configuration warning on the script
func _get_configuration_warnings():
	var warnings := []

	# === Check panels dict values
	if soundsDatabase.is_empty():
		warnings.append("At least one Sound DB must be set.")
	
	# Check Audio stream player type
	if audioPlayer != null:
		if not (audioPlayer.has_method("play") && audioPlayer.has_method("stop") && "stream" in audioPlayer):
			warnings.append("audioPlayer is of invalid type")
	elif get_node("AudioStreamPlayer") == null:
		warnings.append("if no audioPlayer is specified, a child named 'AudioStreamPlayer' shall exist")

	# Returning an empty array means "no warning".
	return warnings
