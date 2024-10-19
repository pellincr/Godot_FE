extends Resource
class_name CombatantDefinition


@export_group("Unit Type")
@export var unit_type_name = ""
@export var unit_type_dictionary_key = ""
@export_enum("Infantry", "Monster", "Animal", "Calvary", "Armored") var class_t = 0
@export_enum("Ground", "Flying", "Mounted") var movement_class = 0
@export_range(1, 5, 1, "or_greater") var xp_worth = 2

@export_group("Usable Weapon Types")
@export var can_use_axe = false ##"Axe", "Sword", "Lance", "Bow", "Anima", "Light", "Dark", "Staff", "Other" ) var item_t = 0
@export var can_use_sword = false
@export var can_use_lance = false
@export var can_use_bow = false
@export var can_use_Anima = false 
@export var can_use_Light = false
@export var can_use_Dark = false
@export var can_use_Staff = false
@export var can_use_Monster = false

@export_group("Base Combat Stats")
@export_range(1, 60, 1, "or_greater") var hp = 20
@export_range(0, 30, 1, "or_greater") var strength = 1
@export_range(0, 30, 1, "or_greater") var magic = 1
@export_range(0, 30, 1, "or_greater") var skill = 1
@export_range(0, 30, 1, "or_greater") var speed = 1
@export_range(0, 30, 1, "or_greater") var luck = 0
@export_range(0, 30, 1, "or_greater") var defense = 1
@export_range(0, 30, 1, "or_greater") var magic_defense = 1

@export_group("Maximum Combat Stats")
@export_range(1, 60, 1, "or_greater") var max_hp = 60
@export_range(0, 30, 1, "or_greater") var max_strength = 20
@export_range(0, 30, 1, "or_greater") var max_magic = 20
@export_range(0, 30, 1, "or_greater") var max_skill = 20
@export_range(0, 30, 1, "or_greater") var max_speed = 20
@export_range(0, 30, 1, "or_greater") var max_luck = 30
@export_range(0, 30, 1, "or_greater") var max_defense = 20
@export_range(0, 30, 1, "or_greater") var max_magic_defense = 20


@export_group("Physical Stats")
@export_range(1, 20, 1, "or_greater") var movement = 5
@export_range(1, 20, 1, "or_greater") var max_movement = 20
@export_range(1, 20, 1, "or_greater") var constitution = 6
@export_range(1, 20, 1, "or_greater") var max_constitution = 6
@export_range(1, 20, 1, "or_greater") var aid = 6
@export_range(1, 2, 1, "or_greater") var initiative = 1 ## initative for AI to check on class move


@export_group("Growths")
@export_range(0, 300, 5, "or_greater") var hp_growth = 0
@export_range(0, 300, 5, "or_greater") var strength_growth = 0
@export_range(0, 300, 5, "or_greater") var magic_growth = 0
@export_range(0, 300, 5, "or_greater") var skill_growth = 0
@export_range(0, 300, 5, "or_greater") var speed_growth = 0
@export_range(0, 300, 5, "or_greater") var luck_growth = 0
@export_range(0, 300, 5, "or_greater") var defense_growth = 0
@export_range(0, 300, 5, "or_greater") var magic_defense_growth = 0


@export_group("Visual")
@export var icon: Texture2D
@export var map_sprite: Texture2D
@export_group("Skills")
@export var skills: Array[String]
@export var skilL_unlock_level: Array[int]
