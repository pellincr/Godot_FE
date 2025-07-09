extends Resource
class_name CombatUnit
##
# The combat unit class intakes a unit and stores the data necessary to
# perform in the combat scene
##

#Unit Data Variables
var _id: String ##TO BE REMOVED? USE UNIT_MANAGER ARRAY INDEX INSTEAD
var unit : Unit
var map_display : CombatUnitDisplay
var ai_type: Constants.UNIT_AI_TYPE


#Unit Status Variables
var alive : bool
var is_boss: bool = false
var drops_item : bool = false
var allegience : Constants.FACTION

#Unit Action Variables
var turn_taken : bool = false
var major_action_taken : bool = false
var minor_action_taken: bool = false

#Unit Move variables
var effective_move : int = 0
var map_position : Vector2i
var map_terrain : Terrain
var move_position: Vector2i
var move_terrain : Terrain

var action_list :  Array[String] ##SHOULD BE HANDLED ELSE WHERE?
var skill_list = []
var status_effects = []

#Constructor
static func create(unit: Unit, team: int, ai:int = 0, boss:bool = false) -> CombatUnit:
	var instance = CombatUnit.new()
	instance.alive = true
	instance.turn_taken = false
	instance.unit = unit
	instance.ai_type = ai
	instance.allegience = team
	instance.effective_move = unit.movement
	instance.is_boss = boss
	return instance

func set_map_terrain(ter : Terrain) :
	map_terrain = ter
	 
func calc_map_avoid()-> int: ##Can this be outsourced to the unit manager?
	if move_position != map_position:
		if move_terrain:
			return unit.avoid + move_terrain.avoid
	else: 
		if map_terrain:
			return unit.avoid + map_terrain.avoid
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
