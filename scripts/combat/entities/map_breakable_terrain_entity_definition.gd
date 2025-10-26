extends Resource
class_name MapBreakableTerrainEntityDefinition

enum ORIENTATION {
	HORIZONTAL,
	VERTICAL
}

const terrain = preload("res://resources/definitions/terrians/cracked_stone_wall_terrain.tres")
const map_view_h = preload("res://resources/sprites/entities/breakable_terrain/breakable_wall_h.png")
const map_view_v = preload("res://resources/sprites/entities/breakable_terrain/breakable_wall_v.png")
@export var position : Vector2i
@export var orientation : ORIENTATION ##TO BE IMPLEMENTED
