extends HSlider

@onready var busManager = $BusManager
@onready var player = $SimpleAudioPlayer
@export var affectedBus : String

func _ready():
	value_changed.connect(onValueChanged)

func onValueChanged(newValue : float):
	busManager.setBusVolumeLinearString(affectedBus, newValue / 100)
	player.playSound("test")
