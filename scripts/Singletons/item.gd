extends Node

class_name Item

enum WEAPON_TYPE
{
	AXE,
	SWORD,
	LANCE,
	BOW,
	ANIMA,
	LIGHT,
	DARK,
	STAFF,
	MONSTER,
	OTHER
}

enum DAMAGE_TYPE
{
	PHYSICAL,
	MAGIC 
}

enum WEAPON_RANK 
{
	E,
	D,
	C,
	B,
	A,
	S,
	NONE
}

var item_name :String
var item_type: int
var item_damage_type : int

var max_uses : int
var uses : int

var attack_range : Array[int]
var class_locked: bool
var locked_class_name : String

var damage : int
var hit : int
var critical_chance : int
var weight : int

var icon: Texture2D


static func create(definition: ItemDefinition) -> Item:
	var instance = Item.new()
	instance.item_name = definition.name
	instance.item_type = definition.item_type
	instance.item_damage_type = definition.item_damage_type
	instance.max_uses = definition.uses
	instance.uses = definition.uses
	instance.attack_range = definition.attack_ranges
	instance.class_locked = definition.class_locked
	instance.locked_class_name = definition.locked_class_name
	instance.damage = definition.damage
	instance.hit = definition.hit
	instance.critical_chance = definition.critical_chance
	instance.weight = definition.weight
	instance.icon = definition.icon
	return instance

func create_itemDefinition() -> ItemDefinition:
	
	var return_object = ItemDefinition.new()
	return return_object

func use_item():
	--uses
