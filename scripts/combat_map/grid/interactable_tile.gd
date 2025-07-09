extends Resource
class_name InteractableTile

enum INTERACTION_TYPE {
	PLAYER,
	TRIGGER,
}
enum INTERACTION_EFFECT {
	ITEM,
	MAP_CHANGE
}

@export_group("Interactable Info")
@export var interaction_name = ""

@export var requires_item: bool = false
@export var required_item_reference : ItemDefinition = null

@export var gives_item : bool = false
@export var stored_item : ItemDefinition = null

@export var intertable_tile_set_update_tile_index : Vector2i = Vector2i(-1,-1)

@export var moves_unit : bool = false
@export var move_target_position : Vector2i = Vector2i(-1,-1)

@export_group("Terrain Info")
@export var changes_terrain : bool = false
@export var terrain_tile_set_update_tile_index: Vector2i = Vector2i(-1,-1)
