extends Node

@onready var rig := $"../2D_character_rig"
# Called when the node enters the scene tree for the first time.
func _ready():
	$"../StateMachine/CompoundState/free/Idle".connect("state_entered",rig.signal_to_anim.bind("idle"))
	$"../StateMachine/CompoundState/free/move".connect("state_entered",rig.signal_to_anim.bind("movement"))
	$"../StateMachine/CompoundState/free/tackle".connect("state_entered",rig.signal_to_anim.bind("tackle"))
	$"../StateMachine/CompoundState/free/guard".connect("state_entered",rig.signal_to_anim.bind("guard"))
	$"../StateMachine/CompoundState/free/charge/preCharge".connect("state_entered",rig.signal_to_anim.bind("pre_charge"))
	$"../StateMachine/CompoundState/free/charge/charge".connect("state_entered",rig.signal_to_anim.bind("charge"))
	$"../StateMachine/CompoundState/stun".connect("state_entered",rig.signal_to_anim.bind("stun"))
	$"../StateMachine/CompoundState/wrestle".connect("state_entered",rig.signal_to_anim.bind("wsl"))
