extends Resource
class_name combatMapUnitStat

var max_hp : StatModifierList
var strength : StatModifierList
var magic :  StatModifierList
var skill :  StatModifierList
var speed :  StatModifierList
var luck :  StatModifierList
var defense :  StatModifierList
var resistance :  StatModifierList

var movement :  StatModifierList
var constitution :  StatModifierList

# Extends UnitStat for use in combatMap actions and previews
var damage : StatModifierList
var hit : StatModifierList
var avoid :  StatModifierList
var attack_speed :  StatModifierList
var critical_chance : StatModifierList


#This comes straight from weapon --> update this when skills are added?
var critical_multiplier : StatModifierList
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
