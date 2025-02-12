extends Resource
class_name MapTile

var position : Vector2i 
var terrain : Terrain

func create(posn: Vector2i, input_terrain: Terrain) -> MapTile:
	var instance = MapTile.new()
	instance.terrain = input_terrain
	instance.position = posn
	return instance
