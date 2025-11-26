extends Resource
class_name Campaign

@export_subgroup("Campaign Info")
@export var name : String

@export_subgroup("Campaign Draft Info")
@export var commander_draft_limit : = 1
@export var number_of_archetypes_drafted : int

@export_subgroup("Campaign Map Info")
@export var max_floor_number : int
@export var number_of_required_combat_maps : int
@export var level_pool : LevelPool

@export_subgroup("Campaign Overview Info")
@export var boss_commander: CommanderDefinition
@export var difficulty : int = 1
@export var length : String = ""
@export var starting_gold = 1000

@export_subgroup("Campaign Rewards Info")
#@export var rewards : String
@export var unit_unlock_rewards : Array[UnitTypeDefinition]
