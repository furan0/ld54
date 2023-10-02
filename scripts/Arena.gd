extends Area2D
## This is the fighting arena !! Awesome !

enum EArena {BIG, MEDIUM, SMALL}
var currentArena : EArena = EArena.BIG

@export var areaBig : CollisionShape2D
@export var areaMedium : CollisionShape2D
@export var areaSmall : CollisionShape2D

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
	if crowdHandler == null:
		crowdHandler = $CrowdHandler
		
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
	match(arenaSize):
		EArena.BIG:
			areaBig.disabled = false
			areaMedium.disabled = true
			areaSmall.disabled = true
			crowdHandler.moveTo(1)
		EArena.MEDIUM:
			areaMedium.disabled = false
			areaBig.disabled = true
			areaSmall.disabled = true
			crowdHandler.moveTo(2)
		EArena.SMALL:
			areaSmall.disabled = false
			areaBig.disabled = true
			areaMedium.disabled = true
			crowdHandler.moveTo(3)

func switchArenaNum(sizeNumber : int):
	match sizeNumber:
		0:
			switchArena(EArena.BIG)
		1:
			switchArena(EArena.MEDIUM)
		2:
			switchArena(EArena.SMALL)
