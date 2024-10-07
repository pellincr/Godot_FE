extends Resource
class_name ItemDefinition


@export var name = ""
@export_group("Type")
@export_enum("Axe", "Sword", "Lance", "Anima", "Light", "Dark" ) var item_t = 0
@export_enum("Phsycial", "Magic") var item_dmg_t = 0

@export_group("Item Stats")
@export_range(1, 2, 1, "or_greater") var uses = 1
@export_range(0, 30, 1, "or_greater") var value = 1
@export_range(0, 30, 1, "or_greater") var range : Array[int]

@export_group("Weapon Requirements") ## TO BE IMPLEMENTED
@export_range(1, 2, 1, "Required Weapon Rank") var required_mastery = 1

@export_group("Combat Stats") ## TO BE IMPLEMENTED
@export_range(0, 30, 1, "or_greater") var damage = 1
@export_range(0, 100, 1, "or_greater") var hit = 1
@export_range(0, 30, 1, "or_greater") var critical_chance = 1
@export_range(0, 30, 1, "or_greater") var weight = 1


@export_group("Visual")
@export var icon: Texture2D
@export var map_sprite: Texture2D
@export_group("Skills")
@export var skills: Array[String]
