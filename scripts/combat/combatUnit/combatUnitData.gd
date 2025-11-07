extends Resource
class_name CombatUnitData

# needed for all units 
@export var name : String
@export var map_position : Vector2i
@export var level : int
@export var level_bonus : int 
#@export var hard_mode_leveling : bool = false
@export_enum( "DEFAULT", "ATTACK_IN_RANGE", "DEFEND_POINT") var ai_type: int 
@export var is_boss : bool = false
# added behind the hood to increase stats
@export_subgroup("Unit Specifics Leave Blank for Random")
@export var unit_type_key: String 
@export var inventory: Array[ItemDefinition]
@export var drops_item : bool = false
