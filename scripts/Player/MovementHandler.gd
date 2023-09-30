extends Node
class_name MovementHandler
## MovementHandler
##
## This script handle player movement by sending forces to the given rigidbody


@export_group("Configuration")
## rigidbody to influence. if not set, will take its parent
@export var rigidbody : RigidBody2D
##verbose mode
@export var isVerbose : bool = false

@export_group("Movement parameters")
## define if this entity can move right now or not
@export var moveEnabled : bool = true

## Movement impulse force
@export var defautImpulseForce : float = 20.0
@onready var impulseForce := defautImpulseForce

## Send signal when a movement is started/handed
signal moveStarted()
signal moveStoped()
var isMoving : bool = false
var movedThisFrame : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# if rigidbody not set, take its parent if compatible
	if (rigidbody == null):
		if is_instance_of(get_parent(), RigidBody2D):
			rigidbody = get_parent() as RigidBody2D
		else:
			push_error("Rigidbody must be set or the node parent must be of type RigidBody2D")

func _process(_delta):
	if (movedThisFrame && !isMoving):
		# We just started moving => signal it
		moveStarted.emit()
		isMoving = true
		_print("Stared moving")
	elif (!movedThisFrame && isMoving):
	# We just stoped moving => signal it
		moveStoped.emit()
		isMoving = false
		_print("Stoped moving")
	movedThisFrame = false

## request a rigidbody movement. Ignored if we can't move right now
func requestMovement(dir : Vector2):
	## return if you can't move right now
	if !moveEnabled:
		return
	
	# Apply the move impulse
	var impulseVector := dir.normalized() * impulseForce
	rigidbody.apply_impulse(impulseVector)
	
	movedThisFrame = true


## Set if this entity can move or not
func canMove(status : bool):
	if (moveEnabled && !status):
		_print("Movement disabled")
	elif (!moveEnabled && status):
		_print("Movement enabled")
		
	moveEnabled = status


## Set impute force. if 0.0 is given as a parameter, restaure default value
func setImpulseForce(value : float):
	if is_equal_approx(value, 0.0):
		# 0.0 as a parameter => restore default value
		impulseForce = defautImpulseForce
	else:
		impulseForce = value


func _print(text : String):
	if isVerbose:
		print(text)
