extends Node2D
class_name GameManager
##Manage the game.. duh !

@export var arena : Node2D
@export var player : Player
@export var enemy : Player

func _ready():
	if arena == null:
		push_warning("Arena must be set")
	
	if player == null:
		push_warning("Player must be set")
		
	lockPlayers(true)

## reset the match and the arena
func resetMatch():
	if arena != null:
		arena.reset()
	if arena != null:

func spawnEnemy():
	pass

##Disable all players movement or IA logic
func lockPlayers(isLocked : bool):
	if isLocked:
		if player != null:
			player.lockControl()
		if enemy != null:
			enemy.lockControl()
	else:
		if player != null:
			player.unlockControl()
		if enemy != null:
			enemy.unlockControl()
