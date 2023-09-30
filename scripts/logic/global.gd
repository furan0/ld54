extends Node
## Game Main autoloaded class.
##
## This script handle all the global logics & initialization.
## It is autoloaded, and thus ALWAYS available for all scenes.
## The following are handled by this script:
##  - Global initialization, such as silentWolf configuration
##  - Scene handling and scene changes
##  - more TBD...


## ==== Scene Loading var
## Curent scene loaded
var currentScene : Node = null
## Is a scene loading in progress ?
var isANewSceneLoading : bool = false
## scene path currently loading
var sceneCurrentlyLoading : String = ""
## Signal emited during scene switch
signal sceneSwitchStarted
signal sceneSwitchCompleted

## Global initialization
func _ready():
	# Retrieve currently loaded scene, ie the last one in the tree (after autoloads)
	var root = get_tree().root
	currentScene = root.get_child(root.get_child_count() - 1)
	
	# Configure SilentWolf API
	_initSilentWolf()


## SilentWolf API initialization. Used for leaderboard.
func _initSilentWolf() -> void:
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


func _process(_delta : float):
	# If a scene is currently loading, update loading status
	if (isANewSceneLoading):
		var progress : Array[float] = [0.0]
		var status := ResourceLoader.load_threaded_get_status(sceneCurrentlyLoading, progress) 
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				var loadPercent = progress[0] * 100
				print("Scene " + sceneCurrentlyLoading + " loading : " + str(loadPercent) + "%")
				$LoadingUI.loadPercent = loadPercent
			ResourceLoader.THREAD_LOAD_FAILED | ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				# Error !! Signal it then abort scene switching
				push_error("Scene loading failed ! Wanted scene : " + sceneCurrentlyLoading)
				isANewSceneLoading = false
			ResourceLoader.THREAD_LOAD_LOADED:
				isANewSceneLoading = false
				$LoadingUI.loadPercent = 100.0
				call_deferred("_completeSceneLoading", sceneCurrentlyLoading)


# ============================
# | Scene Switching handling |
# ============================
## Call this function to change current scene with another one
##
## A loading display will be shown, the scene will be unloaded then the new scene will be 
## instanciated in its place
func goto_scene(path : String) -> void:
	# Refuse all scene switch if a switch is already ongoing
	if (isANewSceneLoading):
		push_warning("Scene " + path + "requested while already switching to " + sceneCurrentlyLoading)
		return
		
	# First, show the loading UI at 0%
	$LoadingUI.loadPercent = 0.0
	$LoadingUI.displayUI()
	
	# Then start the loading process
	ResourceLoader.load_threaded_request(path)
	sceneCurrentlyLoading = path
	isANewSceneLoading = true
	
	# Emit the scene switch signal
	sceneSwitchStarted.emit()
	print("Switching to scene " + path)
	
	# Then remove current scene next idle time
	currentScene.queue_free()


##This fucntion is called whenever the scene loading is completed
func _completeSceneLoading(path : String) -> void:
	# Load & instanciate the new scene.
	var s = ResourceLoader.load_threaded_get(path)
	currentScene = s.instantiate()
	
	# Add it to the active scene, as child of root.
	get_tree().root.add_child(currentScene)
	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = currentScene
	
	# remove Loading UI & signal end of scene switching
	$LoadingUI.hideUI()
	sceneSwitchCompleted.emit()
	print("Scene switching completed")
