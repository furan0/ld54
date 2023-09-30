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

var str_to_anim = {
	"idle" : CHARA_ANIMATION.IDLE,
	"movement" : CHARA_ANIMATION.MOVEMENT,
	"pre_charge" : CHARA_ANIMATION.PRE_CHARGE,
	"charge" : CHARA_ANIMATION.CHARGE,
	"post_charge" : CHARA_ANIMATION.POST_CHARGE,
	"tackle" : CHARA_ANIMATION.TACKLE,
	"guard" : CHARA_ANIMATION.GUARD,
	"exhausted" : CHARA_ANIMATION.EXHAUSTED,
	"dead" : CHARA_ANIMATION.DEAD,
	"pushed" : CHARA_ANIMATION.PUSHED,
}


# The animation to play if the animation is not yet implemented
@export var fallback_animation :=  CHARA_ANIMATION.IDLE
@export var looker : Node2D



var available_animation_parameter = {CHARA_ANIMATION.IDLE : "idle-loop",
	CHARA_ANIMATION.MOVEMENT : "walk-loop"}
	
@onready var available_action = {CHARA_ANIMATION.IDLE : $AnimationPlayer.play,
	CHARA_ANIMATION.MOVEMENT : $AnimationPlayer.play}

## 
func play_animation(desired_animation : CHARA_ANIMATION):
	$AnimationPlayer.speed_scale = 1.0
	if (desired_animation in available_action):
		available_action[desired_animation].call(available_animation_parameter[desired_animation])
	else:
		$AnimationPlayer.play(fallback_animation)

## Called when the node enters the scene tree for the first time.
func _ready():
	play_animation(CHARA_ANIMATION.MOVEMENT)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not(looker == null):
		pass
	
