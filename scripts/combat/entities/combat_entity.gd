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

func populate_chest(definition: MapChestEntityDefinition, hp: int, def: int, res : int):
	self.name = "Chest"
	self.map_position = definition.position
	self.interaction_type = mapEntityDefinition.TYPE.CHEST
	self.terrain = definition.terrain
	self.max_hp = hp
	self.hp = hp
	self.defense = def
	self.resistance = res
	self.attack_speed = 0
	self.contents = definition.contents

func populate_door(definition: MapDoorEntityDefinition, hp: int, def: int, res : int, position: Vector2i):
	self.name = "Door"
	self.map_position = position
	self.interaction_type = mapEntityDefinition.TYPE.DOOR
	self.terrain = definition.terrain
	self.max_hp = hp
	self.hp = hp
	self.defense = def
	self.resistance = res
	self.attack_speed = 0
	self.contents = []

func populate_breakable_terrain(definition: MapBreakableTerrainEntityDefinition, hp: int, def: int, res : int):
	self.name = "Cracked Wall"
	self.map_position = definition.position
	self.interaction_type = mapEntityDefinition.TYPE.BREAKABLE_TERRAIN
	self.terrain = definition.terrain
	self.max_hp = hp
	self.hp = hp
	self.defense = def
	self.resistance = res
	self.attack_speed = 0
	self.contents = []


func set_display(map_display : CombatEntityDisplay):
	self.display = map_display

func set_entity_group(index: int):
	self.group = index
