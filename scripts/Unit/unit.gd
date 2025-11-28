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
@export var stats : UnitStat = UnitStat.new() # what is used for external calculations
@export var effective_stats : EffectiveUnitStat = EffectiveUnitStat.new()
@export var base_stats : UnitStat  =  UnitStat.new() #Pulled from unit definition on creation
@export var promotion_stats: UnitStat = UnitStat.new()
@export var growths : UnitStat = UnitStat.new()
@export var movement_type : unitConstants.movement_type 
@export var movement : int
@export var faction : Array[unitConstants.FACTION] = []
@export var traits : Array[unitConstants.TRAITS] = []
@export var usable_weapon_types : Array[ItemConstants.WEAPON_TYPE] = []
@export_group("Inventory")
@export var inventory : Inventory
@export var inventory_stats : UnitStat = UnitStat.new()
@export var inventory_growths : UnitStat = UnitStat.new()


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

@export var death_count := 0

## STATIC FUNCTIONS USED IN CONSTRUCTORS

# create_unit_unit_character : constructor to generate a Unit using a unitCharacter
# @param unit_type_key : unit type key  
# @param unitCharacter : unitCharacter data
# @param _inventory : reference inventory to assign
# @retuns Unit : created unit
##
static func create_unit_unit_character(unit_type_key: String, unitCharacter: UnitCharacter, _inventory: Array[ItemDefinition], simulated_levels: int = 0, goliath_mode: bool = false, hyper_growth: bool = false) -> Unit:
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
	new_unit.base_stats = new_unit.get_unit_type_definition().base_stats.duplicate()
	if goliath_mode:
		new_unit.base_stats = CustomUtilityLibrary.mult_unit_stat(new_unit.base_stats, 1.8)
	update_usable_weapon_types(new_unit)
	create_inventory(new_unit, _inventory)
	update_visuals(new_unit)
	new_unit.update_stats()
	new_unit.update_growths()
	for levelup in simulated_levels:
		var level_up_stats : UnitStat = new_unit.get_level_up_value(new_unit, hyper_growth)
		new_unit.apply_level_up_value(level_up_stats,new_unit, false)
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
static func create_generic_unit(unit_type_key: String,_inventory: Array[ItemDefinition],name:String, level:int, bonus_levels:int = 0, hard_mode:bool = false, goliath_mode: bool = false, hyper_growth: bool = false, generic:bool = false) -> Unit:
	#Create a unit object
	var new_unit = Unit.new()
	new_unit.unit_type_key = unit_type_key
	new_unit.name = name
	new_unit.level = level
	if new_unit.get_unit_type_definition().tier :
		new_unit.xp_worth = new_unit.get_unit_type_definition().tier
	else:
		new_unit.xp_worth = 2
	new_unit.unit_character = null
	new_unit.movement_type = new_unit.get_unit_type_definition().movement_type
	new_unit.base_stats = new_unit.get_unit_type_definition().base_stats.duplicate()
	if goliath_mode:
		new_unit.base_stats = CustomUtilityLibrary.mult_unit_stat(new_unit.base_stats, 1.8)
	update_usable_weapon_types(new_unit)
	new_unit.update_growths()
	create_inventory(new_unit, _inventory)
	calculate_generic_level_stats(new_unit, level, bonus_levels, hard_mode, goliath_mode, hyper_growth, generic)
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
static func calculate_generic_level_stats(unit : Unit, level: int, bonus_level:int, hardmode:bool, goliath_mode:bool, hyper_growth:bool, generic: bool):
	var effective_level = level -1 + bonus_level
	var goliath_mode_mult = 1.0
	if(unit.get_unit_type_definition().tier == 3): ##TO BE IMPLEMENTED GET THE GROWTHS OF PREVIOUS CLASS
		if(unit.get_unit_type_definition().unit_promoted_from_key):
			if(hardmode):
				calculate_generic_level_stats(UnitTypeDatabase.unit_types[unit.get_unit_type_definition().unit_promoted_from_key],20,0, false, goliath_mode, hyper_growth, generic)
			else :
				calculate_generic_level_stats(UnitTypeDatabase.unit_types[unit.get_unit_type_definition().unit_promoted_from_key],10,0, false, goliath_mode, hyper_growth, generic)
				
	if goliath_mode:
		goliath_mode_mult = 1.8
	unit.level_stats.hp = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.hp, effective_level, hyper_growth)
	unit.level_stats.strength = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.strength, effective_level, hyper_growth)
	unit.level_stats.magic = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.magic, effective_level, hyper_growth)
	unit.level_stats.skill = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.skill, effective_level, hyper_growth)
	unit.level_stats.speed = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.speed, effective_level, hyper_growth)
	unit.level_stats.luck = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.luck, effective_level, hyper_growth)
	unit.level_stats.defense = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.defense, effective_level, hyper_growth)
	unit.level_stats.resistance = calculate_generic_stat(unit.get_unit_type_definition().growth_stats.resistance, effective_level, hyper_growth)

