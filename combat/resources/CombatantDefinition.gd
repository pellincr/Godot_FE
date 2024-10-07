extends Resource
class_name CombatantDefinition


@export var name = ""
@export_group("Class")
@export_enum("Melee", "Ranged", "Magic") var class_t = 0
@export_enum("Ground", "Flying", "Mounted") var class_m = 0

@export_group("Combat Stats")
@export_range(1, 2, 1, "or_greater") var max_hp = 1
@export_range(0, 30, 1, "or_greater") var attack = 1
@export_range(0, 30, 1, "or_greater") var skill = 1
@export_range(0, 30, 1, "or_greater") var speed = 1
@export_range(0, 30, 1, "or_greater") var luck = 1
@export_range(0, 30, 1, "or_greater") var defense = 1
@export_range(0, 30, 1, "or_greater") var magic_defense = 1

@export_group("Physical Stats")
@export_range(1, 3, 1, "or_greater") var movement = 3
@export_range(1, 10, 1, "or_greater") var constitution = 1
@export_range(1, 10, 1, "or_greater") var aid = 1
@export_enum("Ground", "Flying", "Mounted") var affinity = 0

@export_range(1, 2, 1, "or_greater") var initiative = 1 ## to be removed




@export_group("Visual")
@export var icon: Texture2D
@export var map_sprite: Texture2D
@export_group("Skills")
@export var skills: Array[String]
@export_group("Inventory")
@export var items: Array[String]
@export var currently_equipped = ""
