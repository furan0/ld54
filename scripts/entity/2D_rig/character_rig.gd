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
	PUSHED,
	WSL}

var str_to_anim = {
	"idle" : CHARA_ANIMATION.IDLE,
	"movement" : CHARA_ANIMATION.MOVEMENT,
	"pre_charge" : CHARA_ANIMATION.PRE_CHARGE,
	"charge" : CHARA_ANIMATION.CHARGE,
	"post_charge" : CHARA_ANIMATION.POST_CHARGE,
	"tackle" : CHARA_ANIMATION.TACKLE,
	"guard" : CHARA_ANIMATION.GUARD,
	"exhausted" : CHARA_ANIMATION.PUSHED,
	"dead" : CHARA_ANIMATION.DEAD,
	"stun" : CHARA_ANIMATION.PUSHED,
	"wsl" : CHARA_ANIMATION.WSL
}

# The animation to play if the animation is not yet implemented
@export var fallback_animation :=  CHARA_ANIMATION.IDLE
@export var looker : Node2D
@export var angle_max := PI/5
@export var angle_min := -PI/5

var defined_scale = 1.0

var available_animation_parameter = {CHARA_ANIMATION.IDLE : "idle-loop",
	CHARA_ANIMATION.MOVEMENT : "walk-loop",
	CHARA_ANIMATION.PRE_CHARGE : "precharge-loop",
	CHARA_ANIMATION.CHARGE : null,
	CHARA_ANIMATION.POST_CHARGE : "postcharge",
	CHARA_ANIMATION.TACKLE : "tackled",
	CHARA_ANIMATION.GUARD : null,
	CHARA_ANIMATION.EXHAUSTED : "tackled",
	CHARA_ANIMATION.DEAD : "dead",
	CHARA_ANIMATION.PUSHED: "tackled",
	CHARA_ANIMATION.WSL : "wsl"}

@onready var available_action = {CHARA_ANIMATION.IDLE : _play_anim,
	CHARA_ANIMATION.MOVEMENT : _play_anim,
	CHARA_ANIMATION.PRE_CHARGE : anim_precharge,
	CHARA_ANIMATION.CHARGE : anim_charge,
	CHARA_ANIMATION.POST_CHARGE : _play_anim,
	CHARA_ANIMATION.TACKLE : anim_tackle,
	CHARA_ANIMATION.GUARD : anim_guard,
	CHARA_ANIMATION.EXHAUSTED : _play_anim,
	CHARA_ANIMATION.DEAD : _play_anim,
	CHARA_ANIMATION.PUSHED: _play_anim,
	CHARA_ANIMATION.WSL : play_wsl}

###### FUNCTION FOR ANIMATION #####

func play_wsl(param):
	_play_anim(param)
	set_keyframe_mode(true)
	$keyframe/Wsl.visible = true
	$particle/smoke_wsl1.emitting = true
	$particle/smoke_wsl2.emitting = true
	$particle/smoke_wsl3.emitting = true
	$keyframe/anim_wsl.visible = true
	
func _play_anim(anim_name : String):
	set_keyframe_mode(false)
	$AnimationPlayer.play(anim_name)

func set_keyframe_mode(active : bool):
	$AnimationPlayer.speed_scale = 1.0
	$muppet.visible = not(active)
	$keyframe.visible = active
	for child in $keyframe.get_children():
		child.visible = false
	for child in $particle.get_children():
		child.emitting = false

func anim_dead(param):
	play_animation(param)
	set_keyframe_mode(true)
	$keyframe/Dead.visible = true
	

func anim_guard(_param):
	set_keyframe_mode(true)
	$keyframe/Guard.visible = true
	
	
#	$particle/smoke_charge2.emitting = true

func anim_charge(_param):
	set_keyframe_mode(true)
	$keyframe/Charge.visible = true
	$particle/smoke_charge1.emitting = true
#	$particle/smoke_charge2.emitting = true

func anim_precharge(param):
	_play_anim(param)
	$AnimationPlayer.speed_scale =  2.0
	$particle/smoke_precharge1.emitting = true
	$particle/smoke_precharge2.emitting = true
	

func anim_tackle(_param):
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
	defined_scale = scale.x
	play_animation(CHARA_ANIMATION.IDLE)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
#	pass
	if not(looker == null):
		var angle = looker.rotation
		angle = fmod(angle,PI+PI)
		if(cos(angle)<-0.1):
			angle = fmod(angle,PI+PI) + PI
			scale.x = defined_scale * -1
		else : 
			scale.x = defined_scale 
		angle = fmod(angle,PI+PI)
		if(angle<PI):
			rotation = clampf(angle,0,angle_max)
		else:
			rotation = clampf(angle,PI+PI+angle_min,PI+PI)

func signal_to_anim(state : String):
	play_animation(str_to_anim[state])

