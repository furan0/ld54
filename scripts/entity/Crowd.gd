extends Node2D
class_name Crowd
# This class handle one of the game crowd

enum ECrowdState {IDLE, HAPPY, DEAD}

@export_group("Textures")
@export var framesIdle : Array[Texture2D]
@export var framesHappy : Array[Texture2D]
@export var framesDead : Array[Texture2D]
@onready var currentArray : Array[Texture2D] = framesIdle
var currentIndex : float

@onready var sprite : Polygon2D = $Sprite

@export_group("Tinkle")
@export var maxNbFrameBetweenTransition : int = 15
@export var minNbFrameBetweenTransition : int = 4
@onready var nbFrameBetweenTransition := randi_range(minNbFrameBetweenTransition, maxNbFrameBetweenTransition)
var frameCounter := 0

@export_group("Movement")
@export var moveDuration : float = 2.5
var isMoving : bool = false
@export var moveBounceDuration : float = 0.15
@export var moveBounceVector : Vector2 = Vector2(0, -10)

@export_group("Happiness (officer)")
@export var maxTimeHappy : float = 3.0
@export var minTimeHappy : float = 0.5
@export var maxTimeUnhappy : float = 15.0
@export var minTimeUnhappy : float = 5.0
var hapinessTimer : Timer
@export var happyBounceDuration : float = 0.1
@export var happyBounceVector : Vector2 = Vector2(0, -10)


var currentState : ECrowdState = ECrowdState.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	if !framesIdle.is_empty():
		currentIndex = randi() % framesIdle.size()
		sprite.texture = framesIdle[currentIndex]
		
	hapinessTimer = Timer.new()
	add_child(hapinessTimer)
	hapinessTimer.start(randf_range(0.0, maxTimeUnhappy))
	hapinessTimer.timeout.connect(setHappy.bind(true))


func _physics_process(_delta):
	frameCounter += 1
	if frameCounter > nbFrameBetweenTransition:
		# Switch
		frameCounter = 0
		currentIndex += 1
		
		if currentArray.is_empty():
			return
			
		if currentIndex >= currentArray.size():
			currentIndex = 0
		sprite.texture = currentArray[currentIndex]


func setCrowdState(state : ECrowdState):
	match state:
		ECrowdState.IDLE:
			currentArray = framesIdle
			currentState = ECrowdState.IDLE
		ECrowdState.HAPPY:
			currentArray = framesHappy
			currentState = ECrowdState.HAPPY
		ECrowdState.DEAD:
			currentArray = framesDead
			currentState = ECrowdState.DEAD

func kill():
	setCrowdState(ECrowdState.DEAD)

func setHappy(isHappy : bool):
	# Do nothing when you're dead... deuh
	if currentState == ECrowdState.DEAD:
		return
		
	if isHappy:
		setCrowdState(ECrowdState.HAPPY)
		hapinessTimer.start(randf_range(minTimeHappy, maxTimeHappy))
		hapinessTimer.timeout.disconnect(setHappy.bind(true))
		hapinessTimer.timeout.connect(setHappy.bind(false))
	else:
		setCrowdState(ECrowdState.IDLE)
		hapinessTimer.start(randf_range(minTimeUnhappy, maxTimeUnhappy))
		hapinessTimer.timeout.disconnect(setHappy.bind(false))
		hapinessTimer.timeout.connect(setHappy.bind(true))
		
func forceHappy(duration : float):
	# Do nothing when you're dead... deuh
	if currentState == ECrowdState.DEAD:
		return
	
	setCrowdState(ECrowdState.HAPPY)
	hapinessTimer.start(duration)
	if hapinessTimer.timeout.is_connected(setHappy.bind(true)):
		hapinessTimer.timeout.disconnect(setHappy.bind(true))
	if !hapinessTimer.timeout.is_connected(setHappy.bind(false)):
		hapinessTimer.timeout.connect(setHappy.bind(false))
	
	## We are ultra happy ! thus we bounce
	await get_tree().create_timer(randf_range(0.0, 1.0)).timeout
	_doHappyBounce()


func move(target : Node2D):
	# Do nothing when you're dead... deuh
	if currentState == ECrowdState.DEAD:
		return
		
	var tween = create_tween()
	tween.tween_property(self, "position", target.position, moveDuration)
	tween.finished.connect(stopMove)
	isMoving = true
	_doBounce()
	


func _doBounce():
	var originalPosition = $Sprite.position
	while isMoving:
		## Bounce up
		var tween = create_tween().set_ease(Tween.EASE_OUT)
		tween.tween_property($Sprite, "position", originalPosition + moveBounceVector, moveBounceDuration)
		await tween.finished
		
		## Bounce down
		tween = create_tween().set_ease(Tween.EASE_IN)
		tween.tween_property($Sprite, "position", originalPosition, moveBounceDuration)
		await tween.finished

func _doHappyBounce():
	var originalPosition = $Sprite.position
	while currentState == ECrowdState.HAPPY:
		## Bounce up
		var tween = create_tween().set_ease(Tween.EASE_OUT)
		tween.tween_property($Sprite, "position", originalPosition + moveBounceVector, moveBounceDuration)
		await tween.finished
		
		## Bounce down
		tween = create_tween().set_ease(Tween.EASE_IN)
		tween.tween_property($Sprite, "position", originalPosition, moveBounceDuration)
		await tween.finished

func stopMove():
	isMoving = false
