extends AudioStreamPlayer
class_name audio_effect

@export var audio_clips : Array[AudioStream]

@export var pitch_distortion := 0.0 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_sound():
	if(len(audio_clips)<1):
		return
	var idx = randi_range(0,len(audio_clips)-1)
	stream = audio_clips[idx]
	playing = true

func stop_play():
	playing = false

