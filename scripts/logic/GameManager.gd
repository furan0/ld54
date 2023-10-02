extends Node2D
class_name GameManager
##Manage the game.. duh !

@export_group("Entities")
@export var arena : Node2D
@export var player : Player
var enemy : Player
@export var enemyList : Array[PackedScene]

@export_group("Targets")
@export var targetPlayer : Node2D
@export var targetEnemy : Node2D
@export var targetSpawn : Node2D
@export var enemyInPositionArea : Area2D

@export_group("Params")
@export var numberOfRound : int = 3
var currentRoundNumber : int = 0
var currentMatchNumber : int = 0
var playerScore : int = 0
var enemyScore : int = 0
var roundLoser : Player

var roundCompleted : bool = false

var enemyMoveCompleted : bool = false

# signals
signal startRound()
signal endOfRound()
signal resetPlayerPositions()
signal endOfMatch()
signal endOfGame()
signal playerWonRound()
signal enemyWonRound()
signal playerWonMatch()
signal enemyWonMatch()
signal playerWonGame()
signal enemyWonGame()

func _ready():
	if arena == null:
		push_warning("Arena must be set")
	else:
		arena.playerLeavedArena.connect(playerExitedArena)
	if player == null:
		push_warning("Player must be set")
	if targetPlayer == null:
		push_warning("targetPlayer must be set")
	if targetEnemy == null:
		push_warning("targetEnemy must be set")
	if enemyList.is_empty():
		push_warning("At least one enemy must be set")
		
	lockPlayers(true)

## reset the match and the arena
func resetMatch():
	if arena != null:
		arena.reset()
	
	if player != null && targetPlayer != null:
		player.goTo(targetPlayer.global_position)
	
	currentRoundNumber = 0
	playerScore = 0
	enemyScore = 0


##Reset the round
func resetRound():
	# Resurect everyone and make them move
	enemyMoveCompleted = false
	var moveSetter = func ():
		enemyMoveCompleted = true
		print("Enemy move completed")
	if player != null:
		player.unkill()
		player.disableCollider(true)
		if targetPlayer != null:
			player.goTo(targetPlayer.global_position)
	if enemy != null:
		enemy.unkill()
		enemy.disableCollider(true)
		if targetEnemy != null:
			enemy.goTo(targetEnemy.global_position)
			enemy.moveCompleted.connect(moveSetter)
	
	# Wait for reposition of both
	if player != null:
		await player.moveCompleted
	if enemy != null && !enemyMoveCompleted:
		await enemy.moveCompleted
	enemy.moveCompleted.disconnect(moveSetter)
	
	player.disableCollider(false)
	enemy.disableCollider(false)
	
	# Make them look at each others 
	await get_tree().create_timer(0.2).timeout
	lookAtEachOther()
	
	#Resize the arena then start the round
	if arena != null:
		arena.switchArenaNum(currentRoundNumber)
	startRound.emit()


func spawnEnemy():
	if enemyList.is_empty():
		push_warning("At least one enemy must be set")
		startRound.emit()
		return
	
	# Spawn the enemy
	enemy = enemyList[currentMatchNumber].instantiate()
	get_parent().add_child(enemy)
	enemy.lockControl()
	setupPlayer(enemy)
	if targetSpawn != null:
		enemy.position = targetSpawn.global_position
	
	# Start charge toward the given point
	if targetEnemy != null:
		enemy.lookAt(targetEnemy.global_position)
		enemy.charge.bind(10).call_deferred()
		# Disable the charge when the enemy reached the proper position
		if enemyInPositionArea != null:
			enemyInPositionArea.get_node("Collider").disabled = false
			if !enemyInPositionArea.is_connected("body_entered", _nodeReachedArea):
				enemyInPositionArea.body_entered.connect(_nodeReachedArea)


##called when the enemy reached the correct start area
func _nodeReachedArea(node : Node2D):
	if node == enemy:
		print("Enemy Position reached")
		node.stopCharge()
		enemyInPositionArea.get_node("Collider").set_deferred("disabled", true)
		startRound.emit()
		

## Called when the fight started
func fightStarted():
	roundCompleted = false
	lockPlayers(false)
	print("Fight Started !")

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


## Conenct signals and setup params
func setupPlayer(playerToSetup : Player):
	playerToSetup.setupIaTarget(player)
	playerToSetup.matchNumber = currentMatchNumber
	playerToSetup.hitReceived.connect(%Camera.doShake.bind(0.3))


func lookAtEachOther():
	if player != null && enemy != null:
		player.lookAt(enemy.position)
		enemy.lookAt(player.position)

func playerExitedArena(node : Player):
	# do nothing if not current player/enemy
	if node != player && node != enemy:
		return
	#do nothing if round already ended
	if !roundCompleted:
		node.kill()
		lockPlayers(true)
		roundLoser = node
		roundCompleted = true
		endOfRound.emit()

func endCurrentRound():
	print("End of round " + str(currentRoundNumber+1))
	if roundLoser == player:
		enemyScore += 1
		enemyWonRound.emit()
	else:
		playerScore += 1
		playerWonRound.emit()
	
	currentRoundNumber += 1
	if currentRoundNumber >= numberOfRound:
		# End of match
		print ("End of match " + str(currentMatchNumber+1))
		if enemyScore > playerScore:
			# player lost => end Of game
			print ("Player defeat... ")
			endOfGame.emit()
			enemyWonMatch.emit()
			enemyWonGame.emit()
		else:
			playerWonMatch.emit()
			currentMatchNumber += 1
			
			## Kill enemy & resurect plyer if required
			if player != null:
				player.unkill()
			if enemy != null:
				enemy.kill()
				
			## End of match. Check if end of game
			if currentMatchNumber >= enemyList.size():
				# Player victory !
				print ("Player Victory !!")
				endOfGame.emit()
				playerWonGame.emit()
			else:
				endOfMatch.emit()
	else:
		resetPlayerPositions.emit()
