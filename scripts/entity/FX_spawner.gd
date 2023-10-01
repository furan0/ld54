extends Node2D
class_name FX_spawner


const impact_cool := preload("res://scenes/entity/2Deffect/impact_FX2.tscn")



var  available_fx = {"impact" : spwan_FX2}
@export var target : Node2D = null

func spwan_FX2(position_offset,rotation_offset,scale_offset,param_supp_spw):
	var spawned := impact_cool.instantiate()
	if (target == null):
		add_child(spawned)
	else:
		target.add_child(spawned)
	spawned.position += position_offset
	spawned.rotation += rotation_offset
	spawned.scale += scale_offset
	spawned.set_notify_local_transform(false)
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_fx(fx_name : String, position_offset = Vector2.ZERO, rotation_offset = 0.0, scale_offset = 1.0, param_supp_spw := {}):
	if (fx_name in available_fx):
		available_fx[fx_name].call(position_offset,rotation_offset,scale_offset,param_supp_spw)
	else:
		print("ERROR pas de FX nomme "+fx_name)


