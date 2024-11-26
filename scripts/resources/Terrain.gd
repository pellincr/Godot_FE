extends Resource
class_name Terrain

enum TYPE {
	BASIC,
	NATURE
	#HEAVY,
	#MOUNTED,
	#FLYING
}

@export_group("Terrain Info")
@export var name = ""
@export var db_key = ""
@export_enum("Basic", "Nature") var type : Array[int] = [0]


@export_group("Cost")
@export  var cost : Array[int] = [1,1,1,1,1]
@export_enum("Generic", "Mobile", "Heavy", "Mounted", "Flying") var blocks : Array[int] = []
@export_category("Stats Bonuses")
@export var strength = 0
@export var magic = 0
@export var skill = 0
@export var speed = 0
@export var luck = 0
@export var defense = 0
@export var magic_defense = 0
@export var avoid = 0
#@export_category("Status Effects")
