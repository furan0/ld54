extends Node
class_name ChargeHandler
## handle player charge
##
## This script handle the switch between pre-charge and charge and move the character accordingly

## rigidbody to influence. if not set, will take its parent
@export var rigidbody : RigidBody2D
## rotation reference. if not set, will take %LookAt
@export var rotationRef : LookAt

@export var isVerbose : bool = false

@export_group("Charge parameters")
## Additional impulse force to the target per second of charge
@export var additionalForcePerSecond : float = 6000
## Stun duration
@export var pushedStunDuration : float = 0.6
## Maximum charge time. afterward, no more impact on runtime and impulse force
@export var maxChargeTime : float = 0.7
## Charge Run force applied to the player
@export var chargeRunForce : float = 8000
## Max rotation speed while charging
@export var chargeMaxRotationSpeed : float = (PI / 2) / 60
## Player direction influence for trajectory
@export var stickInfluenceForce : float = 200
## Charge Wrestle duration
@export var wrestleDuration : float = 4.0
@onready var wrestleHandler = get_node("%WrestleHandler") as WrestleHandler

# Time ellapsed since start of charge
var chargingTime : float = 0.0
# Are we charging right now ?
var isCharging : bool = false
# Are we running right now ?
var isRunning : bool = false
# Time spent running
var ellapsedRunningTime : float = 0.0
# Was guarder
var hitGuard : bool = false

# Current colliders with the rigidBody
var hitedBody : Array[Node2D] = []

# Stick direction
var currentStickDirection : Vector2 = Vector2.ZERO

# === Signals
## Emitted when the character starts to run...
signal doCharge()
## Emitted when it's time to stop running...
signal endCharge()
##Emitted when charge ended by hiting a guard
signal endChargeGuarded()

# Called when the node enters the scene tree for the first time.
func _ready():
	# if rigidbody not set, take its parent if compatible
	if (rigidbody == null):
		if is_instance_of(get_parent(), RigidBody2D):
			rigidbody = get_parent() as RigidBody2D
		else:
			push_error("Rigidbody must be set or the node parent must be of type RigidBody2D")
		
	if wrestleHandler == null || !is_instance_of(wrestleHandler, WrestleHandler):
		push_error("Wrestle handler not found...Expecting a node calles %HitHandler")
	
	# Connect collision signals to body list
	rigidbody.body_entered.connect(func (node : Node2D):
		hitedBody.append(node))
	rigidbody.body_exited.connect(func (node : Node2D):
		var index := hitedBody.find(node)
		if index != -1:
			hitedBody.remove_at(index))
	
	# if rotationRef not set, take %LookAt if available
	if (rotationRef == null):
		if %LookAt != null:
			rotationRef = %LookAt as LookAt
		else:
			push_error("rotationRef must be set or the node %LookAt must exist")


## start charging
func startCharging():
	isCharging = true;
	chargingTime = 0.0
	_print("Charging started")
	# Reduce rotation speed while charging 
	rotationRef.setMaxRotationSpeed(chargeMaxRotationSpeed)


# Stop charging. Now run baby, run !
func stopCharging():
	isCharging = false
	# make sure charge time is not greater than max charge time
	chargingTime = min(chargingTime, maxChargeTime)
	_print("Charging ended. Run now little bastard ! For : " + str(chargingTime) + "s")
	doCharge.emit()
	# Retablish max rotation speed
	rotationRef.setMaxRotationSpeed(0.0)


## Call this function to start the running phase with previously calculated parameters
func startRunning():
	ellapsedRunningTime = 0.0
	isRunning = true
	pass


##called to set the stick direction
func setCurrentStickDirection(direction : Vector2):
	currentStickDirection = direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# If we are charging, increment charging time
	if isCharging:
		chargingTime += delta
	
	# If we are running, add force to the character rigidbody
	if isRunning:
		# check if we collided with someone
		if _checkCollisionAndHit():
			terminateCharge()
			return
			
		# check if we still need to run
		ellapsedRunningTime += delta
		if ellapsedRunningTime >= chargingTime:
			# You ran for long enough ! Stop that crap...
			terminateCharge()
			
		# Move rigidbody in the right direction
		var direction := Vector2.RIGHT.rotated(rotationRef.rotation)
		var ortho := direction.orthogonal()
		var runForce = direction * chargeRunForce
		
		var stickDirection = currentStickDirection.normalized()
		var stickForce = abs(ortho.dot(stickDirection)) * stickInfluenceForce * stickDirection
		
		var totalForce = runForce + stickForce
		rigidbody.apply_force(totalForce)
		rotationRef.rotation = totalForce.normalized().angle()


## Called to check collision and apply hit if necessary. Return true if we collided.
func _checkCollisionAndHit() -> bool:
	if !hitedBody.is_empty():
		_print("HIT !")
		# Let know all bodies that they were hitted
		for node in hitedBody:
			doHit(node)
		return true
	return false

func doHit(node : Node2D):
	var hitDir = (node.position - get_parent().position).normalized()
	var hitHandler = node.get_node("%HitHandler") as HitHandler
		
	#If the entity has a WrestleHandler : WREstle time !
	var ennemyHandler = node.get_node("%WrestleHandler") as WrestleHandler
	if (wrestleHandler != null) && wrestleHandler.canWrestle && (ennemyHandler != null) && ennemyHandler.canWrestle:
		_print("Wrestling time baby !")
		var hitForce = additionalForcePerSecond * maxChargeTime # Max push always
		var timer : SceneTreeTimer = get_tree().create_timer(wrestleDuration)
		ennemyHandler.beginWrestling(pushedStunDuration, hitDir * hitForce, wrestleHandler, timer)
		
	# If the entity has a stun handler, stun it instead !
	elif (hitHandler != null):
		var hitForce = additionalForcePerSecond * chargingTime
		var hitReceived = hitHandler.hit(pushedStunDuration, hitDir * hitForce)
		if !hitReceived:
			hitGuard = true


## Called to end the charge
func terminateCharge():
	if hitGuard:
		endChargeGuarded.emit()
		hitGuard = false
	else:
		endCharge.emit()
	_print("Charge terminated")
	# Reset everything
	isRunning = false
	isCharging = false
	ellapsedRunningTime = 0.0
	chargingTime = 0.0

func _print(text : String):
	if isVerbose:
		print(text)
