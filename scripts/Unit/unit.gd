extends Resource

class_name Unit
##
# The unit class this is the main data type for any units
#
##

@export_group("Metadata")
@export var name : String
@export var unit_type_key : String
@export var unit_character : UnitCharacter
@export var icon: Texture2D
@export var map_sprite: Texture2D
##Bonuses variables (From permanent External sources / consumables)
@export var bonus_faction : Array[unitConstants.FACTION] = []
@export var bonus_trait : Array[unitConstants.TRAITS] = []
@export var bonus_usable_weapon_types : Array[ItemConstants.WEAPON_TYPE] = []
@export var bonus_movment : int = 0

##Level & experience variables
@export var level : int
@export var level_stats : UnitStat = UnitStat.new()
@export var experience : int
@export var xp_worth : int

@export_group("Effective Stats")
@export var stats : UnitStat = UnitStat.new()
@export var growths : UnitStat = UnitStat.new()
@export var movement_type : unitConstants.movement_type 
@export var movement : int
@export var faction : Array[unitConstants.FACTION] = []
@export var traits : Array[unitConstants.TRAITS] = []
@export var usable_weapon_types : Array[ItemConstants.WEAPON_TYPE] = []

@export_group("Inventory")
@export var inventory : Inventory

@export_group("Skills")
##@export var skills: Array[String]
##@export var skilL_unlock_level: Array[int]
	 
@export_group("Status Effects")
##@export var status_effects: Array[StatusEffect]

@export_group("Combat Stats")
@export var hp : int
@export var attack : int
@export var hit : int
@export var avoid : int
@export var attack_speed : int
@export var critical_hit : int
@export var critical_avoid : int

## STATIC FUNCTIONS USED IN CONSTRUCTORS

# create_unit_unit_character : constructor to generate a Unit using a unitCharacter
# @param unit_type_key : unit type key  
# @param unitCharacter : unitCharacter data
# @param _inventory : reference inventory to assign
# @retuns Unit : created unit
##
static func create_unit_unit_character(unit_type_key: String, unitCharacter: UnitCharacter, _inventory: Array[ItemDefinition], simulated_levels: int = 0) -> Unit:
	#Create the unit
	var new_unit = Unit.new()
	#pull base data
	new_unit.unit_type_key = unit_type_key##unitType.db_key
	
	new_unit.name = unitCharacter.name
	new_unit.level = unitCharacter.level
	new_unit.xp_worth = new_unit.get_unit_type_definition().tier
	new_unit.unit_character = unitCharacter
	new_unit.movement_type = new_unit.get_unit_type_definition().movement_type
	var unit_type = UnitTypeDatabase.get_definition(unit_type_key)
	new_unit.traits = unit_type.traits
	new_unit.faction = unit_type.faction
	
	update_usable_weapon_types(new_unit)
	update_growths(new_unit)
	create_inventory(new_unit, _inventory)
	update_visuals(new_unit)
	new_unit.update_stats()
	for levelup in simulated_levels:
		var level_up_stats : UnitStat = new_unit.get_level_up_value()
		new_unit.apply_level_up_value(level_up_stats)
	new_unit.hp = new_unit.stats.hp
	return new_unit

# create_generic_unit : constructor to generate a Unit via generics (no custom growths, reserved for enemies)
# @param unit_type_key : unit type key  
# @param _inventory : reference inventory to assign
# @param name : name of the unit
# @param level : level of the unit
# @param bonus_levels : extra bonuses levels to further pad the generics stats
# @param hard_mode : does this unit get hardmode bonuses?
# @retuns Unit : created unit
##
static func create_generic_unit(unit_type_key: String,_inventory: Array[ItemDefinition],name:String, level:int, bonus_levels:int = 0, hard_mode:bool = false) -> Unit:
	#Create a unit object
	var new_unit = Unit.new()
	new_unit.unit_type_key = unit_type_key
	
	new_unit.name = name
	new_unit.level = level
	new_unit.xp_worth = new_unit.get_unit_type_definition().tier
	new_unit.unit_character = null
	new_unit.movement_type = new_unit.get_unit_type_definition().movement_type
	
	update_usable_weapon_types(new_unit)
	update_growths(new_unit)
	create_inventory(new_unit, _inventory)
	calculate_generic_level_stats(new_unit, level, bonus_levels, hard_mode)
	update_visuals(new_unit)

	new_unit.update_stats()
	new_unit.hp = new_unit.stats.hp
	return new_unit

