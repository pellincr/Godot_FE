extends Resource
class_name MapDoorEntityDefinition

enum ORIENTATION {
	HORIZONTAL,
	VERTICAL
}

const terrain = preload("res://resources/definitions/terrians/door_terrain.tres")
const map_view_horizontal = preload("res://resources/sprites/entities/door_new.png") 
const map_view_vertical= preload("res://resources/sprites/entities/door_new.png") # Needs new art asset
@export var positions : Array[Vector2i] # required due to doors that are larger than 1 tile
@export var orientation : ORIENTATION ##TO BE IMPLEMENTED
