extends Area2D

func _ready():
	
	pass


func _on_Spawn_body_entered(body):
	
	var current_scene = get_tree().get_current_scene()
	current_scene.spawn_pos = body.global_position
	
	pass # Replace with function body.
