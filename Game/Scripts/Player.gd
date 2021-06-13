extends KinematicBody2D




var G = 20
var ACCELERATION = 700
var FRICTION = 0.25
var MAX_SPEED = 300
var jump_velocity = 550
var input = Vector2()
var velocity = Vector2()


var ground_timer = 0
var ground_register_time = 0.1
var on_ground = true

var controls_default = { }

var controls_binded = { }

onready var anim = self.get_node("AnimatedSprite");

#death vars:
var dead = false
onready var crane_prefab = preload("res://Prefabs//Crane.tscn")
onready var crane = crane_prefab.instance()
onready var crane_animator = crane.get_node("AnimatedSprite")
var player_head_height_difference = -24
var death_animation_time_x = 0
var death_animation_time_y = 0
var death_animation_duration = 1.20
var crane_original_position
var crane_pause_duration = 0.4
var crane_pause_time = 0
var grabbed_by_crane = false

var cam = null

func _ready():
	controls_default = get_parent().controls_default 
	controls_binded = get_parent().controls_binded
	cam = get_node("Camera")
	cam.current = true
	
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
	
	#play crane animation for death.
	if (dead and !grabbed_by_crane):
		anim.play("default")
		crane_animator.play("moving_right")
		#crane moves on X axis to player.
		death_animation_time_x += delta
		crane.position.x = lerp(crane_original_position.x, 0, death_animation_time_x / (death_animation_duration ))
		#crane pauses for a moment. Plays stop animation
		if (death_animation_time_x >= death_animation_duration):
			crane_animator.play("stopping")
			
			crane.position.x = 0
			if (crane_pause_time < crane_pause_duration):
				crane_pause_time += delta
			else:
				crane_animator.play("descending")
				
			#crane descends on player.
				death_animation_time_y += delta
				crane.position.y = lerp(crane_original_position.y, player_head_height_difference, death_animation_time_y / death_animation_duration)
				if (death_animation_time_y >= death_animation_duration):
					crane.position.y = player_head_height_difference
					crane_animator.play("grabbing")
					grabbed_by_crane = true
		return false
	elif (grabbed_by_crane):
		#move the player off the screen and then we can put him back to the checkpoint.
		self.position.y -= delta * 2
		#make a fade out happen here. Only needs to last 1 second or so
	
	#end crane animation / death section.
	##############################################
	
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
	
	# walk animation and sprite direction.
	if (velocity.x > 1):
		anim.play("walking")
		anim.set_scale(Vector2(sign(-1), 1))
	elif (velocity.x < -1):
		anim.play("walking")
		anim.set_scale(Vector2(sign(1), 1))
		
	else:
		anim.play("default")
	
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
	crane.position = Vector2(-270,-120)
	crane_original_position = Vector2(-270,-120)
	add_child(crane)
	# todo make camera go up a bit and follow the crane down.

	
	
	#get_parent().Spawn_Player()
	#queue_free()
	pass



