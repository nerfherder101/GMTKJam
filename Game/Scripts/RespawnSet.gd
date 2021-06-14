extends Area2D


export var controls_binded = {
	"ui_right" : "ui_up",
	"ui_left" :  "none",
	"ui_up" : "ui_right"
}

export var control_panel = "res://Prefabs//Binding1.tscn"

var control_panel_object = load(control_panel)


func _ready():
	control_panel_object = load(control_panel)
	pass


func _on_Spawn_body_entered(body):
	var current_scene = get_tree().get_current_scene()
	body.current_respawn_point = body.global_position
	body.controls_binded = controls_binded
	get_tree().get_current_scene().controls_binded = controls_binded
	get_tree().get_current_scene().get_node("HUD").get_child(0).queue_free()
	var control_panel_instance = control_panel_object.instance()
	get_tree().get_current_scene().get_node("HUD").add_child(control_panel_instance)


	pass # Replace with function body.
