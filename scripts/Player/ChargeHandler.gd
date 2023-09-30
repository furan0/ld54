extends Node
class_name ChargeHandler
## handle player charge
##
## This script handle the switch between pre-charge and charge and move the character accordingly

## rigidbody to influence. if not set, will take its parent
@export var rigidbody : RigidBody2D
## rotation reference. if not set, will take %LookAt
@export var rotationRef : Node2D

@export var isVerbose : bool = false

@export_group("Charge parameters")
## Additional impulse force to the target per second of charge
@export var additionalForcePerSecond : float = 200
## Maximum charge time. afterward, no more impact on runtime and impulse force
@export var maxChargeTime : float = 3
## Charge Run force applied to the player
@export var chargeRunForce : float = 8000

# Time ellapsed since start of charge
var chargingTime : float = 0.0
# Are we charging right now ?
var isCharging : bool = false
# Are we running right now ?
var isRunning : bool = false
# Time spent running
var ellapsedRunningTime : float = 0.0

# === Signals
## Emitted when the character starts to run...
signal doCharge()
## Emitted when it's time to stop running...
signal endCharge()

# Called when the node enters the scene tree for the first time.
func _ready():
	# if rigidbody not set, take its parent if compatible
	if (rigidbody == null):
		if is_instance_of(get_parent(), RigidBody2D):
			rigidbody = get_parent() as RigidBody2D
		else:
			push_error("Rigidbody must be set or the node parent must be of type RigidBody2D")
			
	# if rotationRef not set, take %LookAt if available
	if (rotationRef == null):
		if %LookAt != null:
			rotationRef = %LookAt as Node2D
		else:
			push_error("rotationRef must be set or the node %LookAt must exist")


## start charging
func startCharging():
	isCharging = true;
	chargingTime = 0.0
	_print("Charging started")


# Stop charging. Now run baby, run !
func stopCharging():
	isCharging = false
	# make sure charge time is not greater than max charge time
	chargingTime = min(chargingTime, maxChargeTime)
	_print("Charging ended. Run now little bastard !")
	doCharge.emit()


## Call this function to start the running phase with previously calculated parameters
func startRunning():
	ellapsedRunningTime = 0.0
	isRunning = true
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If we are charging, increment charging time
	if isCharging:
		chargingTime += delta
	
	# If we are running, add force to the character rigidbody
	if isRunning:
		# check if we still need to run
		ellapsedRunningTime += delta
		if ellapsedRunningTime >= chargingTime:
			# You ran for long enough ! Stop that crap...
			_endCharge()
			
		# Move rigidbody in the right direction
		var direction := Vector2.RIGHT.rotated(rotationRef.rotation)
		rigidbody.apply_force(direction * chargeRunForce)
		# TODO : influence the direction with the joystick
		
		# check if we collided with someone
		if _checkCollisionAndHit():
			_endCharge()


## Called to check collision and apply hit if necessary. Return true if we collided.
func _checkCollisionAndHit() -> bool:
	## TODO
	return false

## Called to end the charge
func _endCharge():
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
