extends RigidBody2D
class_name Player
## Player class.. Wrapper for underlying logic mostly

var isDead : bool = false

signal dead()
signal resurect()
signal wrestlingStarted()
signal moveCompleted()

#Force a charge for this duration
func charge(duration : float):
	if isDead:
		return
	
	%InputHandler.spoofInput("charge", true)
	%ChargeHandler.chargingTime = duration
	%InputHandler.spoofInput.bind("charge", false).call_deferred()
	%ChargeHandler.set_deferred("runningTime", duration)

func stopCharge():
	%ChargeHandler.terminateCharge()

# Force rotation
func lookAt(target : Vector2):
	if isDead:
		return
		
	var direction : Vector2 = target - position
	%LookAt.set_rotation(direction.angle())

func kill():
	isDead = true
	
	# Stop all charges and damp movement as much as possible
	#if %ChargeHandler.isRunning:
	#	stopCharge()
	dead.emit()
	lockControl()
	print(name + " is dead.")

func signalWrestling():
	wrestlingStarted.emit()


func unkill():
	resurect.emit()

func goTo(targetPos : Vector2):
	$MovementHandler.moveTo(targetPos)
	await $MovementHandler.moveToCompleted
	moveCompleted.emit()

func lockControl():
	%InputHandler.disableStandardInput = true
	%IA.set_ia_active(false)

func unlockControl():
	%InputHandler.disableStandardInput = false
	%IA.set_ia_active(true)

func setupIaTarget(target : Node2D):
	%IA.target_node = target
