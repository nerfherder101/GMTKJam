extends KinematicBody2D




var G = 20
var ACCELERATION = 700
var FRICTION = 0.25
var MAX_SPEED = 300
var jump_velocity = 550
var input = Vector2()
var velocity = Vector2()
var current_respawn_point = null;


var ground_timer = 0
var ground_register_time = 0.1
var on_ground = true

var controls_default = { }

var controls_binded = { }

onready var anim = self.get_node("AnimatedSprite");

var cam = null


## Start death vars
var dead = false
# Crane
onready var crane_prefab = preload("res://Prefabs//Crane.tscn")
onready var crane = crane_prefab.instance()
onready var crane_animator = crane.get_node("AnimatedSprite")
var player_head_height_difference = -24
var crane_original_position
# Transition screen
onready var transition_screen_prefab = preload("res://Prefabs/Transition.tscn")
onready var transition_screen = transition_screen_prefab.instance()
# Finite state machine
var respawn_step_timer = 0
var current_respawn_step = 0
var respawn_timers = [
	{"name":"crane moving to center screen", "duration":0.6},
	{"name":"crane pauses before descending", "duration":0.2},
	{"name":"crane moving down", "duration":1.2},
	{"name":"crane moving back", "duration":0.8},
	{"name":"transition screen", "duration":1.2},
	{"name":"player has spawned", "duration":0},
]
var default_respawn_timers = respawn_timers

## End death vars

func respawn():
	pass


func _ready():
	controls_default = get_parent().controls_default 
	controls_binded = get_parent().controls_binded
	cam = get_node("Camera")
	cam.current = true
	add_child(crane)
	crane.visible = false
	add_child(transition_screen)
	transition_screen.visible = false
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
	# todo tidy this up. Tons of if statements here that could be replaced with a switch & variables that could be an array.
	if (dead):
		respawn_step_timer += delta
		var step_duration = respawn_timers[current_respawn_step].duration
		match (current_respawn_step):
			0:
				# Crane moves on X axis to player.
				anim.play("default")
				crane_animator.play("moving_right")
				crane.position.x = lerp(crane_original_position.x, 0, respawn_step_timer / step_duration)
				if (respawn_step_timer >= step_duration):
					crane_animator.play("stopping")
					crane.position.x = 0
			1:
				# Crane pauses for a moment. Plays stop animation from last step (so that it doesn't repeat the animation twice)
				if (respawn_step_timer >= step_duration):
					crane_animator.play("descending")
			2:
				# Crane descends on player.
				crane.position.y = lerp(crane_original_position.y, player_head_height_difference, respawn_step_timer / step_duration)
				if (respawn_step_timer >= step_duration):
					crane.position.y = player_head_height_difference
					crane_animator.play("grabbing")
			3:
				#move the player off the screen and then we can put him back to the checkpoint.
				self.position.y = lerp (self.position.y, -300, respawn_step_timer / step_duration)

			4:
				# Supposed to make the screen transition to black so that we can whisk the player back to the spawn point.
				transition_screen.visible = true;
				var mat = transition_screen.get_material()
				mat.set_shader_param("Cutoff", lerp(1, 0, respawn_step_timer / step_duration))
				
			5:
				# Wow! We did it!
				self.position = current_respawn_point
				self.position.y -= 50
				self.dead = false
				var mat = transition_screen.get_material()
				mat.set_shader_param("Cutoff", 1)
				respawn_timers = default_respawn_timers
				current_respawn_step = 0
				respawn_step_timer = 0
				crane.position = crane_original_position
				crane.visible = false

		if (respawn_step_timer >= step_duration):
			current_respawn_step += 1
			respawn_step_timer = 0
		return false # prevent player from moving while this is happening.

	# End crane animation / death section. This turned out to be a finite state machine and a half. Maybe if I understood godot animations it'd have been easier.
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
	crane.visible = true
	
	print ("cam ", cam.get_global_transform())
	# todo make camera go up a bit and follow the crane down.
	pass



