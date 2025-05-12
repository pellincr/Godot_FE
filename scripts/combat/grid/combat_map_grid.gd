extends Node
class_name CombatMapGrid
##
# This script stores all the map related methods for the combat scene
##

##SIGNALS
signal tile_info_updated(tile : Dictionary)

##EXPORTS
@export var combat: Combat 

var terrain_tile_map : TileMap ##UPDATE THIS TO TILEMAPLAYER
var entity_data: MapEntityGroupData
var unit_data: Array[CombatUnit]

const tiles_to_check = [
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.LEFT,
	Vector2i.DOWN
]

const tile_nieghbor_index = [
	0, ##CELL_NEIGHBOR_RIGHT_SIDE
	4, ##CELL_NEIGHBOR_BOTTOM_SIDE
	8, ##CELL_NEIGHBOR_LEFT_SIDE
	12 ##CELL_NEIGHBOR_TOP_SIDE
]

var _astargrid = AStarGrid2D.new()
var _path : PackedVector2Array

## dictionary that stores the tile data
var game_map = {} # <Vector2i, mapTile>
var unit_map = {} # <combat_unit.uid, Vector2i>
var entity_map = {} # <MapEntity.uid, Vector2i>

var current_tile_position: Vector2i

func _ready():
	terrain_tile_map = get_node("../Terrain/TileMap")
	initialize_grid(terrain_tile_map) 
	populate_game_map_terrain(terrain_tile_map)
	populate_game_map_units(unit_data)
	populate_game_map_entities(entity_data)


func populate_game_map_terrain(tile_map: TileMap):
	for tile in tile_map.get_used_cells(0):
		populate_tile_information_at_tile(tile)
		
func populate_game_map_units(unit_data: Array[CombatUnit]):
	for unit in unit_data:
		if game_map.has(str(unit.map_position)):
			set_combat_unit(unit, unit.map_position)

func populate_game_map_entities(entity_data : MapEntityGroupData):
	for entity : CombatMapEntity in entity_data.entities:
		if game_map.has(str(entity.position)):
			set_entity_at_position(entity, entity.position)

func populate_tile_information_at_tile(tile: Vector2i):
	var _mapTile = MapTile.new()
	_mapTile.position = tile
	if get_terrain_from_tile_map(tile):
		_mapTile.terrain = get_terrain_from_tile_map(tile)
		_mapTile.terrain_bonuses = get_terrain_from_tile_map(tile).stat_bonuses
		_mapTile.blocks_unit_movement = get_terrain_from_tile_map(tile).stat_bonuses
	game_map[str(tile)] = _mapTile

func initialize_grid(tile_map:TileMap):
	#configure _astargrid
	_astargrid.region = tile_map.get_used_rect()
	_astargrid.cell_size = Vector2i(32, 32)
	_astargrid.offset = Vector2(16, 16)
	_astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astargrid.update()


func get_combat_unit_at_position(position: Vector2i) -> CombatUnit:
	if game_map.has(str(position)):
		var entry: MapTile = game_map.get(str(position))
		if entry.unit and entry.unit.alive:
			return entry.unit
	return null

func get_entity_at_position(target_position:Vector2i, tile_map:TileMap = terrain_tile_map)-> CombatMapEntity:
	var tile = tile_map.local_to_map(target_position) ##is this just wrong?
	if _astargrid.is_in_boundsv(tile):
		return get_entity_at_map_position(tile)
	return null

func get_entity_at_map_position(position:Vector2i)-> CombatMapEntity:
	if game_map.has(str(position)):
		var entry: MapTile = game_map.get(str(position))
		if entry.entity:
			return entry.entity
	return null

