extends Resource

class_name CombatUnit

enum Group
{
	PLAYERS,
	ENEMIES,
	FRIENDLY,
	NOMAD
}

# Status
var alive : bool
var allegience : Constants.FACTION
var ai_type: Constants.UNIT_AI_TYPE
var is_boss: bool = false
#var drops_last_item : bool = false

# Action Economy
var turn_taken : bool = false
var major_action_taken : bool = false
var minor_action_taken: bool = false
var action_list :  Array[String] #is this redundant?

var effective_move : int = 0

@export var unit : Unit

# The effective Stats of a unit
var stats : combatMapUnitStat = combatMapUnitStat.new()

var map_position : Vector2i
var map_terrain : Terrain

var move_position: Vector2i
var move_terrain : Terrain

var map_display : CombatUnitDisplay

static func create(unit: Unit, team: int, ai:int = 0, boss:bool = false) -> CombatUnit:
	var instance = CombatUnit.new()
	instance.alive = true
	instance.turn_taken = false
	instance.unit = unit
	instance.ai_type = ai
	instance.allegience = team
	instance.effective_move = unit.stats.movement
	instance.is_boss = boss
	return instance

func set_map_terrain(ter : Terrain) :
	map_terrain = ter
	 
func calc_map_avoid()-> int:
	if map_position != move_position:
		if move_terrain:
			return stats.avoid.evaluate() + move_terrain.avoid
	else: 
		if map_terrain:
			return stats.avoid.evaluate() + map_terrain.avoid
	return stats.avoid.evaluate() 

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
		if unit.stats.movement:
			self.effective_move =  unit.stats.movement

func update_move_tile(cmt: CombatMapTile):
	move_position = cmt.position
	move_terrain = cmt.terrain

func update_map_tile(cmt: CombatMapTile):
	map_position = cmt.position
	map_terrain = cmt.terrain

func get_equipped() -> WeaponDefinition:
	return self.unit.inventory.get_equipped_weapon()

func equip(wpn: WeaponDefinition):
	unit.inventory.set_equipped(wpn)
	stats.populate_weapon_stats(self, wpn)
