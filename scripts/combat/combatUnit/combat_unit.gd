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
var turn_taken : bool = false
var major_action_taken : bool = false
var minor_action_taken: bool = false
var effective_move : int = 0
var unit : Unit
var action_list :  Array[String]
var map_tile :  MapTile
var move_tile : MapTile

var map_position : Vector2i
var map_terrain : Terrain
var move_position: Vector2i
var move_terrain : Terrain
var skill_list = []
var map_display : CombatUnitDisplay
var allegience : Constants.FACTION
var ai_type: Constants.UNIT_AI_TYPE
var is_boss: bool = false

static func create(unit: Unit, team: int, ai:int = 0, boss:bool = false) -> CombatUnit:
	var instance = CombatUnit.new()
	instance.alive = true
	instance.turn_taken = false
	instance.unit = unit
	instance.ai_type = ai
	instance.allegience = team
	instance.effective_move = unit.movement
	instance.is_boss = boss
	instance.map_tile = MapTile.new()
	instance.move_tile = MapTile.new()
	return instance

func set_map_terrain(ter : Terrain) :
	map_terrain = ter
	 
func calc_map_avoid()-> int:
	if move_tile.position != map_tile.position:
		if move_tile.terrain:
			return unit.avoid + move_tile.terrain.avoid
	else: 
		if map_tile:
			return unit.avoid + move_tile.terrain.avoid
	return unit.avoid

func calc_map_avoid_staff() -> int:
	#if current_map_tile:
		#return int(unit.magic_defense * 1.5) + int(unit.luck * .5) + current_map_tile.avoid
	#else: 
		return (unit.magic_defense * 1.5) + int(unit.luck * .5)

func refresh_unit():
	self.minor_action_taken = false
	self.major_action_taken = false
	self.turn_taken = false
	refresh_move()

func refresh_move():
	if unit:
		if unit.movement:
			self.effective_move =  unit.movement