func combat_unit_moved(previous_map_positon : Vector2i, new_map_position: Vector2i):
	if game_map.has(str(previous_map_positon)) and game_map.has(str(new_map_position)):
		var previous_map_tile :MapTile= game_map.get(str(previous_map_positon))
		var new_map_tile :MapTile= game_map.get(str(previous_map_positon))
		if previous_map_tile.unit and !new_map_tile.unit :
			new_map_tile.unit = previous_map_tile.unit
			previous_map_tile.unit = null

func set_combat_unit(combatUnit: CombatUnit, position:Vector2i):
	if game_map.has(str(position)):
		var mapTile : MapTile= game_map.get(str(position))
		if !mapTile.unit:
			mapTile.unit = combatUnit
		else:
			print("Error Adding unit in combat map grid, target position already occupied")
	else :
		print("Error Adding unit in combat map grid, target position does not exist in game map")

func is_position_occupied(position:Vector2i) -> bool:
	if get_combat_unit_at_position(position):
		return true
	return false

func is_position_occupied_by_friendly_faction(position:Vector2i, faction:int) -> bool:
	if get_combat_unit_at_position(position):
		var combat_unit = get_combat_unit_at_position(position)
		if combat_unit.allegience == faction:
			return true
	return false

func update_astar_points():
	for key : String in game_map.keys:
		var entry : MapTile = game_map[key]
		var tile = CustomUtilityLibrary.vector2i(key)
		if _astargrid.is_in_boundsv(tile):
			_astargrid.set_point_solid(tile, false)
			_astargrid.set_point_weight_scale(tile, get_tile_cost_at_map_position(tile))
		if is_position_occupied_by_friendly_faction(tile, combat.get_current_combatant().allegience):
			pass
		else:
			_astargrid.set_point_solid(tile)
	## Update for movement classess
		if entry.blocks_unit_movement:
			if combat.get_current_combatant().unit.movement_class in entry.blocks_unit_movement:
				_astargrid.set_point_solid(tile)
		if entry.entity and entry.entity.active:
			if entry.entity.terrain:
				if combat.get_current_combatant().unit.movement_class in entry.entity.terrain.blocks:
					_astargrid.set_point_solid(tile)

##REVIEW THIS METHOD IT SEEMS OUTDATED? 
func find_path(tile_position: Vector2i, current_position : Vector2i = Vector2i(0,0)) -> PackedVector2Array:
	var _path : PackedVector2Array
	if(_astargrid.is_in_boundsv(tile_position)):
		##if we run into a wall, be sure to check all directions
		if _astargrid.get_point_weight_scale(tile_position) > 999999: 
			var dir : Vector2i
			if current_position.x > tile_position.x:
				dir = Vector2i.RIGHT
			if current_position.y > tile_position.y:
				dir = Vector2i.DOWN
			if tile_position.x > current_position.x:
				dir = Vector2i.LEFT
			if tile_position.y > current_position.y:
				dir = Vector2i.UP
			tile_position += dir
		_path = _astargrid.get_point_path(current_position, tile_position, true)
	return _path

func get_tile_cost_at_map_position(tile:Vector2i, unit:CombatUnit = null):
	if game_map.has(str(tile)):
		var mapTile : MapTile = game_map.get(str(tile))
		if mapTile.terrain:
			if unit:
				return int (mapTile.terrain.cost[unit.unit.movement_class])
			else: 
				return int (mapTile.terrain.cost[combat.get_current_combatant().unit.movement_class])
	else : 
		print("get_tile_cost called with out of bounds tile")
	return INF

func get_tile_cost_at_point(point, unit:CombatUnit = null):
	var tile = terrain_tile_map.local_to_map(point)
	if _astargrid.is_in_boundsv(tile):
		return get_tile_cost_at_map_position(tile, unit)
	else: 
		return INF

##Use DFS to retrieve the available cells from an origin point
func get_edge_tiles(tiles :PackedVector2Array) -> PackedVector2Array:
	var _return_array : PackedVector2Array
	var tile_edge_dictionary : Dictionary
	for tile in tiles:
		tile_edge_dictionary.get_or_add(Vector2i(tile), false)
	for tile in tiles: 
		for neighbors in tile_nieghbor_index :
			if tile_edge_dictionary.has(Vector2i(tile + neighbors)):
				pass
			else:
				tile_edge_dictionary[tile] = true
				_return_array.append(tile)
	return _return_array

