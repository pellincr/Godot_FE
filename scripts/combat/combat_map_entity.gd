extends Resource
class_name CombatMapEntity

@export_enum("Generic", "Mobile", "Heavy", "Mounted", "Flying") var blocks : Array[int] = []
@export var position: Vector2i 
@export var sprite: Texture2D
@export var targetable : bool 
@export var active : bool = true
@export_enum("self", "adjacent") var interaction_type

var display : CombatMapEntityDisplay

func interact(cu:CombatUnit):
	return