##
# calculate_generic_stat : caclulate level_stats for generic unit
# @param unit : 
# @param level : target level
# @param bonus_level : extra levels uised in calculation, used for hardmode bonuses & promoted units
# @param hardmode : apply hardmode bonuses
##
static func calculate_generic_level_stats(unit : Unit, level: int, bonus_level:int, hardmode:bool):
	var effective_level = level -1 + bonus_level
	if(unit.get_unit_type_definition().promoted): ##TO BE IMPLEMENTED GET THE GROWTHS OF PREVIOUS CLASS
		if(unit.get_unit_type_definition().unit_promoted_from_key):
			if(hardmode):
				calculate_generic_level_stats(UnitTypeDatabase.unit_types[unit.get_unit_type_definition().unit_promoted_from_key],20,0, false)
			else :
				calculate_generic_level_stats(UnitTypeDatabase.unit_types[unit.get_unit_type_definition().unit_promoted_from_key],10,0, false)
				
	unit.level_stats.hp = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.hp, effective_level)
	unit.level_stats.strength = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.strength, effective_level)
	unit.level_stats.magic = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.magic, effective_level)
	unit.level_stats.skill = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.skill, effective_level)
	unit.level_stats.speed = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.speed, effective_level)
	unit.level_stats.luck = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.luck, effective_level)
	unit.level_stats.defense = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.defense, effective_level)
	unit.level_stats.resistance = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.resistance, effective_level)

##
# calculate_generic_stat : calculcates the level up bonus for a particular stat, used when generating a generic unit
# @param levels : the number of levels to calculate 
# @param growth : the % growth for the targetted stats
##
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

##
# create_inventory : creates a units inventory based on an input reference
# @param target_unit : unit to create a new inventory on
# @param reference_inventory : inventory to copy
##
static func create_inventory(target_unit: Unit , reference_inventory: Array[ItemDefinition]): 
	## insert a duplicate entry of each item in the
	target_unit.inventory = Inventory.create(reference_inventory, target_unit)
	if not target_unit.inventory.items.is_empty():
		for item in target_unit.inventory.items:
			if target_unit.inventory.equipped == false:
				target_unit.set_equipped(item)

##
# level_up_stat_roll : performs calculation to see if a stat point is awarded during level up
# @param growth_rate : target stat's growth rate (%)
##
func level_up_stat_roll(growth_rate : int) -> int:
	var amount = floor(growth_rate/100)
	if (CustomUtilityLibrary.random_rolls_bool(fmod(growth_rate, 100),1)):
		amount += 1
	return amount
	
##
# level_up_stat_roll : performs calculation to see if a stat point is awarded during level up
# @param growth_rate : target stat's growth rate (%)
##
func get_level_up_value(unit: Unit = self) -> UnitStat:
	var level : UnitStat = UnitStat.new()
	
	level.hp += level_up_stat_roll(unit.growths.hp)
	level.strength += level_up_stat_roll(unit.growths.strength)
	level.magic += level_up_stat_roll(unit.growths.magic)
	level.skill += level_up_stat_roll(unit.growths.skill)
	level.speed += level_up_stat_roll(unit.growths.speed)
	level.luck += level_up_stat_roll(unit.growths.luck)
	level.defense += level_up_stat_roll(unit.growths.defense)
	level.resistance += level_up_stat_roll(unit.growths.resistance)
	#unit.update_stats()
	return level

##
# level_up_stat_roll : performs calculation to see if a stat point is awarded during level up
# @param growth_rate : target stat's growth rate (%)
##
func apply_level_up_value(level : UnitStat, unit: Unit = self):
	level_stats = CustomUtilityLibrary.add_unit_stat(unit.level_stats, level)
	unit.level = unit.level + 1
	unit.update_stats()