func get_range_multi_origin_DFS(range:int, tiles: Array[Vector2i], movement_type:int = 0, effected_by_terrain:bool = false):
	var visited : Dictionary #Dictionary with <k,v> = <Vector2 tile posn, Vector2i(highest_move_at_tile, distance)>
	const DEFAULT_TILE_COST = 1
	var remaining_range
		#add our first tile into the front of the visited array
	visited.get_or_add(tiles[0], range)
	#if the player has movement otherwise this is meaningless
	if range > 0:
		for tile in tiles: 
		#recursively call on the tiles around until range is empty
			for neighbors in tile_nieghbor_index :
				#get the correct tile in the direction
				var target_tile = terrain_tile_map.get_neighbor_cell(tile, neighbors)
				if _astargrid.is_in_boundsv(target_tile):
					if(effected_by_terrain) :
						#should we even be considering this tile?
						if not (is_position_occupied_by_friendly_faction(target_tile,combat.get_current_combatant().allegience)):
							var target_tile_cost = get_tile_cost_at_map_position(target_tile)
							remaining_range = range - target_tile_cost 
							if remaining_range >= 0  and not is_unit_blocked(target_tile, movement_type):
								#check if visited has the tile
								if visited.has(target_tile):
									#Is there already a better value in the map?
									if visited.get(target_tile) > remaining_range:
										# this is a dead end.. We have already reached this tile with a superior range
										pass
									else: 
										visited[target_tile] = remaining_range
										DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
								else: 
									visited.get_or_add(target_tile, remaining_range)
									DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
					else : 
						remaining_range = range - DEFAULT_TILE_COST 
						if (remaining_range >= 0) :
							visited.get_or_add(target_tile, remaining_range)
							DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
	return visited.keys()

##Use DFS to retrieve the available cells from an origin point
func get_range_DFS(range:int, origin: Vector2i, movement_type:int = 0, effected_by_terrain:bool = false) -> PackedVector2Array:
	var visited : Dictionary #Dictionary with <k,v> = <Vector2 tile posn, Vector2i(highest_move_at_tile, distance)>
	const DEFAULT_TILE_COST = 1
	var remaining_range
	#add our first tile into the front of the visited array
	visited.get_or_add(origin, range)
	#if the player has movement otherwise this is meaningless
	if range > 0:
		#recursively call on the tiles around until range is empty
		for neighbors in tile_nieghbor_index :
			#get the correct tile in the direction
			var target_tile = terrain_tile_map.get_neighbor_cell(origin, neighbors)
			if _astargrid.is_in_boundsv(target_tile):
				if(effected_by_terrain) :
					#should we even be considering this tile?
					if not is_position_occupied_by_friendly_faction(target_tile,combat.get_current_combatant().allegience):
						var target_tile_cost = get_tile_cost_at_map_position(target_tile)
						remaining_range = range - target_tile_cost 
						if remaining_range >= 0  and not is_unit_blocked(target_tile, movement_type):
							#check if visited has the tile
							if visited.has(target_tile):
								#Is there already a better value in the map?
								if visited.get(target_tile) > remaining_range:
									# this is a dead end.. We have already reached this tile with a superior range
									pass
								else: 
									visited[target_tile] = remaining_range
									DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
							else: 
								visited.get_or_add(target_tile, remaining_range)
								DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
				else : 
					remaining_range = range - DEFAULT_TILE_COST 
					if (remaining_range >= 0) :
						visited.get_or_add(target_tile, remaining_range)
						DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
	return visited.keys()

