extends Node
## Game Main autoloaded class.
##
## This script handle all the global logics & initialization.
## It is autoloaded, and thus ALWAYS available for all scenes.
## The following are handled by this script:
##  - Global initialization, such as silentWolf configuration
##  - Scene handling and scene changes
##  - more TBD...

## Curent scene loaded
var currentScene : Node = null

## Global initialization
func _ready():
	# Retrieve currently loaded scene, ie the last one in the tree (after autoloads)
	var root = get_tree().root
	currentScene = root.get_child(root.get_child_count() - 1)
	
	# Configure SilentWolf API
	initSilentWolf()
	
	## DEBUG
	test()

func test():
	$LoadingUI.display = true
	get_tree().create_tween().tween_method($LoadingUI.setValue, 0.0, 100.0, 5.0)
	await get_tree().create_timer(5.0).timeout
	$LoadingUI.display = false


## SilentWolf API initialization. Used for leaderboard.
func initSilentWolf() -> void:
	# Retrieve APi key from private file
	var file := FileAccess.open("res://api_keys.json", FileAccess.READ)
	if (file == null):
		push_warning("Failed to open API keys file. SilentWolf API disabled.")
		return
	
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	if (error != OK):
		push_warning("Failed to parse API keys file. SilentWolf API disabled.")
		return
	
	var apiKey : String = json.data["silentWolf"]
	if (apiKey == null):
		push_warning("Failed to find API key in json. SilentWolf API disabled.")
		return
	
	# default verbose to ERROR_ONLY, except in debug mode (i.e. in editor)
	var verboseLevel := 0
	if (OS.is_debug_build()):
		verboseLevel = 1
		
	# Finaly configure SilentWolf with retrieved API key
	SilentWolf.configure({
	"api_key": apiKey,
	"game_id": "Ldjam54",
	"log_level": verboseLevel
  	})

	print ("SilentWolf API properly configured")
	
	# Quick test DEBUG ONLY
	# var sw_result: Dictionary = await SilentWolf.Scores.save_score("test", 4242).sw_save_score_complete
	# print("Score persisted successfully: " + str(sw_result.score_id))
