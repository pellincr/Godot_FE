extends Resource
class_name CombatMapEntity

enum interaction_types {
	SELF,
	ADJACENT,
	SCRIPT
}
var db_key: String
var position: Vector2i 
var sprite: Texture2D
var targetable : bool 
var active : bool = true
var interaction_type : interaction_types
var terrain: Terrain = null
var display : CombatMapEntityDisplay

func interact(cu:CombatUnit):
	return
