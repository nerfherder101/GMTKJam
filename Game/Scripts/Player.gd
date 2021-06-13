extends KinematicBody2D

var G = 20
var ACCELERATION = 700
var FRICTION = 0.25
var MAX_SPEED = 300
var jump_velocity = 550
var input = Vector2()
var velocity = Vector2()

var dead = false

var ground_timer = 0
var ground_register_time = 0.1
var on_ground = true

var controls_default = { }

var controls_binded = { }

func _ready():
	controls_default = get_parent().controls_default 
	controls_binded = get_parent().controls_binded
	
	get_node("Camera").current = true
	
	pass 


func get_input (delta):
	input.x = 0
	
	var key_array = Array(controls_default.keys())
	
	for i in controls_default:
		if (i != "none"):
			if (Input.is_action_pressed(i)):
				if (controls_binded[i] == "death"):
					Die()
					break
				input += controls_default[i]
				input += controls_default[controls_binded[i]]
				get_tree().get_current_scene().get_node("HUD").get_child(0).press_key(i)
				get_tree().get_current_scene().get_node("HUD").get_child(0).press_key(controls_binded[i])
			elif !Input.is_action_pressed(controls_binded[i]):
				if get_tree().get_current_scene().get_node("HUD").get_child(0) != null:
					get_tree().get_current_scene().get_node("HUD").get_child(0).unpress_key(i)
				
		
	if !is_on_floor():
		ground_timer += delta
	else:
		ground_timer = 0
	
	if (ground_timer >= ground_register_time):
		input.y = 0
	
	if (input.y > 0):
		ground_timer = ground_register_time
	
	if (Input.is_action_pressed("ui_accept")):
		get_parent().Spawn_Player()
		queue_free()
	pass

func _physics_process(delta):
	get_input(delta)
	
	if input.x != 0:
		velocity.x += input.x * ACCELERATION * delta 
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION)
	
	if velocity.y >= 0:
		velocity.y += G - (input.y * jump_velocity)
	elif velocity.y < 0:
		velocity.y += G
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	CheckCollisions()
	pass

func CheckCollisions ():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if (collision.collider.name == "Hazards" && !dead):
			dead = true
			Die()
	pass

func Die ():
	get_parent().Spawn_Player()
	queue_free()
	pass



