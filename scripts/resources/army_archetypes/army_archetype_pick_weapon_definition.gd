extends armyArchetypePickDefinition
class_name armyArchetypePickWeaponDefinition

##
# Class for a singular weapon pick within the army archetype
#
##

@export var weapon_type : Array[itemConstants.WEAPON_TYPE]
@export var item_damage_type : Array[Constants.DAMAGE_TYPE]
@export var item_scaling_type : Array[itemConstants.SCALING_TYPE]
@export var item_rarity : Rarity
