extends Resource
class_name MapDebrisEntityDefinition

enum TYPE {
	WOODEN,
	STONE_1,
	STONE_2
}

const terrain = preload("res://resources/definitions/terrians/debris_terrain.tres")
const wood_map_view = preload("res://resources/sprites/entities/debris/wood_debris.png")
const stone_1_map_view = preload("res://resources/sprites/entities/debris/stone_debris_1.png")
const stone_2_map_view = preload("res://resources/sprites/entities/debris/stone_debris_2.png")
@export var position : Vector2i
@export var type : TYPE = TYPE.WOODEN
