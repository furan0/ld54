extends Node
class_name AudioBusManager
## AudioBusManager
##
## This class handle and control all operations on major audio buses
## It can be used to change volume or mute a whole bus for example

## Audio buses available in the game. If you add a new editable bus, you should edit this enum
enum E_BusName {MASTER, SFX, MUSIC}

## Audio Bus name to id dict
var busIds : Dictionary

func _ready():
	# Retrieve bus ID from name
	for busName in E_BusName:
		busIds[busName] = AudioServer.get_bus_index(busName.capitalize())


## Used to change a bus value with an input in dB
## 
## params :
## - bus : the bus to update
## - volume_db : the volume to set the bus to, in dB
func setBusVolume(bus : E_BusName, volume_db : float):
	AudioServer.set_bus_volume_db(busIds[bus], volume_db)


## Used to change a bus volume from a linear input. The input will be converted to dB.
## 
## params :
## - bus : the bus to update
## - volume : the volume to set the bus to, in linear value between 0.0 & 100.0
func setBusVolumeLinear(bus : E_BusName, volume : float):
	var volume_db := linear_to_db(volume)
	setBusVolume(bus, volume_db)
	
func setBusVolumeLinearString(bus : String, volume : float):
	var volume_db := linear_to_db(volume)
	var busID = AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(busID, volume_db)


## Used to mute any bus
## 
## params :
## - bus : the bus to mute
func muteBus(bus : E_BusName):
	AudioServer.set_bus_mute(busIds[bus], true)


## Used to un-mute any bus
## 
## params :
## - bus : the bus to unmute
func unmuteBus(bus : E_BusName):
	AudioServer.set_bus_mute(busIds[bus], false)
