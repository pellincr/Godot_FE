extends Resource
class_name EffectiveUnitStat

var max_hp : StatModifierList = StatModifierList.new()
var strength : StatModifierList = StatModifierList.new()
var magic :  StatModifierList = StatModifierList.new()
var skill :  StatModifierList = StatModifierList.new()
var speed :  StatModifierList = StatModifierList.new()
var luck :  StatModifierList = StatModifierList.new()
var defense :  StatModifierList = StatModifierList.new()
var resistance :  StatModifierList = StatModifierList.new()

var movement :  StatModifierList = StatModifierList.new()
var constitution :  StatModifierList = StatModifierList.new()

# Extends UnitStat for use in combatMap actions and previews
var damage : StatModifierList = StatModifierList.new()
var hit : StatModifierList = StatModifierList.new()
var avoid :  StatModifierList = StatModifierList.new()
var attack_speed :  StatModifierList = StatModifierList.new()
var critical_chance : StatModifierList = StatModifierList.new()
var critical_avoid : StatModifierList = StatModifierList.new()

#This comes straight from weapon --> update this when skills are added?
var critical_multiplier : StatModifierList = StatModifierList.new()
#var damage_type : Constants.DAMAGE_TYPE = 0
#var attack_range : Array[int] = []
#var weapon_effectiveness : Array[unitConstants.TRAITS] = []
#var required_mastery : ItemConstants.MASTERY_REQUIREMENT = ItemConstants.MASTERY_REQUIREMENT.E

func clear():
	max_hp.clear()
	strength.clear()
	magic.clear()
	skill.clear()
	speed.clear()
	luck.clear()
	defense.clear()
	resistance.clear()
	movement.clear()
	constitution.clear()
	damage.clear()
	hit.clear()
	avoid.clear()
	attack_speed.clear()
	critical_chance.clear()
	critical_multiplier.clear()

func populate_unit_stats(unit : Unit):
	unit.update_stats()
	# Add stats from Unit
	self.max_hp.append(StatModifier.create(unit.stats.hp, "Unit"))
	
	self.strength.append(StatModifier.create(unit.stats.strength, "Unit"))
	self.magic.append(StatModifier.create(unit.stats.magic, "Unit"))
	
	self.skill.append(StatModifier.create(unit.stats.skill, "Unit"))
	self.speed.append(StatModifier.create(unit.stats.speed, "Unit"))
	self.luck.append(StatModifier.create(unit.stats.luck, "Unit"))
	
	self.defense.append(StatModifier.create(unit.stats.defense, "Unit"))
	self.resistance.append(StatModifier.create(unit.stats.resistance, "Unit"))

	self.movement.append(StatModifier.create(unit.stats.movement, "Unit"))
	self.constitution.append(StatModifier.create(unit.stats.constitution, "Unit"))

	#other stats that require calculations
	self.damage.append(StatModifier.create(unit.attack, "Unit"))
	self.attack_speed.append(StatModifier.create(unit.attack_speed, "Unit"))
	
	self.hit.append(StatModifier.create(unit.hit, "Unit"))
	self.avoid.append(StatModifier.create(unit.avoid, "Unit"))

	self.critical_chance.append(StatModifier.create(unit.critical_hit, "Unit"))
	self.critical_multiplier.append(StatModifier.create(unit.effective_stats.critical_multiplier.evaluate(), "Unit"))


