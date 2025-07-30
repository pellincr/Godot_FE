extends Resource
class_name CombatMapTile

var position : Vector2i
var terrain: Terrain
var terrain_bonuses : Array[UnitStat]
var effects : Array[UnitStat]
var unit : CombatUnit
var entity : CombatMapEntity
var blocks_unit_movement : Array[int]
#var interactables: Array[InteractableTile]
