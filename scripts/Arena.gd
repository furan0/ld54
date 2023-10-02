extends Area2D
## This is the fighting arena !! Awesome !

enum EArena {BIG, MEDIUM, SMALL}
var currentArena : EArena = EArena.BIG

@export var areaBig : CollisionPolygon2D
@export var tracerBig : Node2D
@export var areaMedium : CollisionPolygon2D
@export var tracerMedium : Node2D
@export var areaSmall : CollisionPolygon2D
@export var tracerSmall : Node2D

@export var crowdHandler : Node2D
@export var delayBetweenResurectAndMove : float = 1.5

signal playerLeavedArena(player : Player)

func _ready():
	if areaBig == null:
		areaBig = $ArenaBig
	if areaMedium == null:
		areaMedium = $ArenaMedium
	if areaSmall == null:
		areaSmall = $ArenaSmall
	if tracerBig == null:
		tracerBig = $TracerBig
	if tracerMedium == null:
		tracerMedium = $TracerMedium
	if tracerSmall == null:
		tracerSmall = $TracerSmall
	if crowdHandler == null:
		crowdHandler = $CrowdHandler
	
	tracerBig.show()
	tracerMedium.hide()
	tracerSmall.hide()
		
	body_exited.connect(func (body : Node2D):
		if is_instance_of(body, Player):
			print(body.name + " exited the arena")
			playerLeavedArena.emit(body as Player))

# reset arena & crowd
func reset():
	crowdHandler.ressurectCrowd()
	await get_tree().create_timer(delayBetweenResurectAndMove).timeout
	switchArena(EArena.BIG)

func switchArena(arenaSize : EArena):
	tracerBig.hide()
	tracerMedium.hide()
	tracerSmall.hide()
	match(arenaSize):
		EArena.BIG:
			areaBig.disabled = false
			areaMedium.disabled = true
			areaSmall.disabled = true
			tracerBig.show()
			crowdHandler.moveTo(1)
		EArena.MEDIUM:
			areaMedium.disabled = false
			areaBig.disabled = true
			areaSmall.disabled = true
			tracerMedium.show()
			crowdHandler.moveTo(2)
		EArena.SMALL:
			areaSmall.disabled = false
			areaBig.disabled = true
			areaMedium.disabled = true
			tracerSmall.show()
			crowdHandler.moveTo(3)

func switchArenaNum(sizeNumber : int):
	match sizeNumber:
		0:
			switchArena(EArena.BIG)
		1:
			switchArena(EArena.MEDIUM)
		2:
			switchArena(EArena.SMALL)
