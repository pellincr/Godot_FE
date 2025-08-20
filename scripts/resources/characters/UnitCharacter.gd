extends Resource
class_name UnitCharacter

@export var name= ""
@export var level : int = 1
@export var stats : UnitStat
@export var growths : UnitStat
@export var bonus_usable_weapon_types : Array[ItemConstants.WEAPON_TYPE] = []
@export var icon: Texture2D
@export var map_sprite: Texture2D
