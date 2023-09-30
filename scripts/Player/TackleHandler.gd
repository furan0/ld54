@tool
extends Node
class_name TackleHandler
## Handle tackles
##
## This script handle tackles and stun enemy if in the area

## Area2D used for this tackler
@export var hitbox : Area2D

## Ennemy stun duration after receiving this tackle
@export var stunDuration : float = 1.0

## Is verbose flag
@export var isVerbose : bool = false


## Bodies currently in the hitbox
var hitablesBody : Array[Node2D] = []

func _ready():
	if hitbox == null:
		push_warning("Hitbox not set. doing nothing")
		return
	
	# Connect hitbox signals to body list
	hitbox.body_entered.connect(func (node : Node2D):
		hitablesBody.append(node))
	hitbox.body_exited.connect(func (node : Node2D):
		var index := hitablesBody.find(node)
		if index != -1:
			hitablesBody.remove_at(index))

## Function to call to do a tackle
func tackle():
	if hitbox == null:
		push_warning("Hitbox not set. doing nothing")
		return
		
	_print("Tackle")
	
	## Tackle all targets availables
	for node in hitablesBody:
		# If the entity has a stun handler, stun it !
		var hitHandler = node.get_node("%HitHandler") as HitHandler
		if (hitHandler != null):
			var hitDir = (node.position - get_parent().position).normalized()
			hitHandler.hit(stunDuration, hitDir)


##Calles by editor to update configuration warning on the script
func _get_configuration_warnings():
	var warnings := []

	# === Check hitbox validity
	if !is_instance_of(hitbox, Area2D) || hitbox == null:
		warnings.append("An hitbox shall be specified")

	# Returning an empty array means "no warning".
	return warnings


func _print(text : String):
	if isVerbose:
		print(text)
