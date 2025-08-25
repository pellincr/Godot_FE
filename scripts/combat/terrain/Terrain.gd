extends Resource
class_name Terrain

enum TYPE {
	BASIC,
	NATURE,
	STRUCTURE
}

enum EFFECT_SCALING {
	FLAT,
	PERCENTAGE
}

enum TERRAIN_EFFECTS {
	NONE,
	HEAL,
	DAMAGE
}
@export_group("Terrain Info")
@export var name = ""
@export var description = ""
@export var type : Array[TYPE] = [0]

@export_group("Movement Data")
@export var cost : Array[int] = [1,1,1,1,1]
@export var blocks : Array[unitConstants.movement_type] = []

@export_category("Stats Data")
@export var defense : int = 0
@export var resistance : int = 0
@export var avoid : int = 0

@export_category("Status Data")
@export var active_effect_phases : CombatMapConstants.TURN_PHASE = CombatMapConstants.TURN_PHASE.BEGINNING_PHASE
@export var effect : TERRAIN_EFFECTS = 0
@export var effect_scaling : EFFECT_SCALING = 0
@export var effect_weight : int = 0

@export_category("Visual Data")
@export var tile_texture : Texture = null