##
# update_stats : calculates the effective stats for a unit
##
func update_stats() :
	if unit_character != null:
		stats.hp = calculate_stat(get_unit_type_definition().base_stats.hp, unit_character.stats.hp, level_stats.hp,get_unit_type_definition().maxuimum_stats.hp)
		stats.strength = calculate_stat(get_unit_type_definition().base_stats.strength, unit_character.stats.strength, level_stats.strength,get_unit_type_definition().maxuimum_stats.strength)
		stats.magic = calculate_stat(get_unit_type_definition().base_stats.magic, unit_character.stats.magic, level_stats.magic,get_unit_type_definition().maxuimum_stats.magic)
		stats.skill = calculate_stat(get_unit_type_definition().base_stats.skill, unit_character.stats.skill, level_stats.skill,get_unit_type_definition().maxuimum_stats.skill)
		stats.speed = calculate_stat(get_unit_type_definition().base_stats.speed, unit_character.stats.speed, level_stats.speed,get_unit_type_definition().maxuimum_stats.speed)
		stats.luck = calculate_stat(get_unit_type_definition().base_stats.luck, unit_character.stats.luck, level_stats.luck,get_unit_type_definition().maxuimum_stats.luck)
		stats.defense = calculate_stat(get_unit_type_definition().base_stats.defense, unit_character.stats.defense, level_stats.defense,get_unit_type_definition().maxuimum_stats.defense)
		stats.resistance = calculate_stat(get_unit_type_definition().base_stats.resistance, unit_character.stats.resistance, level_stats.resistance,get_unit_type_definition().maxuimum_stats.resistance)
		##Physical Stats
		stats.movement = calculate_stat(get_unit_type_definition().base_stats.movement, unit_character.stats.movement, level_stats.movement,get_unit_type_definition().maxuimum_stats.movement)
		stats.constitution = calculate_stat(get_unit_type_definition().base_stats.constitution, unit_character.stats.constitution, level_stats.constitution,get_unit_type_definition().maxuimum_stats.constitution)
	else :
		stats.hp = calculate_stat(get_unit_type_definition().base_stats.hp, 0, level_stats.hp,get_unit_type_definition().maxuimum_stats.hp)
		stats.strength = calculate_stat(get_unit_type_definition().base_stats.strength, 0, level_stats.strength,get_unit_type_definition().maxuimum_stats.strength)
		stats.magic = calculate_stat(get_unit_type_definition().base_stats.magic, 0, level_stats.magic,get_unit_type_definition().maxuimum_stats.magic)
		stats.skill = calculate_stat(get_unit_type_definition().base_stats.skill, 0, level_stats.skill,get_unit_type_definition().maxuimum_stats.skill)
		stats.speed = calculate_stat(get_unit_type_definition().base_stats.speed, 0, level_stats.speed,get_unit_type_definition().maxuimum_stats.speed)
		stats.luck = calculate_stat(get_unit_type_definition().base_stats.luck, 0, level_stats.luck,get_unit_type_definition().maxuimum_stats.luck)
		stats.defense = calculate_stat(get_unit_type_definition().base_stats.defense, 0, level_stats.defense,get_unit_type_definition().maxuimum_stats.defense)
		stats.resistance = calculate_stat(get_unit_type_definition().base_stats.resistance, 0, level_stats.resistance,get_unit_type_definition().maxuimum_stats.resistance)
		##Physical Stats
		stats.movement = calculate_stat(get_unit_type_definition().base_stats.movement, 0, level_stats.movement,get_unit_type_definition().maxuimum_stats.movement)
		stats.constitution = calculate_stat(get_unit_type_definition().base_stats.constitution, 0, level_stats.constitution,get_unit_type_definition().maxuimum_stats.constitution)
	###Combat stats
	attack = calculate_attack()
	attack_speed = calculate_attack_speed()
	hit = calculate_hit()
	avoid = calculate_avoid()
	critical_hit = calculate_critical_hit()
	calculate_critical_avoid()


func calculate_stat(base_stat: int, char_stat: int, level_stat: int, stat_cap : int) -> int:
	return clampi(base_stat + char_stat + level_stat, 0, stat_cap)

func calculate_attack_speed(weapon: WeaponDefinition = null) -> int:
	var as_val : int = 0
	if weapon:
		as_val =  clampi(stats.speed - clampi(weapon.weight - stats.constitution, 0, weapon.weight),0, stats.speed)
	else : 
		if inventory.get_equipped_weapon():
			as_val = clampi(stats.speed - clampi(inventory.get_equipped_weapon().weight - stats.constitution,0, inventory.get_equipped_weapon().weight),0, stats.speed)
		else : 
			as_val = stats.speed
	return as_val
	
func calculate_hit(weapon: WeaponDefinition = null) -> int:
	var hit_value : int = 0
	if weapon:
		hit_value = clampi(weapon.hit + (2 * stats.skill) + (stats.luck/2), 0, 500)
	else :
		if inventory.get_equipped_weapon():
			hit_value = clampi(inventory.get_equipped_weapon().hit + (2 * stats.skill) + (stats.luck/2), 0, 500)
	return hit_value
	
