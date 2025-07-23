extends Resource
class_name CombatUnitData

@export var name : String
@export var map_position : Vector2i
@export var level : int
@export var level_bonus : int
@export var hard_mode_leveling : bool = false
@export var unit_type_key: String#UnitTypeDefinition
@export var inventory: Array[ItemDefinition]
@export_enum( "DEFAULT", "ATTACK_IN_RANGE", "DEFEND_POINT") var ai_type: int 
