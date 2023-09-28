@tool
extends Node
class_name SimpleAudioPlayer
## SimpleAudioPlayer
##
## This class handle a library of sound and play them when requested

## Library of playable sound
@export var sounds : Dictionary :
	set(value):
		if (sounds != value):
			sounds = value
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
	if !sounds.has(soundName):
		push_warning("Sound not found : " + soundName + ". Doing nothing.")
		return
	
	print("Play sound : " + soundName)
	audioPlayer.stream = sounds[soundName] as AudioStream
	audioPlayer.play()

##Calles by editor to update configuration warning on the script
func _get_configuration_warnings():
	var warnings := []

	# === Check panels dict values
	if sounds.is_empty():
		warnings.append("At least on panel must be set.")
		
	# Check dictionary keys
	for key in sounds.keys():
		if not is_instance_of(key, TYPE_STRING):
			warnings.append("Sounds Keys shall be of type String")
		if key.is_empty():
			warnings.append("Sounds Keys shall not be empty")
			
	# Check dictionary values
	for value in sounds.values():
		if not is_instance_of(value, AudioStream):
			warnings.append("Sounds Values shall be AudioStream")
		if value == null:
			warnings.append("Sounds values shall not be null")
	
	# Check Audio stream player type
	if audioPlayer != null:
		if not (audioPlayer.has_method("play") && audioPlayer.has_method("stop") && "stream" in audioPlayer):
			warnings.append("audioPlayer is of invalid type")
	elif get_node("AudioStreamPlayer") == null:
		warnings.append("if no audioPlayer is specified, a child named 'AudioStreamPlayer' shall exist")

	# Returning an empty array means "no warning".
	return warnings
