extends KinematicBody2D

var G = 20
var speed = 300
var jump_velocity = 500
var input = Vector2()
var velocity = Vector2()

var controls_default = { }

var controls_binded = { }

func _ready():
	controls_default = get_parent().controls_default 
	controls_binded = get_parent().controls_binded
	pass 

func get_input ():
	input.x = 0
	
	var key_array = Array(controls_default.keys())
	
	for i in controls_default:
		if (Input.is_action_pressed(i)):
			input += controls_default[i]
			input += controls_default[controls_binded[i]]
		
	if !is_on_floor():
		input.y = 0
	pass

func _physics_process(delta):
	get_input()
	velocity.x = input.x * speed
	
	if velocity.y >= 0:
		velocity.y += G - (input.y * jump_velocity)
	elif velocity.y < 0:
		velocity.y += G
	
	velocity = move_and_slide(velocity, Vector2.UP)	
	pass
