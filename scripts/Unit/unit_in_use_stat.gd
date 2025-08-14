extends Resource
class_name unitInUseStat

var damage :int =  0
var hit :int = 100
var critical_chance :int = 0

var attack_speed : int = 0
var avoid : int = 0
var critical_multiplier : float = 3

var attack_range : Array[int] = [1]
var weapon_effectiveness : Array[unitConstants.TRAITS] = []
var required_mastery : itemConstants.MASTERY_REQUIREMENT = itemConstants.MASTERY_REQUIREMENT.E

func populate(combatUnit:CombatUnit, item:ItemDefinition):
	pass
