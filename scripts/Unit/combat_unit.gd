extends Resource

class_name CombatUnit

enum Group
{
	PLAYERS,
	ENEMIES,
	FRIENDLY,
	NOMAD
}

var alive : bool
var turn_taken : bool
var minor_action_taken: bool
var unit : Unit
var map_terrain : Terrain
var action_list :  Array[String]
var map_position : Vector2i
var move_position: Vector2i
var skill_list = ["attack_melee"]
var map_display : CombatUnitDisplay
var allegience : int
var ai_type: int

static func create(unit: Unit, team: int, ai:int = 0) -> CombatUnit:
	var instance = CombatUnit.new()
	instance.alive = true
	instance.turn_taken = false
	instance.unit = unit
	instance.ai_type = ai
	##instance.map_position = position
	instance.allegience = team
	return instance

func set_terrain(terrain : Terrain) :
	map_terrain = terrain
	 
func calc_map_avoid()-> int:
	if map_terrain:
		return unit.avoid + map_terrain.avoid
	else: 
		return unit.avoid

func calc_map_avoid_staff() -> int:
	if map_terrain:
		return int(unit.magic_defense * 1.5) + int(unit.luck * .5) + map_terrain.avoid
	else: 
		return (unit.magic_defense * 1.5) + int(unit.luck * .5)
