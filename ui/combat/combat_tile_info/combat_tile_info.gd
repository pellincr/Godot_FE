extends Control
const BLANK_TERRAIN = preload("res://resources/definitions/terrians/blank_terrain.tres")

var x_coordinate : int
var y_coordinate: int

var terrain : Terrain = BLANK_TERRAIN
var terrain_icon: Texture2D

func update_name() : 
	$VBoxContainer/UpperTilePanel/UpperTileContainer/HBoxContainer/Name.text = terrain.name
	
func update_avoid_bonus() : 
	$VBoxContainer/LowerBonusPanel/LowerBonusContainer/BonusContainer/Avoid.text = "AVO " +str(terrain.avoid)
	
func update_defense_bonus() : 
	$VBoxContainer/LowerBonusPanel/LowerBonusContainer/BonusContainer/Defense.text = "DEF " + str(terrain.defense)

func update_magic_defense_bonus() : 
	$VBoxContainer/LowerBonusPanel/LowerBonusContainer/BonusContainer/Special.text = "RES " + str(terrain.magic_defense)

func set_x_coordinates(value: int) :
	self.x_coordinate = value
	set_coord_string()
	
func set_y_coordinate(value: int) :
	self.y_coordinate = value
	set_coord_string()
	
func set_xy_coordinate(x: int, y:int) :
	self.x_coordinate = x
	self.y_coordinate = y
	set_coord_string()

func update_terrain_icon() :
	$VBoxContainer/UpperTilePanel/UpperTileContainer/HBoxContainer/terrian_icon.texture = terrain.tile_texture

func set_coord_string() : 
	$VBoxContainer/UpperTilePanel/UpperTileContainer/HBoxContainer/terrian_icon/Coordinates.text =  ("(" + str(x_coordinate) + "," + str(y_coordinate)+ ")")
	
func set_terrain(t: Terrain):
	self.terrain = t
	
func set_all(t:Terrain, x: int, y:int) : ##texture:Texture2D,
	set_xy_coordinate(x,y)
	if t:
		set_terrain(t)
		update_name()
		update_avoid_bonus()
		update_defense_bonus()
		update_magic_defense_bonus()
		update_terrain_icon()
	##set_terrain_icon(texture)
