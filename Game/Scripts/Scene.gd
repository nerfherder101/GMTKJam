extends Node2D

onready var player_prefab = preload("res://Prefabs//Player.tscn")
var spawn_pos = Vector2(200,100)

var controls_default = {
	"ui_right" : Vector2 (1,0),
	"ui_left" : Vector2 (-1,0),
	"ui_up" : Vector2 (0,1),
	"none" : Vector2 (0,0)
}

var controls_binded = {
	"ui_right" : "none",
	"ui_left" :  "ui_up",
	"ui_up" : "ui_left"
}

func _ready():
	Spawn_Player()

func Spawn_Player ():
	var player = player_prefab.instance()
	player.position = spawn_pos
	
	add_child(player)
	
	pass