func calculate_critical_hit(weapon: WeaponDefinition = null) -> int:
	var critcal_value : int = 0
	if weapon:
		critcal_value = clampi(weapon.critical_chance + (stats.skill/2), 0 , 500)
	else :
		if inventory.get_equipped_weapon():
			critcal_value = clampi(inventory.get_equipped_weapon().critical_chance + (stats.skill/2), 0 , 500) 
	return critcal_value

func calculate_critical_avoid():
	critical_avoid =  stats.luck 

func calculate_avoid(weapon: WeaponDefinition = null, terrain : Terrain = null) -> int:
	var avoid_value: int = 0
	if weapon:
		avoid_value = (2 * calculate_attack_speed(weapon)) + stats.luck
	else :
		avoid_value = (2 * calculate_attack_speed()) + stats.luck
	if terrain:
		avoid_value += terrain.avoid
	print("Avoid Val : " + str(avoid_value))
	return avoid_value

func calculate_attack(weapon: WeaponDefinition = null) -> int: 
	var attack_value : int = 0
	if weapon:
		if(weapon.item_damage_type == 0) :
			attack_value = stats.strength  + weapon.damage
		else :
			attack_value = stats.magic  + weapon.damage
	else :
		if inventory.get_equipped_weapon():
			if(inventory.get_equipped_weapon().item_damage_type == 0) :
				attack_value = stats.strength  + inventory.get_equipped_weapon().damage
			else :
				attack_value = stats.magic  + inventory.get_equipped_weapon().damage
	return attack_value

func calculate_experience_gain_hit(hit_unit:Unit) -> int:
	print ("Entered calculate_experience_gain_hit")
	var experience_gain = 0
	var target_unit_value = 0
	var my_unit_value = 0
	var hit_unit_type = UnitTypeDatabase.get_definition(hit_unit.unit_type_key)
	if(hit_unit_type.promoted) :
		target_unit_value = 20
	var self_unit_type = UnitTypeDatabase.get_definition(self.unit_type_key)
	if (self_unit_type.promoted) :
		my_unit_value = 20
	experience_gain = clamp(((hit_unit.level + target_unit_value) - (level + my_unit_value) + 31)  / get_unit_type_definition().tier, 0, 100)
	print ("calculate_experience_gain_hit = " + str(experience_gain))
	return experience_gain

func calculate_experience_gain_kill(killed_unit:Unit) -> int:
	print ("Entered calculate_experience_gain_kill")
	var experience_gain = 0
	var target_unit_value = 0
	var my_unit_value = 0
	experience_gain = calculate_experience_gain_hit(killed_unit)
	
	var killed_unit_type = UnitTypeDatabase.get_definition(killed_unit.unit_type_key)
	if(killed_unit_type.promoted) :
		target_unit_value = 60
	
	var self_unit_type = UnitTypeDatabase.get_definition(unit_type_key)
	if (self_unit_type.promoted) :
		my_unit_value = 60
	experience_gain = clamp(experience_gain + ((killed_unit.level + target_unit_value + killed_unit.xp_worth) - (level + my_unit_value + get_unit_type_definition().tier)) + 20, 0, 100)
	print ("calculate_experience_gain_kill = " + str(experience_gain))
	return experience_gain

func heal(value: int) :
	self.hp  =  clamp(self.hp + value, 0, self.stats.hp)

func get_unit_type_definition() -> UnitTypeDefinition:
	return UnitTypeDatabase.get_definition(self.unit_type_key)
	
static func update_usable_weapon_types(u: Unit):
	u.usable_weapon_types.clear()
	u.usable_weapon_types.append_array(u.get_unit_type_definition().usable_weapon_types)
	if u.unit_character != null:
		for weapon in u.unit_character.bonus_usable_weapon_types:
			if weapon not in u.usable_weapon_types:
				u.usable_weapon_types.append(weapon)
	for weapon in u.bonus_usable_weapon_types:
		if weapon not in u.usable_weapon_types:
			u.usable_weapon_types.append(weapon)

