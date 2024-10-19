extends Control

var tile_type_name : String
var avoid_bonus : int
var defense_bonus : int
var x_coordinate : int
var y_coordinate: int

var terrain_icon: Texture2D

func set_tile_type_name(value: String) : 
	$Name.text = value
	self.tile_type_name = value
	
func set_avoid_bonus(value: int) : 
	$BonusContainer/Avoid.text = "Avo. " +str(value)
	self.avoid_bonus = value
	
func set_defense_bonus(value: int) : 
	$BonusContainer/Defense.text = "Def. " + str(value)
	self.defense_bonus = value

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

func set_terrain_icon(texture: Texture2D) :
	self.terrain_icon = texture;
	$terrain_icon_border/terrian_icon.texture = texture

func set_coord_string() : 
	$Coordinates.text =  ("(" + str(x_coordinate) + "," + str(y_coordinate)+ ")")
	
func set_all(tile_name:String, x: int, y:int, def:int, avo:int) : ##texture:Texture2D,
	set_tile_type_name(tile_name)
	set_avoid_bonus(avo)
	set_defense_bonus(def)
	set_xy_coordinate(x,y)
	##set_terrain_icon(texture)
