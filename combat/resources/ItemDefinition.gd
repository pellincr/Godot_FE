extends Resource
class_name ItemDefinition

@export var name = ""
@export_group("Type")
@export_enum("Axe", "Sword", "Lance", "Bow", "Anima", "Light", "Dark", "Staff", "Monster", "Other" ) var item_t = 0
@export_enum("Physical", "Magic") var item_dmg_t = 0

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
