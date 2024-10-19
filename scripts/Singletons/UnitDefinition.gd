extends Resource


@export_group("Unit Type")
@export var Name = ""

@export_range(1, 20, 1, "or_greater") var level = 1
@export_range(0, 100, 1, "or_greater") var experience = 0

@export_group("Stats, Added and Subtracted from Unit Bases")
@export_range(-30, 60, 1, "or_greater") var hp = 0
@export_range(-30, 60, 1, "or_greater") var strength = 0
@export_range(-30, 60, 1, "or_greater") var magic = 0
@export_range(-30, 60, 1, "or_greater") var skill = 0
@export_range(-30, 60, 1, "or_greater") var speed = 0
@export_range(-30, 60, 1, "or_greater") var luck = 0
@export_range(-30, 60, 1, "or_greater") var defense = 0
@export_range(-30, 60, 1, "or_greater") var magic_defense = 0
@export_group("Physical Stats")
@export_range(-20, 20, 1, "or_greater") var movement = 0
@export_range(-20, 20, 1, "or_greater") var constitution = 0
@export_range(-20, 20, 1, "or_greater") var aid = 0

@export var uses_custom_growths = false 
@export_group("Growths")
@export_range(-300, 300, 5, "or_greater") var hp_growth = 0
@export_range(-300, 300, 5, "or_greater") var strength_growth = 0
@export_range(-300, 300, 5, "or_greater") var magic_growth = 0
@export_range(-300, 300, 5, "or_greater") var skill_growth = 0
@export_range(-300, 300, 5, "or_greater") var speed_growth = 0
@export_range(-300, 300, 5, "or_greater") var luck_growth = 0
@export_range(-300, 300, 5, "or_greater") var defense_growth = 0
@export_range(-300, 300, 5, "or_greater") var magic_defense_growth = 0

@export_group("Custom_Skills")
@export var current_skills: Array[String]
@export var unlockable_skills: Array[String]
@export var custom_skills_unlock_level: Array[int]

@export_group("Inventory")
@export var Inventory: Array[ItemDefinition]
