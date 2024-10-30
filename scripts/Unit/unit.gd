extends Resource

class_name Unit

enum MOVEMENT_CLASS {
	GROUND,
	FLYING,
	MOUNTED
}

var unit_name : String
##var uid: String
var unit_class_key : String
var unit_type : Array[String]
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
@export_range(1, 100, 1, "or_greater") var max_hp = 1
@export_range(0, 100, 1, "or_greater") var hp = 1
@export_range(0, 100, 1, "or_greater") var hp_base = 1
@export_range(0, 100, 1, "or_greater") var hp_char = 0
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
@export var inventory : Inventory

@export_group("Skills")
##@export var skills: Array[String]
##@export var skilL_unlock_level: Array[int]
	 
@export_group("Status Effects")
##@export var status_effects: Array[StatusEffect]

var icon: Texture2D
var map_sprite: Texture2D

var attack : int
var hit : int
var avoid : int
var attack_speed : int
var critical_hit : int
var critical_avoid : int

static func create(unitDefinition: UnitTypeDefinition, characterDefinition: CharacterDefinition, reference_inventory: Array[ItemDefinition]) -> Unit:
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
	create_inventory(new_unit, reference_inventory)
	set_growths(new_unit, unitDefinition, characterDefinition)
	set_stat_bases(new_unit, unitDefinition)
	set_stat_caps(new_unit, unitDefinition)
	set_stat_char(new_unit, characterDefinition)

	new_unit.icon = unitDefinition.icon
	new_unit.map_sprite = unitDefinition.map_sprite
	new_unit.update_stats()
	new_unit.hp = new_unit.max_hp
	##TO BE REMOVED
	new_unit.initiative = unitDefinition.initiative
	return new_unit

static func create_generic(unitDefinition: UnitTypeDefinition, reference_inventory: Array[ItemDefinition],name:String, level:int, bonus_levels:int = 0, hard_mode:bool = false) -> Unit:
	var new_unit = Unit.new()
	new_unit.unit_name = name
	new_unit.unit_class_key = unitDefinition.db_key
	new_unit.unit_type = unitDefinition.class_type
	new_unit.movement_class = unitDefinition.movement_class
	new_unit.xp_worth = unitDefinition.xp_worth
	new_unit.uses_custom_growths = false
	new_unit.level = level
	new_unit.can_use_axe = unitDefinition.can_use_axe
	new_unit.can_use_sword = unitDefinition.can_use_sword
	new_unit.can_use_lance = unitDefinition.can_use_lance
	new_unit.can_use_bow = unitDefinition.can_use_bow
	new_unit.can_use_Anima = unitDefinition.can_use_Anima
	new_unit.can_use_Light = unitDefinition.can_use_Light
	new_unit.can_use_Dark = unitDefinition.can_use_Dark
	new_unit.can_use_Staff = unitDefinition.can_use_Staff
	new_unit.can_use_Monster = unitDefinition.can_use_Monster
	set_stat_bases(new_unit, unitDefinition)
	set_stat_caps(new_unit, unitDefinition)
	var level_stats = calculate_generic_stats(unitDefinition, level, bonus_levels, hard_mode)
	new_unit.hp_char = level_stats[0]
	new_unit.strength_char = level_stats[1]
	new_unit.magic_char = level_stats[2]
	new_unit.skill_char = level_stats[3]
	new_unit.speed_char = level_stats[4]
	new_unit.luck_char = level_stats[5]
	new_unit.defense_char = level_stats[6]
	new_unit.magic_defense_char = level_stats[7]
	create_inventory(new_unit, reference_inventory)
	new_unit.icon = unitDefinition.icon
	new_unit.map_sprite = unitDefinition.map_sprite
	new_unit.update_stats()
	new_unit.hp = new_unit.max_hp
	##TO BE REMOVED
	new_unit.initiative = unitDefinition.initiative
	return new_unit

