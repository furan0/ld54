extends Node2D
class_name LookAt
## This class look at things

# Set to true to accept looking at things
var canUpdateItsRotation : bool = true
## max Rotation speed. Set to 0 for no limit
@export var maxAngularVelocity : float = 0

## Set if this object can look ath things or not
func canLookAtThings(status : bool):
	canUpdateItsRotation = status

## Set the rotation, if we can...
func setRotation(value: float):
	if !canUpdateItsRotation:
		return
	
	if !is_equal_approx(maxAngularVelocity, 0.0):
		# TODO : fix that crap
		var rotationToDo : = value - rotation
		if abs(rotationToDo) >= maxAngularVelocity:
			rotation += (maxAngularVelocity * sign(rotationToDo))
		else:
			rotation += rotationToDo
	else:
		rotation = value


##Set rotation with a given vector
func setRotationVect(vector : Vector2):
	setRotation(vector.angle())

## Rotate to the given value with a maximal angular speed
func setRotationSlowed(value : float, angularSpeed : float):
	if !canUpdateItsRotation:
		return
	
	var rotationToDo := value - rotation 
	if abs(rotationToDo) >= angularSpeed:
		rotation += (angularSpeed * sign(rotationToDo))
	else:
		rotation += rotationToDo


##Set max rotation speed. et 0 for unlimited
func setMaxRotationSpeed(speed : float):
	maxAngularVelocity = speed
