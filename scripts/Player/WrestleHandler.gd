extends Node
class_name WrestleHandler
## handle player wrestling
##
## This script receive stuns, impulse & hits

@export var isVerbose : bool = false

## Can wrestle right now
var canWrestle : bool = false

# Are we currently wrestling ?
var isWrestling : bool = false
# Wrestle hit stun duration (for us)
var wrestleHitStunDuration : float
# Wrestle hit vector (for us)
var wrestleHitForce : Vector2
# Wrestle button smash count
var buttonCounter : int = 0
# Ennemy Wrestle
var ennemyWrestle : WrestleHandler

##Emitted when wrestling ended (either victory or lost)
signal wrestlingEnded()
signal wrestlingStarted()
signal changeRotation(rotation : Vector2)

@onready var hitHandler = get_node("%HitHandler") as HitHandler

# Called when the node enters the scene tree for the first time.
func _ready():
	if hitHandler == null ||!is_instance_of(hitHandler, HitHandler):
		push_error("Hit handler not found...Expecting a node calles %HitHandler")


##Called on every button smash
func buttonSmashed():
	if isWrestling:
		buttonCounter += 1

func wrestleFinished(didWeLose : bool):
	if isWrestling:
		isWrestling = false
	
		if didWeLose:
			_print("Wrestling ended : we lost with " + str(buttonCounter) + " inputs...")
			if hitHandler != null:
				hitHandler.hit(wrestleHitStunDuration, wrestleHitForce)
		else:
			_print("Wrestling ended : we Won with " + str(buttonCounter) + " inputs !")
		wrestlingEnded.emit()
		
func _endOfWrestling():
	# Check if we won or lost
	var isVictorious : bool = ennemyWrestle.buttonCounter > self.buttonCounter
	wrestleFinished(isVictorious)

func setCanWrestle(status : bool):
	_print("Can wrestle now : " + str(status))
	canWrestle = status

func beginWrestling(stunDuration : float, hitDirection : Vector2, handler : WrestleHandler, wrestlingTimer : SceneTreeTimer):
	if canWrestle && !isWrestling:
		isWrestling = true
		buttonCounter = 0
		wrestleHitStunDuration = stunDuration
		wrestleHitForce = hitDirection
		ennemyWrestle = handler
		# Register to timer timeout
		wrestlingTimer.timeout.connect(_endOfWrestling)
		# Make the other enter wrestling to
		var chargeHandler = %ChargeHandler as ChargeHandler
		if chargeHandler != null:
			_print ("Trigger other charge handler")
			chargeHandler.doHit(handler.get_parent())
		wrestlingStarted.emit()
		_print("Wrestling started !!")
		changeRotation.emit(hitDirection.angle() + PI) # make the player face the blow
	
func _print(text : String):
	if isVerbose:
		print(text)