static func calculate_generic_stats(unitDefinition: UnitTypeDefinition, level: int, bonus_level:int, hardmode:bool) -> Array[int]:
	var stat_increase_array : Array[int] = [0,0,0,0,0,0,0,0]
	var effective_level = level -1 + bonus_level
	if(unitDefinition.promoted): ##TO BE IMPLEMENTED GET THE GROWTHS OF PREVIOUS CLASS
		if(UnitTypeDatabase.unit_types.has(unitDefinition.unit_promoted_from_key)):
			if(hardmode):
				print("HARDMODE")
				stat_increase_array = calculate_generic_stats(UnitTypeDatabase.unit_types[unitDefinition.unit_promoted_from_key],20,0, false)
			else :
				stat_increase_array = calculate_generic_stats(UnitTypeDatabase.unit_types[unitDefinition.unit_promoted_from_key],10,0, false)
			print("FIRST: "+ "[UnitType] " + unitDefinition.unit_type_name +" " + str(stat_increase_array))
	##Do the actual stat calcs here
	stat_increase_array[0]  += calculate_generic_stat(unitDefinition.hp_growth, effective_level)
	stat_increase_array[1]  += calculate_generic_stat(unitDefinition.strength_growth, effective_level)
	stat_increase_array[2]  += calculate_generic_stat(unitDefinition.magic_growth, effective_level)
	stat_increase_array[3]  += calculate_generic_stat(unitDefinition.skill_growth, effective_level)
	stat_increase_array[4]  += calculate_generic_stat(unitDefinition.speed_growth, effective_level)
	stat_increase_array[5]  += calculate_generic_stat(unitDefinition.luck_growth, effective_level)
	stat_increase_array[6]  += calculate_generic_stat(unitDefinition.defense_growth, effective_level)
	stat_increase_array[7]  += calculate_generic_stat(unitDefinition.magic_defense_growth, effective_level)
	print("SECOND: " + "[UnitType] " + unitDefinition.unit_type_name +" " + str(stat_increase_array))
	return stat_increase_array
	
static func	calculate_generic_stat(growth: int, levels:int) -> int:
	var return_value = 0
	var stat_gain_center = float(growth * levels) / float(100)
	var gain_low = stat_gain_center * 7 / 8
	var gain_high = stat_gain_center * 9/8
	var stat_gain = randf_range(gain_low, gain_high)
	return_value = floor(stat_gain)
	var stat_chance = fmod(stat_gain, return_value)
	if CustomUtilityLibrary.random_rolls_bool(stat_chance, 1) :
		return_value += 1
	return return_value
	
static func set_growths(target_unit : Unit, unitDefinition: UnitTypeDefinition, characterDefinition: CharacterDefinition):
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

static func set_stat_bases(target_unit : Unit, unitDefinition: UnitTypeDefinition):
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

static func set_stat_caps(target_unit : Unit, unitDefinition: UnitTypeDefinition):
	target_unit.hp_cap = unitDefinition.max_hp
	target_unit.strength_cap = unitDefinition.max_strength
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

static func create_inventory(target_unit: Unit , reference_inventory: Array[ItemDefinition]): 
	## insert a duplicate entry of each item in the
	target_unit.inventory = Inventory.create(reference_inventory)

func get_effective_stat(stat_name: String) -> int:
	return 0
	
