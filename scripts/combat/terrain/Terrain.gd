extends Resource
class_name Terrain

enum TYPE {
	BASIC,
	NATURE
}
enum TERRAIN_EFFECTS {
	NONE,
	HEAL,
	DAMAGE
}
@export_group("Terrain Info")
@export var name = ""
@export var db_key = ""
@export_enum("Basic", "Nature") var type : Array[int] = [0]


@export_group("Cost")
@export  var cost : Array[int] = [1,1,1,1,1]
@export var blocks : Array[unitConstants.movement_type] = []
@export_category("Stats Bonuses")
@export var strength = 0
@export var magic = 0
@export var skill = 0
@export var speed = 0
@export var luck = 0
@export var defense = 0
@export var magic_defense = 0
@export var avoid = 0
@export_category("Status Effects")
@export_enum("BEGINNING_PHASE","ENDING_PHASE") var active_effect_phases : String = ""
@export_enum("NONE","HEAL","DAMAGE") var effect : int = 0
@export var effect_weight : int = 4
@export_category("Visual")
@export var tile_texture : Texture = null
