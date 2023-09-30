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
	CHARA_ANIMATION.MOVEMENT : "walk-loop",
	CHARA_ANIMATION.PRE_CHARGE : "pre_charge",
	CHARA_ANIMATION.CHARGE : null,
	CHARA_ANIMATION.POST_CHARGE : "postcharge",
	CHARA_ANIMATION.TACKLE : "tackled",
	CHARA_ANIMATION.GUARD : [],
	CHARA_ANIMATION.EXHAUSTED : [],
	CHARA_ANIMATION.DEAD : [],
	CHARA_ANIMATION.PUSHED: "tackled"}

@onready var available_action = {CHARA_ANIMATION.IDLE : _play_anim,
	CHARA_ANIMATION.MOVEMENT : _play_anim,
	CHARA_ANIMATION.PRE_CHARGE : _play_anim,
	CHARA_ANIMATION.CHARGE : anim_charge,
	CHARA_ANIMATION.POST_CHARGE : _play_anim,
	CHARA_ANIMATION.TACKLE : anim_tackle,
	CHARA_ANIMATION.GUARD : _play_anim,
	CHARA_ANIMATION.EXHAUSTED : _play_anim,
	CHARA_ANIMATION.DEAD : _play_anim,
	CHARA_ANIMATION.PUSHED: _play_anim}

###### FUNCTION FOR ANIMATION #####
func _play_anim(anim_name : String):
	set_keyframe_mode(false)
	$AnimationPlayer.play(anim_name)
	
func set_keyframe_mode(active : bool):
	$muppet.visible = not(active)
	$keyframe.visible = active
	for child in $keyframe.get_children():
		child.visible = false

func anim_charge(param):
	set_keyframe_mode(true)
	$keyframe/Charge.visible = true

func anim_tackle(param):
	set_keyframe_mode(true)
	$keyframe/Tackle.visible = true

## 
func play_animation(desired_animation : CHARA_ANIMATION):
	$AnimationPlayer.speed_scale = 1.0
	if (desired_animation in available_action):
		available_action[desired_animation].call(available_animation_parameter[desired_animation])
	else:
		$AnimationPlayer.play(fallback_animation)

## Called when the node enters the scene tree for the first time.
func _ready():
	play_animation(CHARA_ANIMATION.IDLE)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not(looker == null):
		pass

func signal_to_anim(state : String):
	print(state)
	play_animation(str_to_anim[state])

