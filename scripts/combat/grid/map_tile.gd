extends Resource
class_name MapTile

var position : Vector2i 
var terrain : Terrain

func create(posn: Vector2i, input_terrain: Terrain) -> MapTile:
	var instance = MapTile.new()
	instance.terrain = input_terrain
	instance.position = posn
	return instance

func set_position(posn: Vector2i):
	self.position = posn

func set_terrain(ter: Terrain):
	self.terrain = ter
