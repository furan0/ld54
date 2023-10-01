extends Node



signal walking
signal stop
signal charge


@onready var input_handler := %InputHandler
@export var target_node : Node2D
@export var start_on_load = true
###
var delatcounter := 0.0
var keep_going_global := true
var timer
###

## Ask the input for walking to the target + offset., epsilon here to stop the guy.
func follow(target : Node2D, offset:=Vector2.ZERO, epsilon:=1936.0):
	var keep_going := true
	walking.emit()
	while(keep_going and keep_going_global):
		var dir = target.position+offset-get_parent().position
		if(dir).length_squared() > epsilon:
			dir=dir.normalized()
			input_handler.spoofInput("setMove",true)
			input_handler.spoofInput("move",dir)
		else:
			input_handler.spoofInput("setMove",false)
			input_handler.spoofInput("move",Vector2.ZERO)
			keep_going = false
		await get_tree().process_frame
	stop.emit()

func think(tps := 1.0):
	while (keep_going_global):
		await get_tree().process_frame
	stop.emit()
	
func take_a_break(shouldemit:=true):
	input_handler.spoofInput("setMove",false)
	input_handler.spoofInput("move",Vector2.ZERO)
	if(shouldemit):
		stop.emit()

func make_charge(target : Node2D, offset:=Vector2.ZERO,tps=3000.0,proxim_threshold:=300000):
	var keep_going := true
	input_handler.spoofInput("charge",true)
	if(target_node!=null):
		while(keep_going and keep_going_global):
			await get_tree().process_frame
			var dir = target.position+offset-get_parent().position
			input_handler.spoofInput("move",dir)
	else:
		while(keep_going and keep_going_global):
			await get_tree().process_frame

	input_handler.spoofInput("charge",false)
	await get_tree().process_frame
	input_handler.spoofInput("setMove",false)
	input_handler.spoofInput("move",Vector2.ZERO)
	stop.emit()
	
func make_guard(target : Node2D):
	var keep_going := true
	input_handler.spoofInput("guard",true)
	if(target_node!=null):
		while(keep_going and keep_going_global):
			await get_tree().process_frame
			var dir = target.position-get_parent().position
			input_handler.spoofInput("move",dir)
	else:
		while(keep_going and keep_going_global):
			await get_tree().process_frame
	input_handler.spoofInput("guard",false)
	await get_tree().process_frame
	input_handler.spoofInput("setMove",false)
	input_handler.spoofInput("move",Vector2.ZERO)
	stop.emit()

func pick_action():
	if(target_node != null):
		keep_going_global=true
		
		var p := randf()
		var offset = (target_node.position + get_parent().position) * 0.5 - target_node.position
		offset = offset + (offset as Vector2).orthogonal() 
		if (p<0.05):
			get_tree().create_timer(0.3).timeout.connect(stop_action)
			follow(target_node,offset)
		elif(p<0.3):
			get_tree().create_timer(0.4).timeout.connect(stop_action)
			offset = (get_parent().position-target_node.position).orthogonal()  * 2
			follow(target_node,offset)
		elif(p<0.4):
			get_tree().create_timer(0.3).timeout.connect(stop_action)
			think()
		elif(p<0.6):
			get_tree().create_timer(0.5).timeout.connect(stop_action)
			make_charge(target_node)
		else:
			get_tree().create_timer(0.7).timeout.connect(stop_action)
			make_guard(target_node)

func stop_action():
	keep_going_global = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if(start_on_load):
		connect("stop",pick_action)
		pick_action()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	delatcounter += delta

