extends Resource
class_name mapEntityDefinition

enum TYPE {
	CHEST,
	DOOR,
	LEVER, # Used to trigger a group
	MOVEMENT, # TO BE IMPLEMENTED
	BREAKABLE_TERRAIN,
	DEBRIS,
	VISITABLE, # REPLACED WITH SEARCH
	ON_GROUP_TRIGGER,
	SEARCH
}

@export_group("Metadata")
@export var name: String
@export var interaction_type : TYPE

@export_group("Map Data")
@export var position: Vector2i 
@export var terrain: Terrain = null
@export var map_view : Texture2D
@export var map_view_disabled : Texture2D

@export_group("Combat Entity Stats")
@export var hp = 0
@export var defense = 0
@export var resistance = 0
@export var attack_speed = 0
@export_group("Entity Item Information")
@export var contents: Array[ItemDefinition] = []
@export_group("Entity Visual")
