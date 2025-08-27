extends Resource
class_name CombatEntity

var name : String
var active : bool = true
var destroyed : bool = false
var display : CombatEntityDisplay
var group : int
var interaction_type : mapEntityDefinition.TYPE

var map_position: Vector2i 
var terrain: Terrain = null

var max_hp = 0
var hp = 0
var defense = 0
var resistance = 0
var attack_speed = 0

var contents: Array[ItemDefinition] = []

func populate(definition: mapEntityDefinition):
	self.name = definition.name
	self.map_position = definition.position
	self.interaction_type = definition.interaction_type
	self.terrain = definition.terrain
	self.max_hp = definition.hp
	self.hp = definition.hp
	self.defense = definition.defense
	self.resistance = definition.resistance
	self.attack_speed = definition.attack_speed
	self.contents = definition.contents

func set_display(map_display : CombatEntityDisplay):
	self.display = map_display

func set_entity_group(index: int):
	self.group = index
