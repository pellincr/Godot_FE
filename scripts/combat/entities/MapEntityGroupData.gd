extends Resource
class_name MapEntityGroupData
@export_group("EntityGroup, OLD FOR CUSTOM")
#@export var group_index : int
@export var entities : Array[mapEntityDefinition]

@export_group("Chests")
@export var chests : Array[MapChestEntityDefinition]

@export_group("Search")
@export var searchs : Array[MapSearchEntityDefinition]

@export_group("Doors")
@export var doors : Array[MapDoorEntityDefinition]

@export_group("Breakable Terrains") #OLD TO BE REPLACED BY DEBRIS
@export var breakable_terrains : Array[MapBreakableTerrainEntityDefinition]
@export var default_breakable_terrain_hp : int  = 25
@export var default_breakable_terrain_defense : int = 0
@export var default_breakable_terrain_resistance : int = 0

@export_group("Debris")
@export var debris : Array[MapDebrisEntityDefinition]
@export var wooden_debris_hp : int  = 25
@export var default_wooden_debris_defense : int = 0
@export var default_wooden_debris_resistance : int = 0
@export var stone_debris_hp : int  = 35
@export var default_stone_debris_defense : int = 5
@export var default_stone_debris_resistance : int = 5
