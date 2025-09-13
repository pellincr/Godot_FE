extends Resource
class_name UnitTypeDefinition

@export_group("Unit Type MetaData")
@export var unit_type_name = ""
@export var db_key : String
@export var description : String
@export_range(1, 2, 1, "or_greater") var initiative = 1 ## initative for AI to check on class move, OUTDATED CHANGE TO TIER
@export var faction : Array[unitConstants.FACTION] = []
@export var traits : Array[unitConstants.TRAITS] = []
@export var unit_rarity : Rarity
@export var movement_type : unitConstants.movement_type = 0
@export_range(1, 5, 1, "or_greater") var tier = 2
@export var promoted: bool ##OUTDATED TO BE REMOVED, USE TIER SYSTEM
@export var unit_promoted_from_key: String

@export_group("Usable Weapon Types")
@export var usable_weapon_types : Array[ItemConstants.WEAPON_TYPE] = []

@export_group("Stats")
@export var base_stats : UnitStat
@export var maxuimum_stats : UnitStat 
@export var growth_stats : UnitStat
@export var promotion_stats : UnitStat 

@export_group("Visual")
@export var icon: Texture2D
@export var map_sprite: Texture2D
@export_group("Skills")
@export var skills: Array[String]
@export var skilL_unlock_level: Array[int]

var tags : Array[String] ##TO BE CALCULATED
