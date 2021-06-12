extends KinematicBody2D

var G = 10
var speed = 300
var jump_velocity = 400
var input = Vector2()
var velocity = Vector2()

func _ready():
	pass 

func get_input ():
	if Input.is_action_pressed("ui_right"):
		input.x = 1
	elif Input.is_action_pressed("ui_left"):
		input.x = -1
	else: 
		input.x = 0
		
	if Input.is_action_pressed("ui_up") && is_on_floor():
		input.y = 1

	else: 
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