func populate_weapon_stats(cu: CombatUnit, weapon : WeaponDefinition):
	if weapon != null:
		if weapon.bonus_stat != null:
			self.max_hp.append(StatModifier.create(weapon.bonus_stat.hp, "Weapon"))
			
			self.strength.append(StatModifier.create(weapon.bonus_stat.strength, "Weapon"))
			self.magic.append(StatModifier.create(weapon.bonus_stat.magic, "Weapon"))
			
			self.skill.append(StatModifier.create(weapon.bonus_stat.skill, "Weapon"))
			self.speed.append(StatModifier.create(weapon.bonus_stat.speed, "Weapon"))
			self.luck.append(StatModifier.create(weapon.bonus_stat.luck, "Weapon"))
			
			self.defense.append(StatModifier.create(weapon.bonus_stat.defense, "Weapon"))
			self.resistance.append(StatModifier.create(weapon.bonus_stat.resistance, "Weapon"))

			self.movement.append(StatModifier.create(weapon.bonus_stat.movement, "Weapon"))
			self.constitution.append(StatModifier.create(weapon.bonus_stat.constitution, "Weapon"))

		#other stats that require calculations
		var user_damage : int = 0
		match weapon.item_scaling_type:
			ItemConstants.SCALING_TYPE.STRENGTH:
				user_damage = cu.stats.strength.evaluate()
			ItemConstants.SCALING_TYPE.SKILL:
				user_damage = cu.stats.skill.evaluate()
			ItemConstants.SCALING_TYPE.MAGIC:
				user_damage = cu.stats.magic.evaluate()
			ItemConstants.SCALING_TYPE.CONSTITUTION:
				user_damage = cu.stats.strength.evaluate()
			ItemConstants.SCALING_TYPE.NONE:
				user_damage =  0
		user_damage = floori(user_damage * weapon.item_scaling_multiplier) 
		self.damage.append(StatModifier.create(user_damage, "Unit"))
		self.damage.append(StatModifier.create(weapon.damage, "Weapon"))
		
		self.attack_speed.append(StatModifier.create(-clampi(weapon.weight - cu.stats.constitution.evaluate(), 0, weapon.weight), "Weapon"))
		
		self.hit.append(StatModifier.create(weapon.hit, "Weapon"))
		self.avoid.append(StatModifier.create(-2*clampi(weapon.weight - cu.stats.constitution.evaluate(), 0, weapon.weight), "Weapon"))

		self.critical_chance.append(StatModifier.create(weapon.critical_chance, "Weapon"))
		self.critical_multiplier.append(StatModifier.create(weapon.critical_multiplier, "Weapon"))
	else :
		self.max_hp.remove("Weapon")
		self.strength.remove("Weapon")
		self.magic.remove("Weapon")
		self.skill.remove("Weapon")
		self.speed.remove("Weapon")
		self.luck.remove("Weapon")
		self.defense.remove("Weapon")
		self.resistance.remove("Weapon")
		self.movement.remove("Weapon")
		self.constitution.remove("Weapon")
		self.damage.remove( "Unit")
		self.damage.remove("Weapon")
		self.attack_speed.remove("Weapon")
		self.hit.remove("Weapon")
		self.avoid.remove("Weapon")
		self.critical_chance.remove("Weapon")
		self.critical_multiplier.remove("Weapon")

func populate_terrain_stats(terrain:Terrain):
	self.avoid.append(StatModifier.create(terrain.avoid, "Terrain"))
	self.defense.append(StatModifier.create(terrain.defense, "Terrain"))
	self.resistance.append(StatModifier.create(terrain.resistance, "Terrain"))

func populate_inventory_stats(cu: CombatUnit):
	var inventory_bonuses : CombatUnitStat = cu.unit.inventory.total_item_held_bonus_stats()
	self.max_hp.append(StatModifier.create(inventory_bonuses.hp, "Inventory"))
	self.strength.append(StatModifier.create(inventory_bonuses.strength, "Inventory"))
	self.magic.append(StatModifier.create(inventory_bonuses.magic, "Inventory"))
	self.skill.append(StatModifier.create(inventory_bonuses.skill, "Inventory"))
	self.speed.append(StatModifier.create(inventory_bonuses.speed, "Inventory"))
	self.luck.append(StatModifier.create(inventory_bonuses.luck, "Inventory"))
	
	self.defense.append(StatModifier.create(inventory_bonuses.defense, "Inventory"))
	self.resistance.append(StatModifier.create(inventory_bonuses.resistance, "Inventory"))
	self.movement.append(StatModifier.create(inventory_bonuses.movement, "Inventory"))
	self.constitution.append(StatModifier.create(inventory_bonuses.constitution, "Inventory"))
	self.speed.append(StatModifier.create(inventory_bonuses.speed, "Inventory"))
	self.damage.append(StatModifier.create(inventory_bonuses.damage, "Inventory"))
	self.hit.append(StatModifier.create(inventory_bonuses.hit, "Inventory"))
	self.avoid.append(StatModifier.create(inventory_bonuses.avoid, "Inventory"))
	self.attack_speed.append(StatModifier.create(inventory_bonuses.attack_speed, "Inventory"))
	self.critical_chance.append(StatModifier.create(inventory_bonuses.critical_chance, "Inventory"))
	self.critical_multiplier.append(StatModifier.create(inventory_bonuses.critical_multiplier, "Inventory"))
	self.critical_avoid.append(StatModifier.create(inventory_bonuses.critical_avoid, "Inventory"))

