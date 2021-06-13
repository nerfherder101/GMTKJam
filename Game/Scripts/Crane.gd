extends Node2D

func _ready():
	pass # Replace with function body.



#Draw a line from the top of the screen to where the crane is.

func _draw():
	var pos = get_position()
	draw_line(Vector2(0,-1000), Vector2(0, 0), Color(0, 0, 0), 1)
	print (pos)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
