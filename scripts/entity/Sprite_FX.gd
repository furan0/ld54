extends AnimatedSprite2D
class_name Sprite_FX
@export var play_on_start : bool = true
@export var queue_free_at_end : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if(play_on_start):
		play("default")
	if(queue_free_at_end):
		connect("animation_finished",queue_free)
