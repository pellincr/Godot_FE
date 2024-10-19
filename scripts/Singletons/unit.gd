extends Node

class_name Unit

enum UNIT_TYPE {
	INFANTRY,
	MONSTER,
	ANIMAL,
	CALVARY,
	ARMORED
}

enum MOVEMENT_CLASS {
	GROUND,
	FLYING,
	MOUNTED
}

var unit_name : String
##var uid: String
var unit_class_key : String
var unit_type : int
var movement_class : int
var xp_worth : int ## The multiplier given when unit is defeated
var uses_custom_growths : bool

var level : int
var experience : int

var can_use_axe : bool
var can_use_sword : bool
var can_use_lance : bool
var can_use_bow : bool 
var can_use_Anima : bool
var can_use_Light : bool 
var can_use_Dark : bool 
var can_use_Staff : bool
var can_use_Monster : bool


@export_group("Unit Stats")
@export_subgroup("HP")
@export_range(1, 100, 1, "or_greater") var hp_cap = 100
@export_range(1, 100, 1, "or_greater") var max_hp = 20
@export_range(0, 100, 1, "or_greater") var hp = 20
@export_range(0, 100, 1, "or_greater") var hp_base = 1
@export_range(0, 100, 1, "or_greater") var hp_char = 1
@export_range(0, 20, 1, "or_greater") var hp_bonus = 0
@export_range(-100, 300, 5, "or_greater") var hp_growth = 0

@export_subgroup("Strength")
@export_range(1, 30, 1, "or_greater") var strength_cap = 30
@export_range(0, 30, 1, "or_greater") var strength = 0
@export_range(0,30, 1, "or_greater") var strength_base = 0
@export_range(0,30, 1, "or_greater") var strength_char = 0
@export_range(0,30, 1, "or_greater") var strength_bonus = 0
@export_range(-100, 300, 5, "or_greater") var strength_growth = 0

@export_subgroup("Magic")
@export_range(1, 100, 1, "or_greater") var magic_cap = 30
@export_range(0, 30, 1, "or_greater") var magic = 0
@export_range(0, 30, 1, "or_greater") var magic_base = 0
@export_range(0, 30, 1, "or_greater") var magic_char = 0
@export_range(0, 20, 1, "or_greater") var magic_bonus = 0
@export_range(-100, 300, 5, "or_greater") var magic_growth = 0

@export_subgroup("Skill")
@export_range(1, 100, 1, "or_greater") var skill_cap = 30
@export_range(0, 30, 1, "or_greater") var skill = 0
@export_range(0, 30, 1, "or_greater") var skill_base = 0
@export_range(0, 30, 1, "or_greater") var skill_char = 0
@export_range(0,30, 1, "or_greater") var skill_bonus = 0
@export_range(-100, 300, 5, "or_greater") var skill_growth = 0

@export_subgroup("Speed")
@export_range(1, 100, 1, "or_greater") var speed_cap = 30
@export_range(0, 30, 1, "or_greater") var speed = 0
@export_range(0, 30, 1, "or_greater") var speed_base = 0
@export_range(0, 30, 1, "or_greater") var speed_char = 0
@export_range(0, 30, 1, "or_greater") var speed_bonus = 0
@export_range(-100, 300, 5, "or_greater") var speed_growth = 0

@export_subgroup("Luck")
@export_range(1, 100, 1, "or_greater") var luck_cap = 30
@export_range(0, 30, 1, "or_greater") var luck = 0
@export_range(0, 30, 1, "or_greater") var luck_base = 0
@export_range(0, 30, 1, "or_greater") var luck_char = 0
@export_range(0, 30, 1, "or_greater") var luck_bonus = 0
@export_range(-100, 300, 5, "or_greater") var luck_growth = 0

@export_subgroup("Defense")
@export_range(1, 100, 1, "or_greater") var defense_cap = 30
@export_range(0, 30, 1, "or_greater") var defense = 0
@export_range(0, 30, 1, "or_greater") var defense_base = 0
@export_range(0, 30, 1, "or_greater") var defense_char = 0
@export_range(0, 30, 1, "or_greater") var defense_bonus = 0
@export_range(-100, 300, 5, "or_greater") var defense_growth = 0

