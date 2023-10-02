extends RigidBody2D
## Player class.. Wrapper for underlying logic mostly

var isDead : bool = false

signal dead()
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
