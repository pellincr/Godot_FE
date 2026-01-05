extends CombatUnitData
class_name RandomCombatUnitData

##
# Uses data from the map's unit group to generate combat unit data

#what table are we taking the unit from?
@export_enum("A",
	"B",
	"C",
	"D",
	"MOUNTED",
	"FLIER",
	"ARMOR") var unit_group : String 
@export var position_variance : bool = false
@export var position_variance_weight: int = 2