@export_subgroup("Magic Defense")
@export_range(1, 100, 1, "or_greater") var magic_defense_cap = 30
@export_range(0, 30, 1, "or_greater") var magic_defense = 0
@export_range(0, 30, 1, "or_greater") var magic_defense_base = 0
@export_range(0, 30, 1, "or_greater") var magic_defense_char = 0
@export_range(0, 30, 1, "or_greater") var magic_defense_bonus = 0
@export_range(-100, 300, 5, "or_greater") var magic_defense_growth = 0

@export_subgroup("Movement")
@export_range(1, 100, 1, "or_greater") var movement_cap = 15
@export_range(0, 30, 1, "or_greater") var movement = 5
@export_range(0, 30, 1, "or_greater") var movement_base = 0
@export_range(0, 30, 1, "or_greater") var movement_char = 0
@export_range(0, 30, 1, "or_greater") var movement_bonus = 0

@export_subgroup("Constitution")
@export_range(1, 100, 1, "or_greater") var constitution_cap = 20
@export_range(0, 30, 1, "or_greater") var constitution = 5
@export_range(0, 30, 1, "or_greater") var constitution_base = 5
@export_range(0, 30, 1, "or_greater") var constitution_char = 0
@export_range(0, 30, 1, "or_greater") var constitution_bonus = 0

@export_range(1, 20, 1, "or_greater") var aid = 6 ## To be removed?
@export_range(1, 2, 1, "or_greater") var initiative = 1 ## to be removed

@export_group("Inventory")
@export var equipped_item : Item
##@export var inventory: ItemInventory

@export_group("Skills")
##@export var skills: Array[String]
##@export var skilL_unlock_level: Array[int]
	 
@export_group("Status Effects")
##@export var status_effects: Array[StatusEffect]

var icon: Texture2D
var map_sprite: Texture2D

static func create(unitDefinition: CombatantDefinition, characterDefinition: CharacterDefinition) -> Unit:
	var new_unit = Unit.new()
	new_unit.unit_name = characterDefinition.unit_name
	new_unit.unit_class_key = unitDefinition.unit_type_dictionary_key
	new_unit.unit_type = unitDefinition.class_t
	new_unit.movement_class = unitDefinition.movement_class
	new_unit.xp_worth = unitDefinition.xp_worth
	new_unit.uses_custom_growths = characterDefinition.uses_custom_growths
	new_unit.level = characterDefinition.level
	new_unit.experience = characterDefinition.level
	new_unit.can_use_axe = unitDefinition.can_use_axe
	new_unit.can_use_sword = unitDefinition.can_use_sword
	new_unit.can_use_lance = unitDefinition.can_use_lance
	new_unit.can_use_bow = unitDefinition.can_use_bow
	new_unit.can_use_Anima = unitDefinition.can_use_Anima
	new_unit.can_use_Light = unitDefinition.can_use_Light
	new_unit.can_use_Dark = unitDefinition.can_use_Dark
	new_unit.can_use_Staff = unitDefinition.can_use_Staff
	new_unit.can_use_Monster = unitDefinition.can_use_Monster	
	set_growths(new_unit, unitDefinition, characterDefinition)
	set_stat_bases(new_unit, unitDefinition)
	set_stat_caps(new_unit, unitDefinition)
	set_stat_char(new_unit, characterDefinition)

	new_unit.icon = unitDefinition.icon
	new_unit.map_sprite = unitDefinition.map_sprite
	new_unit.update_stats()
	##TO BE REMOVED
	new_unit.initiative = unitDefinition.initiative
	return new_unit

