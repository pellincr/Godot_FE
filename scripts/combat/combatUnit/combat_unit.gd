extends Resource

class_name CombatUnit

# Status
var alive : bool
var allegience : Constants.FACTION
var ai_type: Constants.UNIT_AI_TYPE
var is_boss: bool = false
var drops_item : bool = false
#var drops_last_item : bool = false

# Action Economy
var turn_taken : bool = false
var major_action_taken : bool = false
var minor_action_taken: bool = false
var action_list :  Array[String] #is this redundant?

var effective_move : int = 0

@export var unit : Unit

# The effective Stats of a unit
var stats : EffectiveUnitStat = EffectiveUnitStat.new()
var current_hp
# Satus Effect
var status_effects : Dictionary = {}
var status_effect_immunities : Array[String] = []

#Map info
var map_position : Vector2i
var map_terrain : Terrain
var move_position: Vector2i
var move_terrain : Terrain

#display
var map_display : CombatUnitDisplay
var draw_ranges : bool = false

static func create(unit: Unit, team: int, ai:int = 0, boss:bool = false, drops_item: bool = false) -> CombatUnit:
	var instance = CombatUnit.new()
	instance.alive = true
	instance.turn_taken = false
	instance.unit = unit
	instance.current_hp = unit.hp
	instance.ai_type = ai
	instance.allegience = team
	instance.effective_move = unit.stats.movement
	instance.is_boss = boss
	instance.drops_item = drops_item
	instance.update_unit_stats()
	return instance

func set_map_terrain(ter : Terrain) :
	map_terrain = ter
	 
func calc_map_avoid()-> int:
	if map_position != move_position:
		if move_terrain:
			return get_avoid() + move_terrain.avoid
	else: 
		if map_terrain:
			return get_avoid() + map_terrain.avoid
	return get_avoid() 

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

func update_unit_stats():
	stats.populate_unit_stats(self.unit)

func equip(wpn: WeaponDefinition):
	if unit.can_equip(wpn):
		unit.inventory.set_equipped(wpn)
		unit.update_stats()
		unit.update_growths()
		update_unit_stats()
		#stats.populate_weapon_stats(self, wpn)

func update_inventory_stats():
	unit.update_stats()
	unit.update_growths()
	update_unit_stats()
	#stats.populate_inventory_stats(self)

func un_equip_current_weapon():
	if get_equipped != null:
		unit.inventory.equipped = false
		unit.update_stats()
		update_unit_stats()
		#stats.populate_weapon_stats(self, null)

func update_display():
	if map_display != null:
		map_display.update_values()

func get_max_hp() -> int:
	return clampi(stats.max_hp.evaluate(), 1, 999)

func get_strength() -> int:
	return stats.strength.evaluate()

func get_magic() -> int:
	return stats.magic.evaluate()

func get_skill() -> int:
	return stats.skill.evaluate()

func get_speed() -> int:
	return stats.speed.evaluate()

func get_luck() -> int:
	return stats.luck.evaluate()

func get_defense() -> int:
	return stats.defense.evaluate()

func get_resistance() -> int:
	return stats.resistance.evaluate()

func get_movement() -> int:
	return stats.movement.evaluate()

func get_constitution() -> int:
	return stats.constitution.evaluate()

func get_damage() -> int:
	return clampi(stats.damage.evaluate(), 0, 99999)

func get_hit() -> int:
	return clampi(stats.hit.evaluate(), 0, 99999)

func get_avoid() -> int:
	return int(stats.avoid.evaluate())

func get_attack_speed() -> int:
	return stats.attack_speed.evaluate()

func get_critical_chance() -> int:
	return clampi(stats.critical_chance.evaluate(), 0, 99999)

func get_critical_avoid() -> int:
	return stats.critical_avoid.evaluate()

func get_critical_multiplier() -> int:
	return clampi(stats.critical_multiplier.evaluate(), 1, 99999)

func set_range_indicator(state: bool):
	draw_ranges = state
	map_display.update_values()
