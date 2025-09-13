extends Resource
class_name MapEntityGroupData
@export_group("EntityGroup, OLD FOR CUSTOM")
#@export var group_index : int
@export var entities : Array[mapEntityDefinition]

@export_group("Chests")
@export var chests : Array[MapChestEntityDefinition]
@export var default_chest_hp : int  = 25
@export var default_chest_defense : int = 10
@export var default_chest_resistance : int = 10

@export_group("Doors")
@export var doors : Array[MapDoorEntityDefinition]
@export var default_door_hp : int  = 50
@export var default_door_defense : int = 20
@export var default_door_resistance : int = 20

@export_group("Breakable Terrains")
@export var breakable_terrains : Array[MapBreakableTerrainEntityDefinition]
@export var default_breakable_terrain_hp : int  = 25
@export var default_breakable_terrain_defense : int = 0
@export var default_breakable_terrain_resistance : int = 0