##Use DFS to retrieve the available cells from an origin point
func get_map_of_range_DFS(range:int, origin: Vector2i, movement_type:int = 0, effected_by_terrain:bool = false) -> Dictionary:
	var visited : Dictionary #Dictionary with <k,v> = <Vector2 tile posn, highest_move_at_tile>
	const DEFAULT_TILE_COST = 1
	var remaining_range
	#add our first tile into the front of the visited array
	visited.get_or_add(origin, range)
	#if the player has movement otherwise this is meaningless
	if range > 0:
		#recursively call on the tiles around until range is empty
		for neighbors in tile_nieghbor_index :
			#get the correct tile in the direction
			var target_tile = terrain_tile_map.get_neighbor_cell(origin, neighbors)
			if _astargrid.is_in_boundsv(target_tile):
				if(effected_by_terrain) :
					#should we even be considering this tile?
					if not is_position_occupied_by_friendly_faction(target_tile,combat.get_current_combatant().allegience):
						var target_tile_cost = get_tile_cost_at_map_position(target_tile)
						remaining_range = range - target_tile_cost 
						if remaining_range >= 0  and not is_unit_blocked(target_tile, movement_type):
							#check if visited has the tile
							if visited.has(target_tile):
								#Is there already a better value in the map?
								if visited.get(target_tile) > remaining_range:
									# this is a dead end.. We have already reached this tile with a superior range
									pass
								else: 
									visited.erase(target_tile)
									visited.get_or_add(target_tile, remaining_range)
									DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
							else: 
								visited.get_or_add(target_tile, remaining_range)
								DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
				else : 
					remaining_range = range - DEFAULT_TILE_COST 
					if (remaining_range >= 0) :
						visited.get_or_add(target_tile, remaining_range)
						DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
	return visited

## Used in retreieveAvailableRange
func DFS_recursion(range:int, origin: Vector2i, movement_type:int, effected_by_terrain:bool, visited:Dictionary) -> Dictionary:
	var DEFAULT_TILE_COST = 1
	var remaining_range
	if range > 0:
		for neighbors in tile_nieghbor_index :
				#get the correct tile in the direction
				var target_tile = terrain_tile_map.get_neighbor_cell(origin, neighbors)
				if _astargrid.is_in_boundsv(target_tile):
					if(effected_by_terrain) :
						#should we even be considering this tile?
						if not is_position_occupied_by_friendly_faction(target_tile,combat.get_current_combatant().allegience):
							var target_tile_cost = get_tile_cost_at_map_position(target_tile)
							remaining_range = range - target_tile_cost 
							if remaining_range >= 0  and not is_unit_blocked(target_tile, movement_type):
								#check if visited has the tile
								if visited.has(target_tile):
									#Is there already a better value in the map?
									if visited.get(target_tile) >= remaining_range:
										# this is a dead end.. We have already reached this tile with a superior range
										pass
									else: 
										visited.erase(target_tile)
										visited.get_or_add(target_tile, remaining_range)
										DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
								else: 
									visited.get_or_add(target_tile, remaining_range)
									DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
					else : 
						remaining_range = range - DEFAULT_TILE_COST 
						if (remaining_range >= 0) :
							visited.get_or_add(target_tile, remaining_range)
							DFS_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
	return visited

#Finds the edges of a list of tiles
# tiles : an array of vector2 tile coords
func find_edges(tiles:PackedVector2Array) -> PackedVector2Array:
	var edge_tiles :PackedVector2Array
	for tile in tiles :
		#check all tile neighbors
		if(!tiles.has(tile + Vector2.RIGHT)) :
			edge_tiles.append(tile)
		elif(!tiles.has(tile + Vector2.UP)) : 
			edge_tiles.append(tile)
		elif(!tiles.has(tile + Vector2.DOWN)) : 
			edge_tiles.append(tile)
		elif(!tiles.has(tile + Vector2.LEFT)) : 
			edge_tiles.append(tile)
		else : 
			continue
	return edge_tiles