##
# calculate_generic_stat : calculcates the level up bonus for a particular stat, used when generating a generic unit
# @param levels : the number of levels to calculate 
# @param growth : the % growth for the targetted stats
##
static func	calculate_generic_stat(growth: int, levels:int, hyper_growth:bool=false, generic:bool = false) -> int:
	var _hyper_growth_bonus : int = 1
	if hyper_growth :
		_hyper_growth_bonus = 2 
	var return_value = 0
	var stat_gain_center = float(growth * levels) / float(100) 
	
	var gain_low = _hyper_growth_bonus * stat_gain_center * 3/4
	var gain_high = _hyper_growth_bonus * stat_gain_center * 5/4
	if generic: 
		gain_low = stat_gain_center
		gain_high = stat_gain_center
	var stat_gain = randf_range(gain_low, gain_high)
	return_value = floor(stat_gain)
	var stat_chance = fmod(stat_gain, return_value)
	if CustomUtilityLibrary.random_rolls_bool(stat_chance* 100, 1):
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
func level_up_stat_roll(growth_rate : int, hyper_growth: bool = false) -> int:
	var amount = floor(growth_rate/100)
	if (CustomUtilityLibrary.random_rolls_bool(fmod(growth_rate, 100),1)):
		amount += 1
	if hyper_growth:
		if (CustomUtilityLibrary.random_rolls_bool(fmod(growth_rate, 100),1)):
			amount += 1
	return amount
	
##
# level_up_stat_roll : performs calculation to see if a stat point is awarded during level up
# @param growth_rate : target stat's growth rate (%)
##
func get_level_up_value(unit: Unit = self, hyper_growth:bool = false) -> UnitStat:
	var level_stats : UnitStat = UnitStat.new()
	#var bonus_growths : UnitStat = unit.inventory.total_item_held_bonus_growths()
	
	level_stats.hp += level_up_stat_roll(unit.growths.hp, hyper_growth)
	level_stats.strength += level_up_stat_roll(unit.growths.strength, hyper_growth)
	level_stats.magic += level_up_stat_roll(unit.growths.magic, hyper_growth)
	level_stats.skill += level_up_stat_roll(unit.growths.skill, hyper_growth)
	level_stats.speed += level_up_stat_roll(unit.growths.speed, hyper_growth)
	level_stats.luck += level_up_stat_roll(unit.growths.luck, hyper_growth)
	level_stats.defense += level_up_stat_roll(unit.growths.defense, hyper_growth)
	level_stats.resistance += level_up_stat_roll(unit.growths.resistance, hyper_growth)
	#unit.update_stats()
	return level_stats

##
# level_up_stat_roll : performs calculation to see if a stat point is awarded during level up
# @param growth_rate : target stat's growth rate (%)
##
func apply_level_up_value(level : UnitStat, unit: Unit = self, increase_level:bool = true):
	level_stats = CustomUtilityLibrary.add_unit_stat(unit.level_stats, level)
	if increase_level:
		unit.level = unit.level + 1
	unit.update_stats()

