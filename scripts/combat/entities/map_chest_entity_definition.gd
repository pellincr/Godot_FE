extends Resource
class_name MapChestEntityDefinition

const terrain = preload("res://resources/definitions/terrians/chest_terrain.tres")
const map_view = preload("res://resources/sprites/entities/chest_sprite.tres")
@export var position : Vector2i
@export var contents : Array[ItemDefinition]
