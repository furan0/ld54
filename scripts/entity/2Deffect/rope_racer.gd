extends Node2D






# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## Trace a rope according a CollisionPolygon2D shape.
func draw_according_collision_shape(collider : CollisionPolygon2D) :
	# Made by bibi
	$rope_renderer.clear_points()
	for vertex in collider.polygon:
		$rope_renderer.add_point(vertex)
	$rope_renderer.add_point(collider.polygon[0])
