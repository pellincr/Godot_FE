extends armyArchetypePickDefinition
class_name armyArchetypePickWeaponDefinition

##
# Class for a singular weapon pick within the army archetype
#
##

@export var weapon_type : Array[itemConstants.WEAPON_TYPE]
@export_enum("Physical", "Magic", "NONE" ) var item_damage_type : Array[int]
@export_enum("Physical", "Magic", "NONE" ) var item_scaling_type : Array[int]