##
#
#
##
func promote(promotion_unit_type : UnitTypeDefinition):
	self.unit_type_key = promotion_unit_type.db_key
	self.level = 1
	self.experience = 0
	self.xp_worth = promotion_unit_type.tier
	self.movement_type = promotion_unit_type.movement_type
	self.traits = promotion_unit_type.traits
	self.faction = promotion_unit_type.faction
	self.promotion_stats = CustomUtilityLibrary.add_unit_stat(promotion_stats, promotion_unit_type.promotion_to_stats)
	self.update_usable_weapon_types(self)
	self.update_visuals(self)
	self.update_stats()
	self.update_growths()
	hp = stats.hp
	print("ENDED PROMOTE IN UNIT.GD")
##
# update_stats : calculates the effective stats for a unit
##
func update_stats() :
	update_effective_stats_base()
	update_effective_stats_character()
	update_effective_stats_level()
	update_effective_stats_inventory()
	update_effective_stats_equipped()
	update_effective_stats_promotion()
	# status effect bonuses would go here
	stats.hp = clampi(effective_stats.max_hp.evaluate(), 0, get_unit_type_definition().maxuimum_stats.hp)
	stats.strength = clampi(effective_stats.strength.evaluate(), 0, get_unit_type_definition().maxuimum_stats.strength)
	stats.magic = clampi(effective_stats.magic.evaluate(), 0, get_unit_type_definition().maxuimum_stats.magic)
	stats.skill = clampi(effective_stats.skill.evaluate(), 0, get_unit_type_definition().maxuimum_stats.skill)
	stats.speed = clampi(effective_stats.speed.evaluate(), 0, get_unit_type_definition().maxuimum_stats.speed)
	stats.luck = clampi(effective_stats.luck.evaluate(), 0, get_unit_type_definition().maxuimum_stats.luck)
	stats.defense = clampi(effective_stats.defense.evaluate(), 0, get_unit_type_definition().maxuimum_stats.defense)
	stats.resistance = clampi(effective_stats.resistance.evaluate(), 0, get_unit_type_definition().maxuimum_stats.resistance)
	stats.movement = clampi(effective_stats.movement.evaluate(), 0, get_unit_type_definition().maxuimum_stats.movement)
	stats.constitution = clampi(effective_stats.constitution.evaluate(), 0, get_unit_type_definition().maxuimum_stats.constitution)
	if hp > stats.hp:
		hp = stats.hp 
	
	## Update Combat Stats
	attack  = calculate_attack(inventory.get_equipped_weapon())
	hit = calculate_hit(inventory.get_equipped_weapon())
	attack_speed = calculate_attack_speed(inventory.get_equipped_weapon())
	avoid = calculate_avoid(inventory.get_equipped_weapon())
	critical_avoid = calculate_critical_avoid()
	critical_hit =  calculate_critical_hit(inventory.get_equipped_weapon())
	
	
##
# update_stats : calculates the effective stats for a unit
##
func update_effective_stats_equipped() :
	#get equipped item, and add its stats where applicable
	if inventory.equipped:
		var equipped : WeaponDefinition = inventory.get_equipped_weapon()
		if equipped != null:
			#effective_stats.populate_from_equipped_weapon_definition(equipped)
			effective_stats.populate_from_unit_stat_source("Equipped", equipped.bonus_stat)
	else:
		effective_stats.remove_all_with_tag("Equipped")
	
##
# update_stats : calculates the effective stats for a unit
##
func update_effective_stats_inventory() :
	var inventory_bonus :CombatUnitStat = inventory.get_all_stats_from_held_items()
	effective_stats.populate_from_combat_unit_stat_source("Inventory", inventory_bonus)

##
# update_stats : calculates the effective stats for a unit
##
func update_effective_stats_character() :
	if unit_character != null:
		effective_stats.populate_from_unit_stat_source("Character", unit_character.stats)

##
# update_stats : calculates the effective stats for a unit
##
func update_effective_stats_level() :
	if level_stats != null:
		effective_stats.populate_from_unit_stat_source("Level_Up", level_stats)

##
# update_stats : calculates the effective stats for a unit
##
func update_effective_stats_base() :
	if base_stats != null:
		effective_stats.populate_from_unit_stat_source("Bases", base_stats)

