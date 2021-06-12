extends TileMap

const NORMAL_TILES = {
	"ui_left" : 8,
	"ui_right" : 17,
	"ui_up" : 11
}

const GLOW_TILES = {
	"ui_left" : 14,
	"ui_right" : 13,
	"ui_up" : 12
}

var controls_location = { }

func press_key (key):
	if(key != "none"):
		var tile = controls_location[key]
		$Animation.set_cell(tile.x, tile.y, GLOW_TILES[key])
	pass

func unpress_key (key):
	if(key != "none"):
		var tile = controls_location[key]
		$Animation.set_cell(tile.x, tile.y, NORMAL_TILES[key])
	pass

func _ready():
	print ("hello")
	var tiles = $Animation.get_used_cells()
	for tile in tiles:
		var index = $Animation.get_cell(tile.x,tile.y)
		match index:
			8: # sorry I know this is sloppy but it wont leme use the dictionary
				controls_location["ui_left"] = tile
			17:
				controls_location["ui_right"] = tile
			11: 
				controls_location["ui_up"] = tile

func _process(delta):
	global_position = get_parent().global_position


