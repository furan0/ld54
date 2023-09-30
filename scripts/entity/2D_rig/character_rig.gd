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
@export var fallback_animation =  CHARA_ANIMATION.IDLE

var available_animation = {
	CHARA_ANIMATION.IDLE : "idle-loop"}

func play_animation(desired_animation : CHARA_ANIMATION):
	if (desired_animation in available_animation):
		$AnimationPlayer.play("idle_loop")
	else:
		$AnimationPlayer.play(fallback_animation)

## Called when the node enters the scene tree for the first time.
func _ready():
	play_animation(CHARA_ANIMATION.IDLE)

#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
