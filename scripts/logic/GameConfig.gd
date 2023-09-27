@icon("res://assets/icons/wrench.svg")
extends Resource
class_name GameConfig
## Game Configuration manager
##
## This script ressource store player config, as well as handling load & save

## var storing the actual config
var config := ConfigFile.new()

## where is the configuration stored on user side
@export var configFileName : String = "config.cfg"

## === exposed configuration value. Edit this part to add more config parameters
## Sound
@export_range(0.0, 100.0) var sfxVolume := 100.0
@export_range(0.0, 100.0) var musicVolume := 100.0
## Player data
@export var playerName := ""
## Keybinding, use a dict for easier management
@export var keybindings : Dictionary


## Call to load conf file and override default parameters if required
func loadConfig():
	var err = config.load("user://" + configFileName)
	# If the file didn't load, ignore it.
	if err != OK:
		return
	
	## retrieve all data stored
	## Sound
	sfxVolume = config.get_value("sound", "sfx", sfxVolume)
	musicVolume = config.get_value("sound", "music", musicVolume)
	## Player data
	playerName = config.get_value("player", "name", playerName)
	## Keybinding
	for key in keybindings:
		keybindings[key] = config.get_value("keybinding", key, keybindings[key])

## Call to save conf file to disk/cookies
func saveConfig():
	## write all data sets
	## Sound
	config.set_value("sound", "sfx", sfxVolume)
	config.set_value("sound", "music", musicVolume)
	## Player data
	config.set_value("player", "name", playerName)
	## Keybinding
	for key in keybindings:
		config.set_value("keybinding", key, keybindings[key])
	
	##Then save config to disk
	var err = config.save("user://" + configFileName)
	if err != OK:
		push_warning("Error while saving player configuration to disk")
