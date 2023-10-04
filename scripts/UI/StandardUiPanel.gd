extends Control
class_name StandardUiPanel
## Game standard UI panel
##
## This class reprensent a standard Ui panel able to be handled by UI Manager
## It implements the  followings fucntionnalities :
## - signal when it want to go back to previous UI
## - Signal desired UI panel switches
## - handle scene goto for underlying buttons

## Emited whenever this panel wants to go back to previous panel
signal returnRequested
## Emited whenever this UI want to switch to a specific panel
signal switchToPanel(panelName : String, childOfCurrentPanel : bool)

# Which component grab focus when panel is opened
@export var initialFocus : Control

func _ready():
	resetFocus()
	visibility_changed.connect(_on_visibility_changed)

## This function handle scene goto for subjacent logic by linking with global
func goToScene(path : String):
	print ("UI scene switch requested : " + path)
	Global.goto_scene(path)

## Functions to be called by underlying signal for reemission
## request UI go back
func goBack():
	print ("UI go back requested")
	returnRequested.emit()
	
## Request panel switch
## - panelName : name of panel to switch to
## - hidePreviousPanel : set to true to hide previous panel. Useful only when isChildPanel = true
## - isChildPanel : set to true to consider the current panel as new panel "back" panel
func requestPanelSwitch(panelName : String, hidePreviousPanel : bool = true, isChildPanel : bool = true):
	print ("UI panel switch requested : " + panelName)
	switchToPanel.emit(panelName, hidePreviousPanel, isChildPanel)

func setNextSceneSwitch(SceneName : String):
	Global.mainMenuNextSceneSwitch = SceneName

func goToStoredScene():
	goToScene(Global.mainMenuNextSceneSwitch)

## reset the UI focus to the initial focus if set
func resetFocus():
	if initialFocus != null:
		initialFocus.grab_focus.call_deferred() # better if called defered according to doc

## Called when visibility changes -> reset focus when visible again
func _on_visibility_changed():
	if (visible):
		resetFocus()