func level_up_player():
	var total_stat_increase
	var stat_increase_array = [0,0,0,0,0,0,0,0] #hp,str,mag,skill,speed,luck,def,mdef
	stat_increase_array[0] = level_up_stat_roll(hp_growth)
	stat_increase_array[1] = level_up_stat_roll(strength_growth)
	stat_increase_array[2] = level_up_stat_roll(magic_growth)
	stat_increase_array[3] = level_up_stat_roll(skill_growth)
	stat_increase_array[4] = level_up_stat_roll(speed_growth)
	stat_increase_array[5] = level_up_stat_roll(luck_growth)
	stat_increase_array[6] = level_up_stat_roll(defense_growth)
	stat_increase_array[7] = level_up_stat_roll(magic_defense_growth)
	## check if all stats low rolled 
	for stat in stat_increase_array :
		total_stat_increase += stat_increase_array[stat]
	## Did the user get any stat increases? If not re-randomize
	if total_stat_increase == 0 :
		stat_increase_array[0] = level_up_stat_roll(hp_growth)
		stat_increase_array[1] = level_up_stat_roll(strength_growth)
		stat_increase_array[2] = level_up_stat_roll(magic_growth)
		stat_increase_array[3] = level_up_stat_roll(skill_growth)
		stat_increase_array[4] = level_up_stat_roll(speed_growth)
		stat_increase_array[5] = level_up_stat_roll(luck_growth)
		stat_increase_array[6] = level_up_stat_roll(defense_growth)
		stat_increase_array[7] = level_up_stat_roll(magic_defense_growth)
	##Now we update the char stats with the increased versions
	hp_char += stat_increase_array[0] 
	strength_char += stat_increase_array[1] 
	magic_char += stat_increase_array[2] 
	skill_char += stat_increase_array[3] 
	speed_char += stat_increase_array[4] 
	luck_char += stat_increase_array[5] 
	defense_char += stat_increase_array[6] 
	magic_defense_char += stat_increase_array[7] 
	update_stats()
	
func level_up_stat_roll(target_growth : int) -> int:
	var amount = floor(target_growth/100)
	if (CustomUtilityLibrary.random_rolls_bool(fmod(target_growth, 100),1)):
		amount += 1
	return amount

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
	##Combat stats
	calculate_attack()
	calculate_attack_speed()
	calculate_hit()
	calculate_avoid()
	calculate_critical_hit()
	calculate_critical_avoid()

func calculate_bonus_stats(stat:String, equipment_bonus: int, status_bonus: int, skill_bonus: int) -> int: 
	return 0
	
func calculate_stat(base: int, char_stat: int, stat_cap : int, bonus: int) -> int:
	return clampi(base + char_stat, 0, stat_cap) + bonus

func calculate_attack_speed():
	attack_speed =  clampi(speed - clampi(inventory.equipped.weight - constitution, 0, 100), 0 , 100)
	
func calculate_hit():
	hit =  clampi(inventory.equipped.hit + (2 * skill) + (luck/2), 0, 500)
	
func calculate_critical_hit():
	critical_hit = clampi(inventory.equipped.critical_chance + (skill/2), 0 , 100) 

func calculate_critical_avoid():
	critical_avoid =  luck 

func calculate_avoid():
	avoid = (2 * attack_speed) + luck

func calculate_attack() : 
	if(inventory.equipped.item_damage_type == 0) :
		attack = strength  + inventory.equipped.damage
	else :
		attack = magic  + inventory.equipped.damage

func calculate_experience_gain_hit(hit_unit:Unit) -> int:
	var experience_gain = 0
	var target_unit_value = 0
	var my_unit_value = 0
	if(UnitTypeDatabase.unit_types[hit_unit.unit_class_key].unit_promoted_from_key != null) :
		target_unit_value = 20
	if (UnitTypeDatabase.unit_typess[unit_class_key].unit_promoted_from_key != null) :
		my_unit_value = 20
	experience_gain = ((hit_unit.level + target_unit_value) - (level + my_unit_value) + 31)  / xp_worth
	return experience_gain

func calculate_experience_gain_kill(killed_unit:Unit) -> int:
	var experience_gain = 0
	var target_unit_value = 0
	var my_unit_value = 0
	experience_gain = calculate_experience_gain_hit(killed_unit)
	if(UnitTypeDatabase.unit_types[killed_unit.unit_class_key].unit_promoted_from_key != null) :
		target_unit_value = 60
	if (UnitTypeDatabase.unit_types[unit_class_key].unit_promoted_from_key != null) :
		my_unit_value = 60
	experience_gain =+ ((killed_unit.level + target_unit_value + killed_unit.xp_worth) - (level + my_unit_value + xp_worth)) + 20
	return experience_gain
