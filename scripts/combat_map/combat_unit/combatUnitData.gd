extends Resource
class_name CombatUnitData
##
# Combat Unit Data is a resource of a combat unit, and is used when loading and reading combat unit
##

@export var name : String
@export var map_position : Vector2i
@export var level : int
@export var level_bonus : int
@export var hard_mode_leveling : bool = false
@export var unitDefinition: UnitTypeDefinition
@export var inventory: Array[ItemDefinition]
@export_enum( "DEFAULT", "ATTACK_IN_RANGE", "DEFEND_POINT") var ai_type: int 