func populate_from_combat_unit_stat_source(tag: String, source: CombatUnitStat):
	self.max_hp.append(StatModifier.create(source.hp, tag))
	self.strength.append(StatModifier.create(source.strength, tag))
	self.magic.append(StatModifier.create(source.magic, tag))
	self.skill.append(StatModifier.create(source.skill, tag))
	self.speed.append(StatModifier.create(source.speed, tag))
	self.luck.append(StatModifier.create(source.luck, tag))
	
	self.defense.append(StatModifier.create(source.defense, tag))
	self.resistance.append(StatModifier.create(source.resistance, tag))
	self.movement.append(StatModifier.create(source.movement, tag))
	self.constitution.append(StatModifier.create(source.constitution, tag))
	self.speed.append(StatModifier.create(source.speed, tag))
	self.damage.append(StatModifier.create(source.damage, tag))
	
	# Calculation based stats
	self.hit.append(StatModifier.create(int(source.hit + (2 * self.skill.get_item(tag)) + (self.luck.get_item(tag)/2)) , tag))
	self.attack_speed.append(StatModifier.create(source.attack_speed + self.speed.get_item(tag), tag))
	self.avoid.append(StatModifier.create(int(source.avoid + (2 * self.attack_speed.get_item(tag)) + self.luck.get_item(tag)), tag))
	self.critical_chance.append(StatModifier.create(int(source.critical_chance +  self.luck.get_item(tag)/2), tag))
	self.critical_multiplier.append(StatModifier.create(source.critical_multiplier, tag))
	self.critical_avoid.append(StatModifier.create(source.critical_avoid + self.luck.get_item(tag), tag))

func populate_from_unit_stat_source(tag: String, source: UnitStat):
	self.max_hp.append(StatModifier.create(source.hp, tag))
	self.strength.append(StatModifier.create(source.strength, tag))
	self.magic.append(StatModifier.create(source.magic, tag))
	self.skill.append(StatModifier.create(source.skill, tag))
	self.speed.append(StatModifier.create(source.speed, tag))
	self.luck.append(StatModifier.create(source.luck, tag))
	self.defense.append(StatModifier.create(source.defense, tag))
	self.resistance.append(StatModifier.create(source.resistance, tag))
	self.movement.append(StatModifier.create(source.movement, tag))
	self.constitution.append(StatModifier.create(source.constitution, tag))
	self.speed.append(StatModifier.create(source.speed, tag))
	
	# Calculation based stats
	self.hit.append(StatModifier.create(int(2 * source.skill) + (source.luck/2) , tag))
	self.attack_speed.append(StatModifier.create(source.speed, tag))
	self.avoid.append(StatModifier.create(int(self.luck.get_item(tag)), tag)) ##DONT ACCOUNT FOR SPEED B/C IT HAPPENS IN THE OTHER CALC
	self.critical_chance.append(StatModifier.create(int(self.skill.get_item(tag)/2 + self.luck.get_item(tag)/2), tag))
	self.critical_avoid.append(StatModifier.create(self.luck.get_item(tag), tag))

func populate_from_equipped_weapon_definition(weapon : WeaponDefinition):
		# Do bonus Stats
		if weapon.bonus_stat != null:
			self.max_hp.append(StatModifier.create(weapon.bonus_stat.hp, "Equipped"))
			self.strength.append(StatModifier.create(weapon.bonus_stat.strength, "Equipped"))
			self.magic.append(StatModifier.create(weapon.bonus_stat.magic, "Equipped"))
			self.skill.append(StatModifier.create(weapon.bonus_stat.skill, "Equipped"))
			self.speed.append(StatModifier.create(weapon.bonus_stat.speed, "Equipped"))
			self.luck.append(StatModifier.create(weapon.bonus_stat.luck, "Equipped"))
			self.defense.append(StatModifier.create(weapon.bonus_stat.defense, "Equipped"))
			self.resistance.append(StatModifier.create(weapon.bonus_stat.resistance, "Equipped"))
			self.movement.append(StatModifier.create(weapon.bonus_stat.movement, "Equipped"))
			self.constitution.append(StatModifier.create(weapon.bonus_stat.constitution, "Equipped"))
		# Calculate others
		self.damage.append(StatModifier.create(weapon.damage, "Equipped"))
		self.hit.append(StatModifier.create(weapon.hit, "Equipped"))
		self.critical_chance.append(StatModifier.create(weapon.critical_chance, "Equipped"))
		self.critical_multiplier.append(StatModifier.create(weapon.critical_multiplier, "Equipped"))
		self.attack_speed.append(StatModifier.create(self.speed.get_item("Equipped"), "Equipped"))
		self.avoid.append(StatModifier.create((2 * self.attack_speed.get_item("Equipped")) + self.luck.get_item("Equipped"), "Equipped"))

func remove_all_with_tag(tag: String):
	self.max_hp.remove(tag)
	self.strength.remove(tag)
	self.magic.remove(tag)
	self.skill.remove(tag)
	self.speed.remove(tag)
	self.luck.remove(tag)
	
	self.defense.remove(tag)
	self.resistance.remove(tag)
	self.movement.remove(tag)
	self.constitution.remove(tag)
	self.speed.remove(tag)
	self.damage.remove(tag)
	self.hit.remove(tag)
	self.avoid.remove(tag)
	self.attack_speed.remove(tag)
	self.critical_chance.remove(tag)
	self.critical_multiplier.remove(tag)
	self.critical_avoid.remove(tag)
	
