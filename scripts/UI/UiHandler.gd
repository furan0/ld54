@tool
extends CanvasLayer
class_name UiHandler
## UI Handler
##
## This high level class handle all common UI (unrelated to gameplay UI)
## It implements the  followings fucntionnalities :
## - instanciate & manages various UI panel (of the StandardUiPanel type)
## - handle switching between all theses panels
## - handle UI input action such as "go back" 


## This dict store all managed UI as scenes with a StandardUiPanel at its root.
## It allow the association of a UI scene with a name used in underlying controls
## The first indexed panel is considered as the ROOT UI and will be shown first
@export var panels : Dictionary :
	set(value):
		if (panels != value):
			panels = value
			update_configuration_warnings()
# Stack used to store panel hierarchy
var panelHierarchy : Array[String] = []
# handle to current panel node
var currentPanel : StandardUiPanel = null

## Signals definition
# Signal emitted whenever a back is called even though there is no more panels in hierarchy
# (can be handled by hiding the UI or switching scene for example)
signal backRequestedWithEmptyHierarchy()
# Signal emitted on every ui switch, apart from go back
signal uiSwitched()
# Signal emitted on every go_back action
signal uiGoback()


@export_placeholder("Root panel name") var rootPanel : String :
	set(value):
		if (rootPanel != value):
			rootPanel = value
			update_configuration_warnings()

# Called when the node enters the scene tree for the first time.
func _ready():
	# check root panel and set it appropriately if required
	# No or erroneous root panel info -> set it to first dict key
	if (rootPanel.is_empty() || !panels.has(rootPanel)) && !panels.is_empty():
		push_warning("No Root panel info set. Setting it to first panels dict key")
		rootPanel = panels.keys()[0]
	
	# Initializes root panel
	switchPanel(rootPanel)


#Called each frame. used to handle UI input action
func _process(_delta):
	if not Engine.is_editor_hint():
		if Input.is_action_just_released("ui_cancel"):
			_on_back_called()


## Function used switchPanel (handle also signal calls)
##
## Parameters : 
## - panelName : name of panel to switch to
## - hidePreviousPanel : set to true to hide previous panel. Useful only when isChildPanel = true
## - isChildPanel : set to true to consider the current panel as new panel "back" panel
func switchPanel(panelName : String, hidePreviousPanel : bool = true, isChildInHierarchy : bool = true):
	# Check if new panel is in panels dict
	if !panels.has(panelName):
		push_error("Panel " + panelName + " was not found in panels dictionnary. Panel switch aborted.")
		return
	
	# handle hierarchy if new panel is not a child of current one
	if isChildInHierarchy:
		# hide previous panel if requested
		if hidePreviousPanel && currentPanel != null:
			currentPanel.hide()
	else:
		# Remove current panel if not null
		if currentPanel != null:
			currentPanel.queue_free() 
		panelHierarchy.pop_back()
	panelHierarchy.push_back(panelName)

	# Instantiate & configure new panel
	currentPanel = panels[panelName].instantiate() as StandardUiPanel
	self.add_child(currentPanel)
	
	# configure signal connection
	if not Engine.is_editor_hint():
		currentPanel.switchToPanel.connect(switchPanel)
		currentPanel.returnRequested.connect(_on_back_called)
		
	# emit panel switch signal
	if not Engine.is_editor_hint():
		uiSwitched.emit()


# handle back input/signal
func _on_back_called():
	# check hierarchy
	if panelHierarchy.size() <= 1:
		# Empty hierarchy => do nothing and emit a signal. Handled by higher levels
		backRequestedWithEmptyHierarchy.emit()
		return
	else:
		# Hierarchy not empty => remove current panel and update hierarchy
		currentPanel.queue_free()
		panelHierarchy.pop_back()
		# update current panel and restore focus
		currentPanel = get_child(get_child_count()-2) as StandardUiPanel # -2 since current panel is not freed yet
		currentPanel.show()
		currentPanel.resetFocus()
	# trigger signal
	if not Engine.is_editor_hint():
		uiGoback.emit()

##Calles by editor to update configuration warning on the script
func _get_configuration_warnings():
	var warnings := []

	# === Check panels dict values
	if panels.is_empty():
		warnings.append("At least on panel must be set.")
		
	# Check dictionary keys
	for key in panels.keys():
		if not is_instance_of(key, TYPE_STRING):
			warnings.append("Panels Keys shall be of type String")
		if key.is_empty():
			warnings.append("Panels Keys shall not be empty")
			
	# Check dictionary values
	for value in panels.values():
		if not is_instance_of(value, PackedScene):
			warnings.append("Panels Values shall be scenes with StandarduiPanel as root node")
		if value == null:
			warnings.append("Panels values shall not be null")
	
	# === Check root panel value
	if !rootPanel.is_empty() && !panels.has(rootPanel):
		warnings.append("Given root panel is not a key of Panels dictionnary")

	# Returning an empty array means "no warning".
	return warnings
