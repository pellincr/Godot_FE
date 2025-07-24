extends armyArchetypePickDefinition
class_name armyArchetypePickUnitDefinition

##
# Class for a singular unit picks within the army archetype
#
##

@export var factions :Array[unitConstants.FACTION]
@export var traits : Array[unitConstants.TRAITS]
@export var rarity : UnitRarity
@export var weapon_types : Array[ItemConstants.WEAPON_TYPE] = []
@export var unit_Type : Array[String]
