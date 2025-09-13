extends Resource
class_name CombatMapReinforcementZoneData

enum ZONE_MAPPING_METHODS {
	CORNER, # provide 4 corners to create square zone
	COORDINATE # provide list of Vector2i that creates a zone
}
@export var zone_id : String
@export var mapping_method : ZONE_MAPPING_METHODS
@export var zone : Array[Vector2i]
@export var zone_bottom_left_vertex : Vector2i
@export var zone_top_right_vertex : Vector2i