static func set_growths(target_unit : Unit, unitDefinition: CombatantDefinition, characterDefinition: CharacterDefinition):
	if target_unit.uses_custom_growths :
		target_unit.hp_growth = characterDefinition.hp_growth
		target_unit.strength_growth = characterDefinition.strength_growth
		target_unit.magic_growth = characterDefinition.magic_growth
		target_unit.skill_growth = characterDefinition.skill_growth
		target_unit.speed_growth = characterDefinition.speed_growth
		target_unit.luck_growth = characterDefinition.luck_growth
		target_unit.defense_growth = characterDefinition.defense_growth
		target_unit.magic_defense_growth = characterDefinition.magic_defense_growth
	else : 
		target_unit.hp_growth = characterDefinition.hp_growth + unitDefinition.hp_growth
		target_unit.strength_growth = characterDefinition.strength_growth + unitDefinition.strength_growth
		target_unit.magic_growth = characterDefinition.magic_growth + unitDefinition.magic_growth
		target_unit.skill_growth = characterDefinition.skill_growth + unitDefinition.skill_growth
		target_unit.speed_growth = characterDefinition.speed_growth + unitDefinition.speed_growth
		target_unit.luck_growth = characterDefinition.luck_growth + unitDefinition.luck_growth
		target_unit.defense_growth = characterDefinition.defense_growth + unitDefinition.defense_growth
		target_unit.magic_defense_growth = characterDefinition.magic_defense_growth + unitDefinition.magic_defense_growth

static func set_stat_bases(target_unit : Unit, unitDefinition: CombatantDefinition):
	target_unit.hp_base = unitDefinition.hp
	target_unit.strength_base = unitDefinition.strength
	target_unit.magic_base = unitDefinition.magic
	target_unit.skill_base = unitDefinition.skill
	target_unit.speed_base = unitDefinition.speed
	target_unit.luck_base = unitDefinition.luck
	target_unit.defense_base = unitDefinition.defense
	target_unit.magic_defense_base = unitDefinition.magic_defense
	target_unit.movement_base = unitDefinition.movement
	target_unit.constitution_base = unitDefinition.constitution

static func set_stat_caps(target_unit : Unit, unitDefinition: CombatantDefinition):
	target_unit.hp_cap = unitDefinition.max_hp
	target_unit.strength_cap = unitDefinition.max_trength
	target_unit.magic_cap = unitDefinition.max_magic
	target_unit.skill_cap = unitDefinition.max_skill
	target_unit.speed_cap = unitDefinition.max_speed
	target_unit.luck_cap = unitDefinition.max_luck
	target_unit.defense_cap = unitDefinition.max_defense
	target_unit.magic_defense_cap = unitDefinition.max_magic_defense
	target_unit.movement_cap = unitDefinition.max_movement
	target_unit.constitution_cap = unitDefinition.max_constitution
	
static func set_stat_char(target_unit : Unit, characterDefinition: CharacterDefinition):
	target_unit.hp_char = characterDefinition.hp
	target_unit.strength_char = characterDefinition.strength
	target_unit.magic_char = characterDefinition.magic
	target_unit.skill_char = characterDefinition.skill
	target_unit.speed_char = characterDefinition.speed
	target_unit.luck_char = characterDefinition.luck
	target_unit.defense_char = characterDefinition.defense
	target_unit.magic_defense_char = characterDefinition.magic_defense
	target_unit.movement_char = characterDefinition.movement
	target_unit.constitution_char = characterDefinition.constitution

func get_effective_stat(stat_name: String) -> int:
	return 0
	
func level_up():
	return
	
func update_stats() :
	max_hp = calculate_stat(hp_base, hp_char, hp_cap,hp_bonus)
	strength = calculate_stat(strength_base, strength_char, strength_cap,strength_bonus)
	magic = calculate_stat(magic_base, magic_char, magic_cap, magic_bonus)
	skill = calculate_stat(skill_base, skill_char, skill_cap, skill_bonus)
	speed = calculate_stat(speed_base, speed_char, speed_cap, speed_bonus)
	luck = calculate_stat(luck_base, luck_char, luck_cap, luck_bonus)	
	defense = calculate_stat(defense_base, defense_char, defense_cap, defense_bonus)	
	magic_defense = calculate_stat(magic_defense_base, magic_defense_char, magic_defense_cap, magic_defense_bonus)	
	movement = calculate_stat(movement_base, movement_char, movement_cap, movement_bonus)	
	constitution = calculate_stat(constitution_base, constitution_char, constitution_cap, constitution_bonus)	

func calculate_bonus_stats(stat:String, equipment_bonus: int, status_bonus: int, skill_bonus: int) -> int: 
	return 0
	
func calculate_stat(base: int, char_stat: int, stat_cap : int, bonus: int) -> int:
	return clampi(base + char_stat, 0, stat_cap) + bonus
