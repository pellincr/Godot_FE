extends Resource
class_name CombatMapUnitNetStat

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
var critical_avoid : StatModifierList = StatModifierList.new() ##NEED TO IMPL

#This comes straight from weapon --> update this when skills are added?
var critical_multiplier : StatModifierList = StatModifierList.new()
#var damage_type : Constants.DAMAGE_TYPE = 0
#var attack_range : Array[int] = []
#var weapon_effectiveness : Array[unitConstants.TRAITS] = []
#var required_mastery : itemConstants.MASTERY_REQUIREMENT = itemConstants.MASTERY_REQUIREMENT.E

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
	#stats.damage Awaits the weapon equip to see what stat to pull from
	self.attack_speed.append(StatModifier.create(self.speed.evaluate(), "Unit"))
	
	self.hit.append(StatModifier.create(int(2 * self.skill.evaluate() +self.luck.evaluate()/2), "Unit"))
	self.avoid.append(StatModifier.create(int(self.luck.evaluate() + 2 * self.speed.evaluate()), "Unit"))

	self.critical_chance.append(StatModifier.create(int(self.skill.evaluate()/2), "Unit"))
	self.critical_multiplier.append(StatModifier.create(0, "Unit"))

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
