extends Resource
class_name Terrian


@export_group("Terrain Info")
@export var name = ""
@export var db_key = ""

@export_group("Stats")
@export_category("Generic, Mobile, Heavy, Mounted, Flying")
@export var movement_cost : Array[int] = [1,1,1,1,1]
@export_category("bonuses")
@export var defense = 0
@export var magic_defense = 0
@export var avoid = 0
