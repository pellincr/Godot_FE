extends UnitStat
class_name CombatUnitStat

#hp --> this is max_hp, current hp_is still stored on unit -- Should that be changed? 
#strength
#magic
#skill
#speed
#luck
#defense
#resistance
@export var current_hp :int

@export_group("Combat Stats")
var damage : int
var hit : int

var avoid :  int
var attack_speed :  int

var critical_chance : int
var critical_multiplier :int
var critical_avoid :int
