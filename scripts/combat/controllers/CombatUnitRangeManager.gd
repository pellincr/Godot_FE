extends Node
class_name CombatUnitRangeManager

# GAME GRID
@export var game_grid : CombatMapGrid

func _init(game_grid : CombatMapGrid) -> void:
		self.game_grid = game_grid
# Vars
var max_range : Dictionary[CombatUnit, TileGroup]
var enemy_range : Dictionary[CombatUnit, TileGroup]
var units_in_range_of_tile : Dictionary[Vector2i, UnitGroup]

var selected_unit_range_tiles : Array[Vector2i] = []
var enemy_range_tiles: Array[Vector2i] = []

# LIST THAT MANAGES SELECTED UNIT RANGEe
var selected_unit_list : Array[CombatUnit] = []


func set_game_grid(game_grid : CombatMapGrid):
	self.game_grid = game_grid

func process_unit_move(combatUnit: CombatUnit):
	update_effected_entries([combatUnit.map_position, combatUnit.move_position])
	update_combat_unit_range_data(combatUnit)

func process_unit_die(combatUnit: CombatUnit):
	remove_unit(combatUnit)
	#remove_selected_unit(combatUnit)
	update_effected_entries([combatUnit.map_position])

##
# Updates the manager's dictionaries and arrays to deal with an update on a certain tile(s), for example a unit dying, a unit moving etc.
##
func update_effected_entries(updated_tiles: Array[Vector2i]):
	# parse each tile
	var cache:  Dictionary[CombatUnit, bool] = {}
	for tile in updated_tiles:
		if units_in_range_of_tile.has(tile):
			var _effected_units = units_in_range_of_tile[tile].data
			for combatUnit in _effected_units:
				# have we already re-calculated for this unit?
				if not cache.has(combatUnit):
					# update the unit's info and the cache
					update_combat_unit_effective_range_data(combatUnit)
					cache[combatUnit] = true
	update_enemy_range_tiles()
	update_selected_unit_range_tiles(selected_unit_list)

##
# Called when a unit's max range has an effected tile, this will re-calculated the effective range tiles for the unit
##
func update_combat_unit_effective_range_data(combatUnit: CombatUnit):
	# get the effective range
	var _enemy_range = get_effective_unit_range(combatUnit)
	#replace the enemy_range entry
	enemy_range.set(combatUnit, TileGroup.new(_enemy_range))

##
# Called when a unit moves and its range data needs to be re-calculated, updates all data involved with CombatUnit
##
func update_combat_unit_range_data(combatUnit: CombatUnit):
	# get the max range 
	var _max_range = get_max_unit_range(combatUnit)
	max_range.set(combatUnit, TileGroup.new(_max_range))
	# get the effective range
	var _enemy_range = get_effective_unit_range(combatUnit)
	enemy_range.set(combatUnit, TileGroup.new(_enemy_range))
	# remove old data from the map
	if max_range.has(combatUnit):
		for tile in max_range[combatUnit].data:
			if units_in_range_of_tile.has(tile):
				units_in_range_of_tile[tile].data.erase(combatUnit)
				if units_in_range_of_tile[tile].data.is_empty():
					units_in_range_of_tile.erase(tile)
	# add tiles to effected tile map
	for tile in _max_range:
		if units_in_range_of_tile.has(tile):
			units_in_range_of_tile[tile].data.append(combatUnit)
		else:
			var _combat_unit_array :Array[CombatUnit] = [combatUnit]
			units_in_range_of_tile[tile] = UnitGroup.new(_combat_unit_array)

func update_enemy_range_tiles():
	enemy_range_tiles.clear()
	var cache : Dictionary[Vector2i, bool] = {}
	for tileGroup in enemy_range.values():
		for tile in tileGroup.data:
			if not cache.has(tile):
				enemy_range_tiles.append(tile)
				cache.set(tile, true)
	#iterate through enemy_range map and populate

func update_selected_unit_range_tiles(selected_units: Array[CombatUnit] = selected_unit_list):
	selected_unit_range_tiles.clear()
	var cache : Dictionary[Vector2i, bool] = {}
	for key in selected_units:
		for tile in enemy_range[key].data:
			if not cache.has(tile):
				selected_unit_range_tiles.append(tile)
				cache.set(tile, true)

func remove_unit(combatUnit: CombatUnit):
	if max_range.has(combatUnit):
		var unit_tiles = max_range[combatUnit].data
		# remove all the instances of the combat unit being in the units_in_range_of_tile dictionary
		for tile in unit_tiles:
			units_in_range_of_tile[tile].data.erase(combatUnit)
		#remove entries from other maps
		max_range.erase(combatUnit)
		enemy_range.erase(combatUnit)
		selected_unit_list.erase(combatUnit)

