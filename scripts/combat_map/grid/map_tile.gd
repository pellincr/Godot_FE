extends Resource
class_name MapTile

var position : Vector2i
var terrain: Terrain
var terrain_bonuses : Array[UnitStatBonus]
var effects : Array[UnitStatBonus]
var unit : CombatUnit
var entity : CombatMapEntity
var blocks_unit_movement : Array[int]
#var interactables: Array[InteractableTile]
