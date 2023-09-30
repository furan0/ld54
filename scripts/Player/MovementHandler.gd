extends Node
class_name MovementHandler
## MovementHandler
##
## This script handle player movement by sending forces to the given rigidbody


## rigidbody to influence. if not set, will take its parent
@export var rigidbody : RigidBody2D

## define if this entity can move right now or not
@export var movementAuthorized : bool = true

## Movement impulse velocity
@export var defaultForce : float = 4000.0
@onready var movementForce : float = defaultForce

# Called when the node enters the scene tree for the first time.
func _ready():
	# if rigidbody not set, take its parent if compatible
	if (rigidbody == null):
		if is_instance_of(get_parent(), RigidBody2D):
			rigidbody = get_parent() as RigidBody2D
		else:
			push_error("Rigidbody must be set or the node parent must be of type RigidBody2D")


## request a rigidbody movement. Ignored if we can't move right now
func requestMovement(dir : Vector2):
	## return if you can't move right now
	if !movementAuthorized:
		return
	
	# Apply the move impulse
	var forceVector := dir.normalized() * movementForce
	rigidbody.apply_force(forceVector)


## Set if the character can move or not
func canMove(status : bool):
	movementAuthorized = status
