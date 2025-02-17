extends ItemDefinition
class_name StaffDefinition

enum HIT_EFFECT
{
	PHYSICAL_DAMAGE,
	MAGICAL_DAMAGE,
	HEAL,
	SLEEP,
	PLACEHOLDER
}

var weapon_type = 6 #ENUM FOR STAFF IN WEAPON DEFINITION

@export_group("Staff Requirements") ## TO BE IMPLEMENTED
@export_enum("E","D","C","B","A","S", "NONE") var required_mastery = 0
@export_range(0, 30, 1) var attack_range : Array[int] = [1]

@export_group("Combat Stats") ## TO BE IMPLEMENTED
@export_range(0, 30, 1, "or_greater") var effect_weight = 0
@export var effect_scaling : bool = false
@export_range(0, 30, 1, "or_greater") var weight = 5
