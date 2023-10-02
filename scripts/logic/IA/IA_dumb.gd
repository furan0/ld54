extends Node



signal walking
signal stop
signal charge


@onready var input_handler := %InputHandler as InputHandler
@export var target_node : Node2D
@export var start_on_load = true
## Param de Strategie
@export var ZAD : Array[Vector2] = [Vector2(600,300),Vector2(700,300),Vector2(550,150),Vector2(750,450)]
@export var frame_react := 8
##

var papa : Node2D
###
# Don not modify directly use set_ia_active
var is_ia_active = false
var keep_going_global := true
var timer
###

 #Lancer IA
func start_ia():
	is_ia_active=true
	if !stop.is_connected(pick_action):
		connect("stop",pick_action)
	pick_action()
	
# Autorise l'IA a choisir des action à realiser.
func set_ia_active(active:bool):
	var old_state = is_ia_active
	is_ia_active = active
	if is_ia_active:
		if not(old_state):
			start_ia()
	else :
		keep_going_global = false
		
## Ne stop pas l'IA
func stop_action():
	keep_going_global = false

## Move to a direction an emit a stop.
func move_to(target_pos : Vector2,threhsold_for_stop=10.0):
	var keep_going := true
	var sqrd_thr = threhsold_for_stop * threhsold_for_stop
	walking.emit()
	
	while(keep_going and keep_going_global):
		var dir = target_pos-get_parent().position
		if ((dir).length_squared() > sqrd_thr):
			dir=dir.normalized()
			input_handler.spoofInput("setMove",true)
			input_handler.spoofInput("move",dir)
		else:
			keep_going = false
		await get_tree().process_frame
	
	input_handler.spoofInput("setMove",false)
	input_handler.spoofInput("move",Vector2.ZERO)
	stop.emit()

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

func think(_tps := 1.0):
	while (keep_going_global):
		await get_tree().process_frame
	stop.emit()
	
func take_a_break(shouldemit:=true):
	if(keep_going_global):
		input_handler.spoofInput("setMove",false)
		input_handler.spoofInput("move",Vector2.ZERO)
		if(shouldemit):
			stop.emit()

func make_charge(target : Node2D, offset:=Vector2.ZERO,_tps=3000.0,_proxim_threshold:=300000):
	
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


## Va chercher un pt strategique qui n'est pas sur l'axe joueur / peon
func go_to_orthogonal_ZAD():
	var best_pose = ZAD[0]
	var dir := target_node.position-papa.position
	var mid_point := (target_node.position+papa.position) * 0.5
	var best_score = 10000000000.0 # faites pas chier
	for pos in ZAD:
		var score = abs((pos-mid_point).dot(dir))
		if(score < best_score):
			best_score = score
			best_pose = pos
	move_to(best_pose)

## Va chercher un pt strategique qui est le plus loin du joueur et le plus proche du joueur
func flee():
	var best_pose = ZAD[0]
	var dir := target_node.position-papa.position
	#var mid_point := (target_node.position+papa.position) * 0.5
	var best_score = 10000000000.0 # faites pas chier
	for pos in ZAD:
		var score = (pos-papa.position).dot(dir)
		if(score < best_score):
			best_score = score
			best_pose = pos
	move_to(best_pose)

## Attaque suivant la position de la target.
func pick_attaque(threshold_for_charge=40.0):
	if (target_node.position-papa.position).length_squared() < threshold_for_charge*threshold_for_charge:
		for i in range(frame_react):
			# simule un temps de reaction 
			await get_tree().physics_frame
		get_tree().create_timer(0.6).timeout.connect(stop_action)
		input_handler.spoofInput("tackle",null)
	elif (target_node.position-papa.position).length_squared() < 1.7*1.7*threshold_for_charge*threshold_for_charge:
		# tkt
		get_tree().create_timer(0.3).timeout.connect(stop_action)
		make_guard(target_node)
	else :
		for i in range(frame_react):
			# simule un temps de reaction 
			await get_tree().physics_frame
		get_tree().create_timer(0.9).timeout.connect(stop_action)
		make_charge(target_node)

func pick_action():
	if(is_ia_active):
		if(target_node != null):
			keep_going_global=true
			input_handler.spoofInput("setMove",false)
			input_handler.spoofInput("move",Vector2.ZERO)
			await get_tree().create_timer(randf()*0.5+0.1).timeout
			
			var p = randf()
			
			if (p<0.1):
				get_tree().create_timer(0.5).timeout.connect(stop_action)
				follow(target_node)
			elif (p<0.3):
				flee()
			elif (p<0.4):
				get_tree().create_timer(0.5).timeout.connect(stop_action)
				make_guard(target_node)
			elif (p<0.6):
				pick_attaque()
			else:
				go_to_orthogonal_ZAD()



# Called when the node enters the scene tree for the first time.
func _ready():
	papa = get_parent() as Node2D
	if(start_on_load):
		start_ia()
		


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	delatcounter += delta

