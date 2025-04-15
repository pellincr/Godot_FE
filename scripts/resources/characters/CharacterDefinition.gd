extends Resource
class_name CharacterDefinition


@export_group("Unit Type")
@export var unit_name= ""
@export_range(1, 20, 1, "or_greater") var level = 1
@export_range(0, 100, 1, "or_greater") var experience = 0
@export var uses_custom_growths = false

@export_group("Unit Combat Stats") ## from levels and defaults
@export_range(0, 60, 1, "or_greater") var hp = 0
@export_range(0, 30, 1, "or_greater") var strength = 0
@export_range(0, 30, 1, "or_greater") var magic = 0
@export_range(0, 30, 1, "or_greater") var skill = 0
@export_range(0, 30, 1, "or_greater") var speed = 0
@export_range(0, 30, 1, "or_greater") var luck = 0
@export_range(0, 30, 1, "or_greater") var defense = 0
@export_range(0, 30, 1, "or_greater") var magic_defense = 0

@export_group("Unit Physical Stats")
@export_range(1, 20, 1, "or_greater") var movement = 0
@export_range(1, 20, 1, "or_greater") var constitution = 0
@export_range(1, 20, 1, "or_greater") var aid = 0
@export_range(1, 2, 1, "or_greater") var initiative = 1 ## initative for AI to check on class move


@export_group("Growths")
@export_range(-100, 300, 5, "or_greater") var hp_growth = 0
@export_range(-100, 300, 5, "or_greater") var strength_growth = 0
@export_range(-100, 300, 5, "or_greater") var magic_growth = 0
@export_range(-100, 300, 5, "or_greater") var skill_growth = 0
@export_range(-100, 300, 5, "or_greater") var speed_growth = 0
@export_range(-100, 300, 5, "or_greater") var luck_growth = 0
@export_range(-100, 300, 5, "or_greater") var defense_growth = 0
@export_range(-100, 300, 5, "or_greater") var magic_defense_growth = 0

##TO BE IMPLEMENTED FURTHER
##@export var inventory: Array[ItemDefinition]
@export var equipped : ItemDefinition

##TO BE IMPLEMENTED
##@export_group("Skills")
##@export var skills: Array[String]
##@export var skilL_unlock_level: Array[int]
