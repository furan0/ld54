extends RigidBody2D
class_name Player
## Player class.. Wrapper for underlying logic mostly

var isDead : bool = false

signal dead()
signal resurect()
signal wrestlingStarted()

#Force a charge for this duration
func charge(duration : float):
	if isDead:
		return
		
	%ChargeHandler.chargingTime = duration
	%ChargeHandler.startRunning()

func stopCharge():
	%ChargeHandler.terminateCharge()

# Force rotation
func lookAt(target : Node2D):
	if isDead:
		return
		
	var direction : Vector2 = target.position - position
	%LookAt.rotation = direction.angle()

func kill():
	isDead = true
	dead.emit()

func signalWrestling():
	wrestlingStarted.emit()


func unkill():
	resurect.emit()

func goTo(position : Vector2):
	%IA.move_to(position)

func lockControl():
	%InputHandler.disableStandardInput = true
	%IA.set_ia_active(false)

func unlockControl():
	%InputHandler.disableStandardInput = false
	%IA.set_ia_active(true)