##
# update_stats : calculates the effective stats for a unit
##
func update_effective_stats_promotion() :
	if promotion_stats != null:
		effective_stats.populate_from_unit_stat_source("Promotion", promotion_stats)

func calculate_stat(base_stat: int, char_stat: int, level_stat: int, promotion_stat: int,  stat_cap : int) -> int:
	return clampi(base_stat + char_stat + level_stat + promotion_stat, 0, stat_cap)

func calculate_attack_speed(weapon: WeaponDefinition = null) -> int:
	var as_val : int = 0
	if weapon:
		as_val =  clampi(effective_stats.attack_speed.evaluate() - clampi(weapon.weight - effective_stats.constitution.evaluate(), 0, weapon.weight),0, effective_stats.speed.evaluate())
	else : 
		if inventory.get_equipped_weapon():
			as_val = clampi(stats.speed - clampi(inventory.get_equipped_weapon().weight - stats.constitution,0, inventory.get_equipped_weapon().weight),0, stats.speed)
		else : 
			as_val = stats.speed
	return as_val
	
func calculate_hit(weapon: WeaponDefinition = null) -> int:
	var hit_value : int = 0
	if weapon:
		#hit_value = clampi(weapon.hit + (2 * stats.skill) + (stats.luck/2), 0, 500)
		hit_value = clampi(weapon.hit + effective_stats.hit.evaluate(), 0, 500)
	else :
		if inventory.get_equipped_weapon():
			hit_value = clampi(inventory.get_equipped_weapon().hit + effective_stats.hit.evaluate(), 0, 500)
	return hit_value
	
func calculate_critical_hit(weapon: WeaponDefinition = null) -> int:
	var critcal_value : int = 0
	if weapon:
		critcal_value = clampi(weapon.critical_chance + effective_stats.critical_chance.evaluate(), 0 , 500)
	else :
		if inventory.get_equipped_weapon():
			critcal_value = clampi(inventory.get_equipped_weapon().critical_chance + effective_stats.critical_chance.evaluate(), 0 , 500) 
	return critcal_value

func calculate_critical_avoid() -> int:
	return effective_stats.critical_avoid.evaluate()

func calculate_avoid(weapon: WeaponDefinition = null, terrain : Terrain = null) -> int:
	var avoid_value: int = 0
	if weapon:
		avoid_value = (2 * attack_speed) + effective_stats.avoid.evaluate()
	else :
		avoid_value = (2 * attack_speed) +  effective_stats.avoid.evaluate()
	return avoid_value

func calculate_attack(weapon: WeaponDefinition = null) -> int: 
	var attack_value : int = 0
	if weapon:
		match weapon.item_scaling_type:
			ItemConstants.SCALING_TYPE.STRENGTH:
				attack_value = int(stats.strength * weapon.item_scaling_multiplier) + weapon.damage + effective_stats.damage.evaluate()
			ItemConstants.SCALING_TYPE.MAGIC:
				attack_value = int(stats.magic * weapon.item_scaling_multiplier) + weapon.damage + effective_stats.damage.evaluate()
			ItemConstants.SCALING_TYPE.SKILL:
				attack_value = int(stats.skill * weapon.item_scaling_multiplier) + weapon.damage + effective_stats.damage.evaluate()
	else :
		if inventory.get_equipped_weapon():
			if(inventory.get_equipped_weapon().item_damage_type == 0) :
				attack_value = stats.strength  + inventory.get_equipped_weapon().damage
			else :
				attack_value = stats.magic  + inventory.get_equipped_weapon().damage
	return attack_value

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