func add_unit(combatUnit: CombatUnit):
	# get the max range 
	var _max_range = get_max_unit_range(combatUnit)
	max_range.set(combatUnit, TileGroup.new(_max_range))
	# get the effective range
	var _enemy_range = get_effective_unit_range(combatUnit)
	enemy_range.set(combatUnit, TileGroup.new(_enemy_range))
	# add tiles to effected tile map
	for tile in _max_range:
		if units_in_range_of_tile.has(tile):
			units_in_range_of_tile[tile].data.append(combatUnit)
		else:
			var _combat_unit_array :Array[CombatUnit] = [combatUnit]
			units_in_range_of_tile[tile] = UnitGroup.new(_combat_unit_array)

func get_max_unit_range(combatUnit : CombatUnit) -> Array[Vector2i]:
	var _arr : Array[Vector2i] =  []
	if combatUnit.ai_type == CombatMapConstants.UNIT_AI_TYPE.DEFEND_POINT:
		var _max_range = 0
		var _ranges = combatUnit.unit.inventory.get_available_attack_ranges()
		if not _ranges.is_empty:
			_max_range = _ranges.max()
		return game_grid.get_range_DFS(_max_range, combatUnit.map_position)
	else :
		# get move tiles that is absolute max (no effect from terrain or units etc.)
		var _movable_tiles = game_grid.get_range_DFS(combatUnit.unit.stats.movement, combatUnit.map_position)
		# get the edge of the maximum tiles
		var _edge_array = game_grid.find_edges(_movable_tiles)
		# return all the tiles that can be reached
		var _attack_tiles = game_grid.get_range_multi_origin_DFS(combatUnit.unit.get_max_attack_range(), _edge_array)
		_arr.append_array(_movable_tiles)
		_arr.append_array(_attack_tiles)
		return _arr

func get_effective_unit_range(combatUnit : CombatUnit) -> Array[Vector2i]:
	var _arr : Array[Vector2i] =  []
	game_grid.update_astar_points(combatUnit)
	if combatUnit.ai_type == CombatMapConstants.UNIT_AI_TYPE.DEFEND_POINT:
		var _max_range = 0
		var _ranges = combatUnit.unit.inventory.get_available_attack_ranges()
		if not _ranges.is_empty:
			_max_range = _ranges.max()
		return game_grid.get_range_DFS(_max_range, combatUnit.map_position)
	else :
		# get move tiles
		var _moveable_tiles = game_grid.get_range_DFS(combatUnit.unit.stats.movement, combatUnit.map_position, combatUnit.unit.movement_type, true, combatUnit.allegience)
		# get the edge of the move tiles
		var _edge_array = game_grid.find_edges(_moveable_tiles)
		# return all the tiles that can be reached
		var _attack_tiles = game_grid.get_range_multi_origin_DFS(combatUnit.unit.get_max_attack_range(), _edge_array)
		_arr.append_array(_moveable_tiles)
		_arr.append_array(_attack_tiles)
		return _arr

##
# Used to add or remove a unit from the selected unit list, and range tracking
##
func toggle_selected_unit(combatUnit: CombatUnit) -> bool:
	#add unit
	var _unit_added = false
	if not selected_unit_list.has(combatUnit):
		# add the unit
		selected_unit_list.append(combatUnit)
		_unit_added = true
	else:
	#remove unit
		selected_unit_list.erase(combatUnit)
	# re-populate the return array
	update_selected_unit_range_tiles()
	return _unit_added

##
# Used to add or remove a unit from the selected unit list, and range tracking
##
func remove_selected_unit(combatUnit: CombatUnit):
	if selected_unit_list.has(combatUnit):
		selected_unit_list.erase(combatUnit)
		update_selected_unit_range_tiles()

func get_units_in_range_of_tile(tile: Vector2i):
	if units_in_range_of_tile.has(tile):
		return units_in_range_of_tile[tile].data
	else :
		return null

func update_output_arrays():
	update_enemy_range_tiles()
	update_selected_unit_range_tiles()
	
class TileGroup:
	var data : Array[Vector2i]

	func _init(new_data: Array[Vector2i]) -> void:
		data = new_data

class UnitGroup:
	var data : Array[CombatUnit]

	func _init(new_data: Array[CombatUnit]) -> void:
		data = new_data