func get_terrain_at_position(position: Vector2) ->  Terrain:
	var tile = terrain_tile_map.local_to_map(position)
	return get_terrain_at_map_position(tile)

func get_terrain_at_map_position(position: Vector2i) ->  Terrain:
	if game_map.has(str(position)):
		return game_map[str(position)].terrain
	else : 
		if get_terrain_from_tile_map(position):
			populate_tile_information_at_tile(position)
			return game_map[str(position)].terrain
		else : 
			return null

func get_effective_terrain(mapTile : MapTile) -> Terrain:
	if mapTile.entity:
		if mapTile.entity.active:
			if mapTile.entity.terrain:
				return mapTile.entity.terrain
	if mapTile.terrain:
		return mapTile.terrain
	return null

func set_entity_at_position(cme :CombatMapEntity, position: Vector2i):
	if game_map.has(str(position)):
		var mapTile:MapTile = game_map.get(str(position))
		mapTile.entity = cme
		game_map[str(position)] = mapTile

func get_terrain_from_tile_map(position:Vector2) -> Terrain:
	if _astargrid.is_in_boundsv(position):
		var tile_data = terrain_tile_map.get_cell_tile_data(0, position)
		if tile_data :
			if tile_data.get_custom_data("Terrain") is Terrain:
				return tile_data.get_custom_data("Terrain")
		print("Error Failed to get terrain from tile map, terrain data is null")
	else :
		print("get_terrain_at_map_position called on out of bounds tile")
	return null

func get_tiles_at_range_new(range:int, origin: Vector2i) -> PackedVector2Array:
	var _tiles_at_range : PackedVector2Array
	var dict = get_map_of_range_DFS(range, origin)
	var _keys = dict.keys()
	var _vals = dict.values()
	for index in range(_keys.size()):
		if _vals[index] == 0: #where the range is fully used up
			_tiles_at_range.append(_keys[index])
	return _tiles_at_range

func get_tiles_at_range(range:int, origin: Vector2i, visited:PackedVector2Array = [] , edge:PackedVector2Array= []) -> Array[PackedVector2Array]:
	var return_object :Array[PackedVector2Array] = [
		visited,
		edge
	]
	var remaining_range
	if range > 0:
		for neighbors in tile_nieghbor_index :
			var target_tile = terrain_tile_map.get_neighbor_cell(origin, neighbors)
			remaining_range = range - 1 
			if (remaining_range > 0) :
				if(edge.has(target_tile)):
					edge.remove_at(edge.find(target_tile))
				if(!visited.has(target_tile)) : 
					visited.append(target_tile)
				get_tiles_at_range(remaining_range, target_tile, visited, edge)
			else : #this is the "edge" the last block 
				#has this block already been visited?
				if(!visited.has(target_tile)):
					edge.append(target_tile)
	return return_object

func grid_get_target_tile_neighbors(tile_position: Vector2i):
	var tile_array: PackedVector2Array
	for tile in tiles_to_check:
		tile_array.append(tile_position + tile)
	return tile_array

func astar_path_distance(path: PackedVector2Array) -> int:
	var distance : int = 0
	for cell in path:
		distance = distance + _astargrid.get_point_weight_scale(cell)
	return distance

func get_map_tile_at_position(position: Vector2)-> MapTile:
	var tile = terrain_tile_map.local_to_map(position)
	return get_map_tile_at_map_position(tile)

func get_map_tile_at_map_position(position: Vector2i) -> MapTile:
	if game_map.has(str(position)):
		return game_map[str(position)]
	return null

func is_unit_blocked(position: Vector2i, unit_movement_class:int):
	if get_map_tile_at_map_position(position):
		if get_effective_terrain(get_map_tile_at_map_position(position)):
			var _terrain : Terrain = get_effective_terrain(get_map_tile_at_map_position(position))
			if unit_movement_class not in _terrain.blocks:
				return false
	return true
