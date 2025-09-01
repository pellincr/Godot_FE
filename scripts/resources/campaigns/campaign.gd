extends Resource
class_name Campaign

@export_subgroup("Campaign Info")
@export var name : String
@export var level_pool : LevelPool
#@export var map : CampaignMapGenerator
@export_subgroup("Campaign Draft Info")
@export var commander_draft_limit : = 1
@export var max_floor_number : int
@export var number_of_required_combat_maps : int
@export var number_of_archetypes_drafted : int
@export var rewards : String
@export var unit_unlock_rewards : Array[String]
@export var boss : String #MIGHT BE DONE IN LEVEL POOL