static func update_growths(u :Unit):
	#var unit_type_growths : UnitStat = u.get_unit_type_definition().growth_stats
	if u.unit_character:
		u.growths.hp = clampi(u.unit_character.growths.hp + u.get_unit_type_definition().growth_stats.hp, 0,200)
		u.growths.strength = clampi(u.unit_character.growths.strength + u.get_unit_type_definition().growth_stats.strength, 0,200)
		u.growths.magic = clampi(u.unit_character.growths.magic + u.get_unit_type_definition().growth_stats.magic, 0,200)
		u.growths.skill = clampi(u.unit_character.growths.skill + u.get_unit_type_definition().growth_stats.skill, 0,200)
		u.growths.speed = clampi(u.unit_character.growths.speed + u.get_unit_type_definition().growth_stats.speed, 0,200)
		u.growths.luck = clampi(u.unit_character.growths.luck + u.get_unit_type_definition().growth_stats.luck, 0,200)
		u.growths.defense = clampi(u.unit_character.growths.defense + u.get_unit_type_definition().growth_stats.defense, 0,200)
		u.growths.resistance = clampi(u.unit_character.growths.resistance + u.get_unit_type_definition().growth_stats.resistance, 0,200)
	else :
		u.growths.hp = u.get_unit_type_definition().growth_stats.hp
		u.growths.strength = u.get_unit_type_definition().growth_stats.strength
		u.growths.magic = u.get_unit_type_definition().growth_stats.magic
		u.growths.skill = u.get_unit_type_definition().growth_stats.skill
		u.growths.speed = u.get_unit_type_definition().growth_stats.speed
		u.growths.luck = u.get_unit_type_definition().growth_stats.luck
		u.growths.defense = u.get_unit_type_definition().growth_stats.defense
		u.growths.resistance = u.get_unit_type_definition().growth_stats.resistance

##Inventory Methods
func get_usable_weapons_at_range(distance: int) -> Array[WeaponDefinition]:
	var usable_weapons : Array[WeaponDefinition]
	var weapons_in_inventory : Array[WeaponDefinition] = get_equippable_weapons()
	for weapon : WeaponDefinition in weapons_in_inventory:
		if weapon.attack_range.has(distance):
			usable_weapons.append(weapon)
	return usable_weapons

func get_usable_weapons_at_ranges(ranges: Array[int]) -> Array[WeaponDefinition]:
	var inventoryWeaponList : Array[WeaponDefinition] = inventory.get_weapons_with_range(ranges)
	var usable_weapons : Array[WeaponDefinition] = []
	for weapon in inventoryWeaponList:
		if !can_equip(weapon):
			usable_weapons.append(weapon)
	return usable_weapons

func use_consumable_item(item:ItemDefinition ):
	if item is ConsumableItemDefinition:
		if item.use_effect == item.USE_EFFECTS.HEAL:
			heal(item.use_effect_power)
			inventory.use_item(item)

func can_use_consumable_item(item:ItemDefinition) -> bool:
	var can_use :bool
	if item is ConsumableItemDefinition:
		if item.use_effect == item.USE_EFFECTS.HEAL:
			if self.hp == self.stats.hp:
				can_use =  false
			else: 
				can_use =  true
	return can_use

func discard_item(item:ItemDefinition):
	inventory.discard_item(item)

func can_equip(item:ItemDefinition) -> bool:
	var can_equip_item : bool = false
	if item is WeaponDefinition:
		if item.weapon_type in usable_weapon_types:
			can_equip_item = true
		else :
			print("Tried to equip weapon that class can't use")
	else :
		print("Tried to equip a non-weapon")
	return can_equip_item
	
func set_equipped(item : ItemDefinition):
	if can_equip(item):
		inventory.set_equipped(item)
		update_stats()
		print(self.name + " equipped : " + item.name)

func get_equippable_weapons() ->  Array[WeaponDefinition]:
	var equippable_weapons : Array[WeaponDefinition]
	var weapons_in_inventory : Array[WeaponDefinition] = inventory.get_weapons()
	for weapon:WeaponDefinition in weapons_in_inventory:
		if can_equip(weapon):
			equippable_weapons.append(weapon)
	return  equippable_weapons

func get_attackable_ranges() -> Array[int]:
	var attack_ranges : Array[int]
	for weapon: WeaponDefinition in get_equippable_weapons():
		if not weapon.attack_range.is_empty():
			for attack_range in weapon.attack_range:
				if not attack_ranges.has(attack_range):
					attack_ranges.append(attack_range)
	return attack_ranges

static func update_visuals(u :Unit): 
	if u.unit_character:
		if u.unit_character.icon : 
			u.icon = u.unit_character.icon
		if u.unit_character.map_sprite:
			u.map_sprite = u.unit_character.map_sprite
	if null == u.icon:
		u.icon = u.get_unit_type_definition().icon
	if null == u.map_sprite:
		u.map_sprite = u.get_unit_type_definition().map_sprite

static func set_movement(u :Unit): 
	u.movement = u.bonus_movment + u.get_unit_type_definition().base_stats.movement