func update_growths():
	var _inventory_bonuses: UnitStat =  UnitStat.new()
	if inventory != null:
		_inventory_bonuses = inventory.get_all_growths_from_held_items()

	if self.unit_character:
		self.growths.hp = clampi(self.unit_character.growths.hp + self.get_unit_type_definition().growth_stats.hp + _inventory_bonuses.hp, 0,200)
		self.growths.strength = clampi(self.unit_character.growths.strength + self.get_unit_type_definition().growth_stats.strength+ _inventory_bonuses.strength, 0,200)
		self.growths.magic = clampi(self.unit_character.growths.magic + self.get_unit_type_definition().growth_stats.magic+ _inventory_bonuses.magic, 0,200)
		self.growths.skill = clampi(self.unit_character.growths.skill + self.get_unit_type_definition().growth_stats.skill+ _inventory_bonuses.skill, 0,200)
		self.growths.speed = clampi(self.unit_character.growths.speed + self.get_unit_type_definition().growth_stats.speed+ _inventory_bonuses.speed, 0,200)
		self.growths.luck = clampi(self.unit_character.growths.luck + self.get_unit_type_definition().growth_stats.luck+ _inventory_bonuses.luck, 0,200)
		self.growths.defense = clampi(self.unit_character.growths.defense + self.get_unit_type_definition().growth_stats.defense+ _inventory_bonuses.defense, 0,200)
		self.growths.resistance = clampi(self.unit_character.growths.resistance + self.get_unit_type_definition().growth_stats.resistance+ _inventory_bonuses.resistance, 0,200)
	else :
		self.growths.hp = self.get_unit_type_definition().growth_stats.hp + _inventory_bonuses.hp
		self.growths.strength = self.get_unit_type_definition().growth_stats.strength + _inventory_bonuses.strength
		self.growths.magic = self.get_unit_type_definition().growth_stats.magic + _inventory_bonuses.magic
		self.growths.skill = self.get_unit_type_definition().growth_stats.skill + _inventory_bonuses.skill
		self.growths.speed = self.get_unit_type_definition().growth_stats.speed + _inventory_bonuses.speed
		self.growths.luck = self.get_unit_type_definition().growth_stats.luck + _inventory_bonuses.luck
		self.growths.defense = self.get_unit_type_definition().growth_stats.defense + _inventory_bonuses.defense 
		self.growths.resistance = self.get_unit_type_definition().growth_stats.resistance + _inventory_bonuses.resistance

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

func use_consumable_item( item: ItemDefinition):
	if item is ConsumableItemDefinition:
		match item.use_effect:
			ItemConstants.CONSUMABLE_USE_EFFECT.HEAL:
				heal(item.power)
			ItemConstants.CONSUMABLE_USE_EFFECT.STAT_BOOST:
				if item.boost_stat != null:
					unit_character.stats = CustomUtilityLibrary.add_unit_stat(unit_character.stats, item.boost_stat)
					update_stats()
				if item.boost_growth != null:
					unit_character.growths = CustomUtilityLibrary.add_unit_stat(unit_character.growths, item.boost_growth)
					update_growths()
			ItemConstants.CONSUMABLE_USE_EFFECT.STATUS_EFFECT:
				pass
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
			if not item.expended:
				if item.class_lock.is_empty() or item.class_lock == unit_type_key:
					can_equip_item = true
		else :
			print("Tried to equip weapon that class can't use")
	else :
		print("Tried to equip a non-weapon")
	return can_equip_item

func attempt_to_equip_front_item():
	if can_equip(inventory.items.front()):
		inventory.set_equipped(inventory.items.front())
	else: 
		inventory.unequip()
	update_stats()

func equip_next_available_weapon():
	# get all equippable items
	var equippables : Array[WeaponDefinition] = get_equippable_weapons()
	if not equippables.is_empty():
		inventory.set_equipped(equippables.front())

func set_equipped(item : ItemDefinition):
	if can_equip(item):
		inventory.set_equipped(item)
		update_stats()

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
	u.icon = u.get_unit_type_definition().icon
	u.map_sprite = u.get_unit_type_definition().map_sprite

static func set_movement(u :Unit): 
	u.movement = u.bonus_movment + u.get_unit_type_definition().base_stats.movement

func get_max_attack_range() -> int:
	var _items = inventory.get_items_by_range()
	for item in _items:
		if item is WeaponDefinition:
			if can_equip(item):
				if item.item_target_faction.has(ItemConstants.AVAILABLE_TARGETS.ENEMY):
					return item.attack_range.max()
	return 0

func set_hp_to_max():
	hp = stats.hp
