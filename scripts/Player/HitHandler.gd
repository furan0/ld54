extends Node
class_name HitHandler
## handle player hit and protection
##
## This script receive stuns, impulse & hits

## Set to true to make someone invulnerable
@export var invulnerable : bool = false

## rigidbody to influence. if not set, will take its parent
@export var rigidbody : RigidBody2D

##verbose mode
@export var isVerbose : bool = false

## Check if we are protected or not
var isProtected : bool = false


## stun signal
signal startStun(duration : float)
signal changeRotation(rotation : Vector2)

## Call this function to hit the player
## Params :
## - stunDuration : duration of the stun associated with the hit
## - impactVector : impact Vector for hit impulse calculation
## - bypassProtection : can this hit bypass guard protection
func hit(stunDuration : float, impactVector : Vector2 = Vector2.ZERO, bypassProtection : bool = false):
	# Check if we can receive the hit
	if invulnerable:
		_print("Received a hit while invulnerable. Ignoring it")
		return
	
	if isProtected && !bypassProtection:
		_print("Received a non-bypassing hit while protected. Ignoring it")
		return
	
	# Not protected -> receive the hit
	_print("Character hit and stuned for " + str(stunDuration))
	startStun.emit(stunDuration)
	rigidbody.apply_impulse(impactVector)
	changeRotation.emit(impactVector.angle() + PI) # make the player face the blow


func setProtected(status : bool):
	isProtected = status

func _ready():
	# if rigidbody not set, take its parent if compatible
	if (rigidbody == null):
		if is_instance_of(get_parent(), RigidBody2D):
			rigidbody = get_parent() as RigidBody2D
		else:
			push_error("Rigidbody must be set or the node parent must be of type RigidBody2D")

func _print(text : String):
	if isVerbose:
		print(text)
