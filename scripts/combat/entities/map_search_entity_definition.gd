extends Resource
class_name MapSearchEntityDefinition

const WEAPON_RACK_SPRITE = preload("res://resources/sprites/entities/search/weapon_rack_full_1.png")
const WEAPON_RACK_EMPTY_SPRITE = preload("res://resources/sprites/entities/search/weapon_rack_empty.png")
const FOOD_SHELF_SPRITE = preload("res://resources/sprites/entities/search/food_counter.png")
const FOOD_SHELF_EMPTY_SPRITE = preload("res://resources/sprites/entities/search/food_counter_empty.png")
const BOOK_SHELF_SPRITE = preload("res://resources/sprites/entities/search/book_shelf.png")
const BOOK_SHELF_EMPTY_SPRITE = preload("res://resources/sprites/entities/search/book_shelf_empty.png")

enum TYPE {
	HOUSE,
	FOOD_SHELF,
	BOOK_SHELF,
	WEAPON_RACK
}
@export var type : TYPE
@export var position : Vector2i
@export var loot_table : LootTable

func get_active_map_view():
	match self.type:
		TYPE.HOUSE:
			return null
		TYPE.FOOD_SHELF:
			return FOOD_SHELF_SPRITE
		TYPE.BOOK_SHELF:
			return BOOK_SHELF_SPRITE
		TYPE.WEAPON_RACK:
			return WEAPON_RACK_SPRITE

func get_type_name():
	match self.type:
		TYPE.HOUSE:
			return "House"
		TYPE.FOOD_SHELF:
			return "Shelf"
		TYPE.BOOK_SHELF:
			return "Book Shelf"
		TYPE.WEAPON_RACK:
			return "Weapon Rack"
