extends Resource
class_name MapChestEntityDefinition

const terrain = preload("res://resources/definitions/terrians/chest_terrain.tres")
const map_view = preload("res://resources/sprites/entities/chests/chest.png")

@export var position : Vector2i
@export var loot_table : LootTableItem
