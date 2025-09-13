extends Resource
class_name ArmyArchetypeDefinition

##
# ArmyArchetypeDefinition is used to populate the army archetype database, this contains all the information when drafting archetypes
#
##

@export var name : String
@export var db_key : String
@export var rarity : Rarity
@export_group("Picks")
@export var archetype_picks : Array[armyArchetypePickDefinition]

func get_number_of_picks() -> int:
	return archetype_picks.size()
