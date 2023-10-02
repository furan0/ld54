extends AudioStreamPlayer
class_name audio_effect

@export var audio_clips : Array[AudioStream]

@export var pitch_distortion := 0.0 

func play_sound():
	if(len(audio_clips)<1):
		return
	var idx = randi_range(0,len(audio_clips)-1)
	stream = audio_clips[idx]
	playing = true

func stop_play():
	playing = false

