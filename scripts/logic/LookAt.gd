extends Node2D
## This class look at things

# Set to true to accept looking at things
var canUpdateItsRotation : bool = true

## Set if this object can look ath things or not
func canLookAtThings(status : bool):
	canUpdateItsRotation = status

## Set the rotation, if we can...
func setRotation(value: float):
	if canUpdateItsRotation:
		rotation = value


##Set rotation with a given vector
func setRtationVect(vector : Vector2):
	if canUpdateItsRotation:
		rotation = vector.angle()

## Rotate to the given value with a maximal angular speed
func setRotationSlowed(value : float, angularSpeed : float):
	if !canUpdateItsRotation:
		return
	
	var rotationToDo := value - rotation 
	if abs(rotationToDo) >= angularSpeed:
		rotation += (angularSpeed * sign(rotationToDo))
	else:
		rotation += rotationToDo
