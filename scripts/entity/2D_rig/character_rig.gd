extends Node2D


enum CHARA_ANIMATION {
	IDLE,
	MOVEMENT,
	PRE_CHARGE,
	CHARGE,
	POST_CHARGE,
	TACKLE,
	GUARD,
	EXHAUSTED,
	DEAD,
	PUSHED}
	
# The animation to play if the animation is not yet implemented
@export var fallback_animation :=  CHARA_ANIMATION.IDLE
@export var looker : Node2D



var available_animation = {CHARA_ANIMATION.IDLE : "idle-loop",
	CHARA_ANIMATION.MOVEMENT : "walk-loop"}
@onready var available_action = {CHARA_ANIMATION.IDLE : $AnimationPlayer.play,
	CHARA_ANIMATION.MOVEMENT : $AnimationPlayer.play}


func play_animation(desired_animation : CHARA_ANIMATION):
	if (desired_animation in available_animation):
		available_action[desired_animation].call(available_animation[desired_animation])
	else:
		$AnimationPlayer.play(fallback_animation)

## Called when the node enters the scene tree for the first time.
func _ready():
	play_animation(CHARA_ANIMATION.IDLE)

#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not(looker == null):
		pass
	
