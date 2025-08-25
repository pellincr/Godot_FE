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
@export var damage : int
@export var hit : int

@export var avoid :  int
@export var attack_speed :  int

@export var critical_chance : int
@export var critical_multiplier :int
@export var critical_avoid :int
