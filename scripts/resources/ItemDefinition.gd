extends Resource
class_name ItemDefinition

@export var name = ""
@export_group("Type")
@export_enum("Axe", "Sword", "Lance", "Bow", "Anima", "Light", "Dark", "Staff", "Monster", "Other" ) var item_type = 0
@export_enum("Physical", "Magic") var item_damage_type = 0

@export_group("Item Stats")
@export_range(1, 2, 1, "or_greater") var uses = 50
@export_range(0, 30, 1, "or_greater") var value = 35
@export_range(0, 30, 1, "or_greater") var attack_ranges : Array[int]

@export_group("Weapon Requirements") ## TO BE IMPLEMENTED
@export_enum("E","D","C","B","A","S", "NONE") var required_mastery = 0
@export var class_locked = false
@export var locked_class_name = ""
@export_group("Combat Stats") ## TO BE IMPLEMENTED
@export_range(0, 30, 1, "or_greater") var damage = 0
@export_range(0, 100, 1, "or_greater") var hit = 100
@export_range(0, 30, 1, "or_greater") var critical_chance = 0
@export_range(0, 30, 1, "or_greater") var weight = 5


@export_group("Visual")
@export var icon: Texture2D


static func create_from_item(reference:Item) -> ItemDefinition:
	var instance = ItemDefinition.new()
	instance.name = reference.item_name
	instance.item_type = reference.item_type
	instance.item_damage_type = reference.item_damage_type
	instance.max_uses = reference.uses
	instance.uses = reference.uses
	instance.attack_range = reference.attack_ranges
	instance.class_locked = reference.class_locked
	instance.locked_class_name = reference.locked_class_name
	instance.damage = reference.damage
	instance.hit = reference.hit
	instance.critical_chance = reference.critical_chance
	instance.weight = reference.weight
	instance.icon = reference.icon
	return instance
