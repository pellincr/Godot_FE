extends Resource
class_name armyArchetypePickDefinition

##
# Parent class for a singular pick within the army archetype
#
##
enum PICK_TYPE
{
UNIT,
WEAPON,
ITEM #ITEM IS CURRENTLY UNUSED
}

enum SELECTION_RESPONSE
{
	NON_MUTUALLY_EXCLUSIVE, #Faction : Kingdom & Trait : Armored = returns only armored units with faction kingdom
	MUTUALLY_EXCLUSIVE, ##DEPROVISIONED IMPL LATER #Faction : Kingdom & Trait : Armored = returns all units that are kingdom and NOT ARMORED and all units that are armored that are not part of the kingdom 
	COMBINED #Faction : Kingdom & Trait : Armored = returns all armored units and all kingdom units 
}

@export var name : String
@export var type : PICK_TYPE 
@export var response_filter : SELECTION_RESPONSE
@export var volume : int
var icon : Texture2D #This can be generated later, and needs to be created in figma
