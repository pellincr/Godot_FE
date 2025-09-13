extends Resource
class_name MapBreakableTerrainEntityDefinition

enum ORIENTATION {
	HORIZONTAL,
	VERTICAL
}

const terrain = preload("res://resources/definitions/terrians/cracked_stone_wall_terrain.tres")
const map_view_h = preload("res://resources/sprites/entities/breakable_wall_horizontal.tres")
const map_view_v = preload("res://resources/sprites/entities/breakable_wall_vertical.tres")
@export var position : Vector2i
@export var orientation : ORIENTATION ##TO BE IMPLEMENTED
