##
# Combat Controller Class
# manages all the components used in the combat map
#
##
extends Node2D
class_name CController

##CONST
#Grid
const GRID_TEXTURE = preload("res://resources/sprites/grid/grid_marker_2.png")
const PATH_TEXTURE = preload("res://resources/sprites/grid/path_ellipse.png")

#Actions
const ATTACK_ACTION : UnitAction = preload("res://resources/definitions/actions/unit_action_attack.tres")
const WAIT_ACTION : UnitAction = preload("res://resources/definitions/actions/unit_action_wait.tres")
const TRADE_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_trade.tres")
const ITEM_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_inventory.tres")
const USE_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_use_item.tres")
const SUPPORT_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_support.tres")
const SHOVE_ACTION: UnitAction = preload("res://resources/definitions/actions/unit_action_shove.tres")
const CHEST_ACTION: UnitAction = preload("res://resources/definitions/actions/unit_action_chest.tres")

#Movement
const MOVEMENT_SPEED = 96

##SIGNALS
signal movement_changed(movement: int)
signal finished_move(position: Vector2i)
signal target_selection_started()
signal target_selection_finished()
signal tile_info_updated(tile : CombatMapTile)
signal target_detailed_info(combat_unit : CombatUnit)

##State Machine
#@export var seed : int
var turn_count : int
var turn_order : Array[CombatMapConstants.FACTION] = [CombatMapConstants.FACTION.PLAYERS, CombatMapConstants.FACTION.ENEMIES] #Default for a two factioned map
var turn_order_index : int = 0
var turn_owner : CombatMapConstants.FACTION =  CombatMapConstants.FACTION.NULL
var player_factions :  Array[CombatMapConstants.FACTION] = [CombatMapConstants.FACTION.PLAYERS]

var game_state: CombatMapConstants.COMBAT_MAP_STATE #= CombatMapConstants.COMBAT_MAP_STATE.INITIALIZING
var turn_phase: CombatMapConstants.TURN_PHASE #= CombatMapConstants.TURN_PHASE.INITIALIZING
var previous_turn_phase: CombatMapConstants.TURN_PHASE #= CombatMapConstants.TURN_PHASE.INITIALIZING
var previous_player_state : CombatMapConstants.PLAYER_STATE
var player_state: CombatMapConstants.PLAYER_STATE #= CombatMapConstants.PLAYER_STATE.INITIALIZING

##Controller Main Variables
@export var controlled_node : Control
@export var combat: Combat 
var grid: CombatMapGrid
var camera: CombatMapCamera

var current_tile : Vector2i #Where the cursor currently is
var selected_tile : Vector2i #What we first selected
var target_tile : Vector2i #Our First Target
var move_target_tile : Vector2i

## Selector/Cursor
@export var selector : AnimatedSprite2D
@export var selector_target : AnimatedSprite2D
@export var selector_support : AnimatedSprite2D

##Player Interaction Variables
var unit_detail_open = false #TO BE UPDATED TO unit_detial_overlay
var option_menu : bool = false
var unit_detail_overlay : bool = false
#var map_focused : bool = true This may be redundant

#Movement Variables
var _arrived = true
var _path : PackedVector2Array #to be converted to Array[Vector2i]
var default_move_speed = MOVEMENT_SPEED * 5
var return_move_speed = MOVEMENT_SPEED * 5
var move_speed = default_move_speed
var _previous_position : Vector2i
var _next_position
var _position_id = 0

#Action Select
var _available_actions : Array[UnitAction]
var _action: UnitAction
var _action_selected: bool # Is this redundant?

#Action Variables
var _action_target_unit : CombatUnit
var _action_target_unit_selected : bool = false # is this redundant? 
var _unit_action_completed : bool = false
var _unit_action_initiated : bool = false
var _action_tiles : Array[Vector2i]
var _action_valid_targets : Array[CombatUnit]
var _action_ranges : Array[int] = []

#Item Selection Variables
var _selected_item: ItemDefinition
var _selected_entity: CombatMapEntity
var _item_selected: bool

#AI Variables
var _in_ai_process: bool = false
var _enemy_units_turn_taken: bool = false

#Drawing Variables
var move_range : Array[Vector2i]
var attack_range : Array[Vector2i]
#var skill_range : PackedVector2Array 

func _ready():
	##Load Seed to ensure consistent runs
	#seed(seed)
	##Configure FSM States
	turn_count = 1
	game_state = CombatMapConstants.COMBAT_MAP_STATE.INITIALIZING
	turn_phase = CombatMapConstants.TURN_PHASE.INITIALIZING
	previous_turn_phase = CombatMapConstants.TURN_PHASE.INITIALIZING
	previous_player_state = CombatMapConstants.PLAYER_STATE.INITIALIZING
	player_state = CombatMapConstants.PLAYER_STATE.INITIALIZING
	##create variables needed for Combat Map
	grid = CombatMapGrid.new()
	camera = CombatMapCamera.new()
	##Assign created variables to create place in the scene tree
	await combat.ready
	await camera.ready
	self.add_child(grid)
	self.add_child(camera)
	#Auto Wire combat signals for modularity
	combat.connect("perform_shove", perform_shove)
	combat.connect("combatant_added", combatant_added)
	combat.connect("combatant_died", combatant_died)
	combat.connect("major_action_completed", _on_visual_combat_major_action_completed)
	combat.connect("minor_action_completed", _on_visual_combat_minor_action_completed)
	combat.connect("turn_advanced", advance_turn)
	# Init & Populate dynamically created nodes
	await camera.init()
	#await combat.load_entities()
	# Prepare to transition to player turn and handle player input
	autoCursor()
	##Set the correct states to begin FSM flow
	game_state = CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN
	turn_owner = CombatMapConstants.FACTION.PLAYERS
	
#process called on frame
func _process(delta):
	queue_redraw()
	if(turn_phase == CombatMapConstants.TURN_PHASE.INITIALIZING):
		# initializing UI method
		combat.game_ui.hide_end_turn_button()
		update_turn_phase(CombatMapConstants.TURN_PHASE.BEGINNING_PHASE)
	elif(turn_phase == Constants.TURN_PHASE.BEGINNING_PHASE):
		#await ui.play_turn_banner(turn_owner)
		await process_terrain_effects()
		# await process_skill_effects()
		# await clean_up --> remove debuffs / buffs & etc.
		# await spawn reinforcements()
		update_turn_phase(CombatMapConstants.TURN_PHASE.MAIN_PHASE)
		if game_state == (CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN):
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
	elif turn_phase == CombatMapConstants.TURN_PHASE.MAIN_PHASE :
		if game_state == (CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN):
			player_fsm_process(delta)
		elif game_state == CombatMapConstants.COMBAT_MAP_STATE.AI_TURN :
			if _in_ai_process:
				pass
			else : 
				if not _enemy_units_turn_taken:
					ai_turn()
				else :
					print("moved to enemy end phase")
					update_turn_phase(CombatMapConstants.TURN_PHASE.ENDING_PHASE)
			#DO PLAYER ACTION PROCESS HERE, WE GIVE PLAYER CONTROL
	elif(turn_phase == CombatMapConstants.TURN_PHASE.ENDING_PHASE):
		if game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN : 
			pass
		elif game_state == CombatMapConstants.COMBAT_MAP_STATE.AI_TURN :
			print("Enemy Ended Turn")
			_in_ai_process = false
			_enemy_units_turn_taken = false
		# await process_skill_effects()
		# await clean_up()
		# await terrain_effects()
		await trigger_reinforcements()
		progress_turn_order()
		#All players have completed their turns, and order resets
		if turn_order_index == 0:
			turn_count += 1
		update_turn_phase(CombatMapConstants.TURN_PHASE.BEGINNING_PHASE)
	elif game_state == CombatMapConstants.COMBAT_MAP_STATE.PROCESSESING:
		#Move Unit Code
		if _arrived == false:
			process_unit_move(delta)

#draw the area
func _draw():
	if(game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN):
		if(player_state == CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT):
			if(combat.get_current_combatant()):
				draw_comb_range(combat.get_current_combatant())
				draw_ranges(move_range, true, attack_range,true)
				drawSelectedpath()
		#if(player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT):
			#draw_action_tiles(_action_tiles, _action)

func process_unit_move(delta):
		if (delta * move_speed) > controlled_node.position.distance_to(_next_position):
				controlled_node.position = _next_position
		else :
			controlled_node.position += controlled_node.position.direction_to(_next_position) * delta * move_speed
		#Update move, on entering new tile
		if controlled_node.position.distance_to(_next_position) < 1:
			var tile_cost = grid.get_tile_cost_at_point(_previous_position)
			controlled_node.position = _next_position
			var new_position: Vector2i = grid.position_to_map(_next_position)
			grid.combat_unit_moved(_previous_position, new_position)
			_previous_position = new_position
			var next_tile_cost = grid.get_tile_cost_at_point(new_position)
			#movement -= tile_cost
			#Can the unit move to the next tile in the path  ** THIS DOESNT MATTER B/C MATH HAPPENING IN DFS?
			if (_position_id < _path.size() - 1):
				_position_id += 1
				_next_position = _path[_position_id]
			else:
				update_turn_phase(previous_turn_phase)
				_arrived = true
				finished_move.emit(new_position) #EMIT THIS LAST
				if game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN:
					if(player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT) :
						#Move complete on action select (cancelled move)
						#remove old space from occupied spaces
						##_astargrid.set_point_weight_scale(combat.get_current_combatant().move_tile.position, 1) ##REMOVED ALSO SEEMS REDUNDANT VERIFY
						#movement = combat.get_current_combatant().unit.movement
						update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT)
					elif(player_state == CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT):
						combat.get_current_combatant().move_position = new_position
						combat.get_current_combatant().move_terrain = grid.get_terrain(new_position)
						combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
						update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT)
					else: ## THIS WILL NEED TO BE UPDATED WITH ALL POSSIBLE PLACES THE ACTION FLOWS CAN COME FROM
						combat.get_current_combatant().move_position = new_position
						combat.get_current_combatant().move_terrain = grid.get_terrain(new_position)

#advance_the game turn
#connect to UI end turn
func advance_turn():
	update_turn_phase(CombatMapConstants.TURN_PHASE.ENDING_PHASE)
	combat.advance_turn(Constants.FACTION.PLAYERS)

func progress_turn_order():
	turn_order_index = CustomUtilityLibrary.array_next_index_with_loop(turn_order, turn_order_index)
	turn_owner = turn_order[turn_order_index]
	combat.advance_turn(turn_owner)
	if turn_owner in player_factions:
		game_state = CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN
	else : 
		game_state = CombatMapConstants.COMBAT_MAP_STATE.AI_TURN 

func get_entity_at_tile(tile:Vector2i)-> CombatMapEntity:
	for ent in combat.entities:
		if ent.position == tile and ent.active:
			return ent
	return null

func combatant_added(combatant):
	pass
	
func entity_added(cme: CombatMapEntity):
	pass

func combatant_died(combatant):
	if combatant.map_display:
		combatant.map_display.queue_free()

func entity_disabled(e :CombatMapEntity):
	if e.display:
		e.display.queue_free()

func find_path(tile_position: Vector2i):
	_path.clear()
	var current_position = grid.position_to_map(controlled_node.position)
	_path = grid.find_path(current_tile, tile_position)
	queue_redraw()

func move_player():
	move_speed = default_move_speed
	var current_position = grid.local_to_map(controlled_node.position)
	var _path_size = _path.size()
	if _path_size > 1: # and movement > 0:
		await move_on_path(current_position)

func return_player():
	move_speed = return_move_speed
	var original_position = combat.get_current_combatant().map_position
	var _path_size = _path.size()
	#movement = 99
	if _path_size >= 1:
		await move_on_path(original_position)

#
# Moves unit on specified path
#
func move_on_path(current_position):
	_previous_position = current_position
	_position_id = 1
	# Is there another space to move on the path
	if _path.size() > _position_id :
		_next_position = _path[_position_id]
	_arrived = false
	queue_redraw()

##Draw the path between the selected Combatant and the mouse cursor
func drawSelectedpath():
	if _arrived == true :
		var path_length = combat.get_current_combatant().unit.stats.movement
		#Get the length of the path
		for i in range(_path.size()):
			var point = _path[i]
			var draw_color = Color.TRANSPARENT
			if grid.is_unit_blocked(point, combat.get_current_combatant().unit.movement_class):
				draw_color = Color.DIM_GRAY
				if path_length - grid.get_tile_cost_at_position(point, combat.get_current_combatant()) >= 0:
					draw_color = Color.WHITE
				if i > 0:
					path_length -= grid.get_tile_cost_at_position(point, combat.get_current_combatant())
			else : 
				break
			draw_texture(PATH_TEXTURE, point - Vector2(16, 16), draw_color)

#Draws a units move and attack ranges
func draw_ranges(move_range:PackedVector2Array, draw_move_range:bool, attack_range:PackedVector2Array, draw_attack_range:bool, skill_range:PackedVector2Array = [], draw_skill_range:bool = false):
	var move_range_color = Color.BLUE
	var attack_range_color = Color.CRIMSON
	var skill_range_color = Color.GOLD
	if (draw_move_range) :
		for tile in move_range :
			draw_texture(GRID_TEXTURE, tile  * Vector2(32, 32), move_range_color)
	if (draw_attack_range) :
		for tile in attack_range :
			if(!move_range.has(tile)) : 
				draw_texture(GRID_TEXTURE, tile  * Vector2(32, 32), attack_range_color)
	if (draw_skill_range) :
		for tile in skill_range :
			if(!attack_range.has(tile) and !move_range.has(tile)) : 
				draw_texture(GRID_TEXTURE, tile  * Vector2(32, 32), skill_range_color)

func draw_attack_range(attack_range:PackedVector2Array):
	for tile in attack_range : 
			draw_texture(GRID_TEXTURE, tile  * Vector2(32, 32), Color.CRIMSON)

func draw_action_tiles(tiles:PackedVector2Array, ua:UnitAction):
	##Set the tile color based on the type of action
	var tile_color : Color = Color.CRIMSON
	if _action:
		if _action == SUPPORT_ACTION: 
			tile_color = Color.SEA_GREEN
		if _action == TRADE_ACTION:
			tile_color = Color.BLUE_VIOLET
		if _action == SHOVE_ACTION:
			tile_color = Color.ORANGE
	for tile in tiles : 
		draw_texture(GRID_TEXTURE, tile  * Vector2(32, 32), tile_color)

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

func get_tile_info(position : Vector2i): 
	tile_info_updated.emit(grid.get_map_tile(position))

func draw_comb_range(combatant: CombatUnit) :
	attack_range.clear()
	move_range = grid.get_range_DFS(combatant.unit.stats.movement, combatant.map_tile.position, combatant.unit.movement_type, true)
	var edge_array = find_edges(move_range)
	attack_range = grid.get_range_multi_origin_DFS(combatant.unit.inventory.get_max_attack_range(), edge_array)

func get_potential_targets(cu : CombatUnit, range: Array[int] = []) -> Array[CombatUnit]:
	var range_list :Array[int] = []
	if range.is_empty():
		range_list = cu.unit.inventory.get_available_attack_ranges()
	else:
		range_list = range.duplicate()
	var attackable_tiles : PackedVector2Array
	var response : Array[CombatUnit]
	if range_list.is_empty() : ##There is no attack range
		return response
	attackable_tiles = get_attackable_tiles(range_list, cu)
	_action_tiles = attackable_tiles.duplicate()
	for tile in attackable_tiles :
		if grid.get_combatant_at_position(tile) :
			if(grid.get_combatant_at_position(tile).allegience != cu.allegience) :
				response.append(grid.get_combatant_at_position(tile))
	return response

func get_potential_support_targets(cu : CombatUnit, range: Array[int] = []) -> Array[CombatUnit]:
	var range_list :Array[int] = []
	if range.is_empty():
		range_list = cu.unit.inventory.get_available_support_ranges()
	else:
		range_list = range.duplicate()
	var attackable_tiles : PackedVector2Array
	var response : Array[CombatUnit]
	if range_list.is_empty() : ##There is no range
		return response
	attackable_tiles = get_attackable_tiles(range_list, cu)
	print(str(attackable_tiles))
	_action_tiles = attackable_tiles.duplicate()
	for tile in attackable_tiles :
		if grid.get_combatant_at_position(tile) :
			if(grid.get_combatant_at_position(tile).allegience == cu.allegience and grid.get_combatant_at_position(tile) != cu) :
				response.append(grid.get_combatant_at_position(tile))
	return response
	
func get_potential_shove_targets(cu: CombatUnit) -> Array[CombatUnit]:
	var pushable_targets : Array[CombatUnit]
	for tile in grid.get_target_tile_neighbors(cu.move_tile.position):
		if grid.get_combatant_at_position(tile) :
			var pushable_unit = grid.get_combatant_at_position(tile)
			var push_vector : Vector2i  = Vector2i(tile) - Vector2i(cu.move_tile.position)
			var target_tile : Vector2i = Vector2i(tile) + push_vector;
			if grid.is_map_position_available_for_unit_move(target_tile, pushable_unit.unit.movemement_type):
				if grid.get_tile_cost(target_tile, pushable_unit) < 99999:
					pushable_targets.append(pushable_unit)
	return pushable_targets

#func get_potential_door_targets(position: Vector2i)-> Array[CombatMapEntity]:
	#var door_targets : Array[CombatMapEntity]
	#for tile in grid_get_target_tile_neighbors(position):
		#if get_entity_at_position(tile) :
			#var _entity = get_entity_at_position(tile)
			#if _entity is CombatMapChestEntity:
				#door_targets.append(_entity)
	#return door_targets

func get_viable_chest_items(cu: CombatUnit) -> Array[ItemDefinition]:
	var _items : Array[ItemDefinition]
	if grid.get_entity_at_position(cu.move_position) :
		var _entity = grid.get_entity_at_position(cu.move_position)
		if _entity is CombatMapChestEntity:
			for item : ItemDefinition in _entity.required_item:
				if cu.unit.inventory.has(item):
					_items.append(item)
					#TO BE IMPLEMENTED if unit can use item
	return _items

func chest_action_available(cu:CombatUnit)-> bool:
	if  grid.get_entity_at_tile(cu.move_tile.position) :
		var _entity = grid.get_entity_at_tile(cu.move_tile.position)
		if _entity is CombatMapChestEntity:
			if _entity.required_item.is_empty():
				return true
			else:
				for item : ItemDefinition in _entity.required_item:
					print(item.name)
					if cu.unit.inventory.has(item):
						#TO BE IMPLEMENTED if unit can use item
						return true
	return false

func get_attackable_tiles(range_list: Array[int], cu: CombatUnit):
	var attackable_tiles : PackedVector2Array
	for range in range_list:
		if cu.move_tile.position :
			attackable_tiles.append_array(grid.get_tiles_at_range_new(range, cu.move_tile.position))
	return attackable_tiles

func process_terrain_effects():
	for combat_unit in combat.combatants:
		if combat not in combat.dead_units:
			if (combat_unit.allegience == Constants.FACTION.PLAYERS and game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN) or (combat_unit.allegience == Constants.FACTION.ENEMIES and game_state == CombatMapConstants.COMBAT_MAP_STATE.AI_TURN):
				if grid.get_terrain_at_map_position(combat_unit.map_tile.position): 
					var target_terrain = grid.get_terrain_at_map_position(combat_unit.map_tile.position)
					if target_terrain.active_effect_phases == CombatMapConstants.TURN_PHASE.keys()[turn_phase]:
						if target_terrain.effect != Terrain.TERRAIN_EFFECTS.NONE:
							if target_terrain.effect == Terrain.TERRAIN_EFFECTS.HEAL:
								if combat_unit.unit.hp < combat_unit.unit.stats.hp:
									print("HEALED UNIT : " + combat_unit.unit.name)
									combat.combatExchange.heal_unit(combat_unit, target_terrain.effect_weight)

func get_available_unit_actions(cu:CombatUnit) -> Array[UnitAction]:
	var action_array : Array[UnitAction] = []
	if cu.minor_action_taken == false:
		if not get_potential_support_targets(cu, [1]).is_empty():
			action_array.push_front(TRADE_ACTION)
	if not cu.unit.inventory.is_empty():
		action_array.append(ITEM_ACTION)
	if cu.major_action_taken == false:
		if not get_potential_shove_targets(cu).is_empty():
			action_array.push_front(SHOVE_ACTION)
		if chest_action_available(cu):
			action_array.push_front(CHEST_ACTION)
		if not get_potential_support_targets(cu).is_empty():
			action_array.push_front(SUPPORT_ACTION)
		if not get_potential_targets(cu).is_empty():
			action_array.push_front(ATTACK_ACTION)
	action_array.append(WAIT_ACTION)
	return action_array

func _on_visual_combat_major_action_completed() -> void:
	_unit_action_completed = true
	_action_selected = false
	_action = null
	_selected_item = null
	_item_selected = false

func _on_visual_combat_minor_action_completed() -> void:
	_unit_action_completed = true
	_unit_action_initiated = false
	_action_selected = false
	_action = null
	_selected_item = null
	_item_selected = false
	set_controlled_combatant(combat.get_current_combatant())
	combat.game_ui.hide_end_turn_button()
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT)

# AI Methods
func ai_process_new(ai_unit: CombatUnit) -> aiAction:
	print("Entered ai_process in cController.gd")
	#find nearest non-solid tile to target_position
	#Get Attack Range to see what are "attackable tiles"	
	grid.update_points_weight() #Is this redundant? 
	var current_position = grid.local_to_map(controlled_node.position)
	var moveable_tiles : Array[Vector2i]
	var actionable_tiles :Array[Vector2i]
	var actionable_range : Array[int]= ai_unit.unit.get_attackable_ranges()
	var action_tile_options: Array[Vector2i]
	var selected_action: aiAction
	var called_move : bool = false
	#Step 1 : Get all moveable tiles
	print("@ BEGAN TILE ANALYSIS WITH CURRENT TILE")
	selected_action = ai_get_best_move_at_tile(ai_unit, current_position, actionable_range)
	# Step 2, if the unit can move do analysis on movable tiles
	if ai_unit.ai_type != Constants.UNIT_AI_TYPE.DEFEND_POINT:
		print("@ BEGAN MOVABLE TILE ANALYSIS")
		moveable_tiles = grid.get_range_DFS(ai_unit.unit.stats.movement,current_position, ai_unit.unit.movement_type, true)
		for moveable_tile in moveable_tiles:
			if grid.is_map_position_available_for_unit_move(moveable_tile, ai_unit.unit.movement_type):
				var best_tile_action: aiAction = ai_get_best_move_at_tile(ai_unit, moveable_tile, actionable_range)
				if selected_action == null or selected_action.rating < best_tile_action.rating:
					selected_action = best_tile_action
					print("@ FOUND BETTER ACTION AT TILE : "+ str(moveable_tile) + ". WITH A RATING OF : " + str(selected_action.rating))
	# Step 3, if the unit still doesnt have a good move, and is able have it seek one
	if selected_action != null:
		if ai_unit.ai_type != Constants.UNIT_AI_TYPE.DEFEND_POINT:
			if selected_action.action_type == "NONE": # we found no value moves within move range
				if ai_unit.ai_type != Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE:
					#TO BE IMPLEMENTED : SEARCH FOR HIGH POTENTIAL TILES AND MOVE
					for targetable_unit_index: int in combat.groups[Constants.FACTION.PLAYERS]:
						for range in actionable_range:
							for tile in grid.get_tiles_at_range_new(range,combat.combatants[targetable_unit_index].map_tile.position):
								if not grid.is_position_occupied(tile):
									if tile not in actionable_tiles:
										actionable_tiles.append(tile)
					print("@ FINISHED MOVE AND TARGET SEARCH, NO TARGET FOUND")
					var closet_action_tile
					var _astar_closet_distance = 99999
					var closet_tile_in_range_to_action_tile
					for tile in actionable_tiles:
						if grid.is_valid_tile(tile):
							var _astar_path = grid.get_point_path(current_position,tile)
							if _astar_path:
								var _astar_distance = grid.astar_path_distance(_astar_path)
								if _astar_distance < _astar_closet_distance and _astar_distance != null:
									closet_action_tile = tile
									_astar_closet_distance = _astar_distance
					print("@ FOUND CLOSET ACTIONABLE TILE : [" + str(closet_action_tile) + "]")
					if closet_action_tile != null: 
						if not grid.get_point_weight_scale(closet_action_tile) > 999999:
							if closet_action_tile != Vector2(current_position):
								if closet_action_tile in moveable_tiles:
									ai_move(closet_action_tile)
									called_move = true
								else:
									print("@ MOVEABLE TILES : [" + str(moveable_tiles) + "]")
									var _astar_closet_move_tile_distance_to_action  = 99999
									for moveable_tile in moveable_tiles: 
										if not grid.is_position_occupied(moveable_tile):
											if grid.is_valid_tile(moveable_tile):
												var _astar_path = grid.get_id_path(moveable_tile,closet_action_tile)
												if _astar_path:
													var _astar_distance = grid.astar_path_distance(_astar_path)
													if _astar_distance < _astar_closet_move_tile_distance_to_action and _astar_distance != null:
														closet_tile_in_range_to_action_tile = moveable_tile
														_astar_closet_move_tile_distance_to_action = _astar_distance
														print("@UPDATED CLOSET MOVE TO ACTIONABLE TILE : [" + str(closet_tile_in_range_to_action_tile) + "] with a move distance rating of" + str(_astar_closet_move_tile_distance_to_action))
									print("@ FOUND CLOSET MOVEABLE TILE TO ACTIONABLE TILE : [" + str(closet_tile_in_range_to_action_tile) + "] with a move distance rating of" + str(_astar_closet_move_tile_distance_to_action))
									if closet_tile_in_range_to_action_tile !=  Vector2(current_position):
										ai_move(closet_tile_in_range_to_action_tile)
										called_move = true
			else:
				if called_move == false:
					if Vector2(current_position) != selected_action.action_position:
						ai_move(selected_action.action_position)
						called_move = true
	# Step 4, Perform the move if it is required
	if(called_move):
		print("@ AWAIT AI MOVE FINISH")
		await finished_move
		print("@ COMPLTED WAITING CALLING AI ACTION")
		#update the combat_unit info with the new tile info
	ai_unit.update_map_tile(grid.get_map_tile(grid.position_to_map(controlled_node.position)))
	return selected_action


func ai_get_best_move_at_tile(ai_unit: CombatUnit, tile_position: Vector2i, attack_range: Array[int]) -> aiAction:
	#print("@ ENTERED ai_get_best_move_at_tile")
	#are there targets?
	var tile_best_action: aiAction = aiAction.new()
	tile_best_action.action_type = "NONE"
	tile_best_action.rating = 0
	for range in attack_range:
		for tile in grid.get_tiles_at_range_new(range,tile_position):
			if grid.get_combatant_at_position(tile) != null:
				if grid.get_combatant_at_position(tile).allegience == Constants.FACTION.PLAYERS:
					if not ai_unit.unit.get_usable_weapons_at_range(range).is_empty():
						if grid.get_terrain_at_map_position(tile):
							var best_action_target : aiAction = combat.ai_get_best_attack_action(ai_unit, CustomUtilityLibrary.get_distance(tile, tile_position), grid.get_combatant_at_position(tile), grid.get_terrain_at_map_position(tile))
							best_action_target.target_position = tile
							best_action_target.action_position = tile_position
							if tile_best_action.rating < best_action_target.rating:
								tile_best_action = best_action_target
	#print("@ EXITED ai_get_best_move_at_tile")
	return tile_best_action

func get_closet_tile(target: Vector2, array:PackedVector2Array):
	pass

func ai_move(target_position: Vector2i):
	print("@ AI MOVE CALLED @ : "+ str(target_position))
	var current_position = grid.local_to_map(controlled_node.position)
	find_path(target_position)
	move_on_path(current_position)

func ai_turn ():
	_in_ai_process = true
	var enemy_units  = combat.get_ai_units()
	for unit :CombatUnit in enemy_units:
		print("Began AI processing unit : "+ unit.unit.name)
		set_controlled_combatant(unit)
		await combat.ai_process_new(unit)
		print("finished Processing Unit : " + unit.unit.name)
	_enemy_units_turn_taken = true
	print("finished AI Turn")
	_in_ai_process = false

func set_selected_item(item: ItemDefinition):
	_selected_item = item

func set_unit_action(action: UnitAction):
	_action = action


func set_controlled_combatant(combatant: CombatUnit):
	#combat.get_current_combatant() = combatant
	combat.set_current_combatant(combatant)
	controlled_node = combatant.map_display
	grid.update_points_weight()

func perform_shove(pushed_unit: CombatUnit, push_vector:Vector2i):
	var target_tile = grid.get_map_tile(pushed_unit.map_tile.position + push_vector);
	if grid.is_map_position_available_for_unit_move(target_tile.position, pushed_unit.unit.movement_type):
		set_controlled_combatant(pushed_unit)
		find_path(target_tile.position)
		move_player()
		await finished_move
		pushed_unit.update_map_tile(target_tile)
		combat.complete_shove()

func trigger_reinforcements():
	combat.spawn_reinforcements(turn_count)

func update_player_state(new_state : CombatMapConstants.PLAYER_STATE):
	previous_player_state = player_state
	player_state = new_state

func update_turn_phase(new_state : CombatMapConstants.TURN_PHASE):
	print("$$ CALLED UPDATE TURN PHASE : With target turn phase : " + str(new_state))
	if new_state != turn_phase:
		previous_turn_phase = turn_phase
		turn_phase = new_state
	else: 
		print("$$ CALLED UPDATE TURN PHASE : With current turn phase")

#
# Moves the player's cursor to their first unit
#
func autoCursor():
	current_tile = combat.combatants[combat.groups[0].front()].map_position
	camera.centerCameraCenter(grid.map_to_position(current_tile))
	selector.position = grid.map_to_position(current_tile) 

#
# Updates the selected tile to a new position, but ensures it is within the grid
#
func update_current_tile(position : Vector2i):
	if grid.is_valid_tile(position):
		get_tile_info(position)
		selector.position = grid.map_to_position(current_tile)
		combat.game_ui._set_tile_info(grid.get_map_tile(current_tile))

## FSM METHODS
#
# Called on cancel in the UNIT_SELECT state
#
func fsm_unit_select_cancel(delta):
	if unit_detail_open:
		target_detailed_info.emit(null)
		unit_detail_open = false

#
# Moves the unit, visually and in code to its new position by calling move player when the user presses confirms the move
#
func fsm_unit_move_confirm(delta):
	combat.game_ui.play_menu_confirm()
	if _arrived == true:
	#If the unit is currently at a position and the player is selecting a different available position
		if current_tile != combat.get_current_combatant().map_tile.position:
			if grid.is_map_position_available_for_unit_move(current_tile, combat.get_current_combatant().unit.movement_type):
					target_tile = current_tile
					await move_player()
					# Create the unit Action Select menu
					combat.get_current_combatant().update_move_tile(grid.get_map_tile(target_tile))
					combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
					update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT)

#
# Called on cancel input during unit_move state
#
func fsm_unit_move_cancel(delta):
	_action_tiles.clear()
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)

#
# Called when the user confirms, during the action select phase.
#
func fsm_unit_action_confirm(delta):
	pass

#
# Called in the unit_action select state, this cancels the player's previous move and returns the unit to its starting position (if it has moved)
#
func fsm_unit_action_cancel(delta):
	combat.game_ui.play_menu_back()
	if (_arrived):
		combat.game_ui.hide_action_list()
		#Did the unit traverse any tiles in the move?
		var current_unit : CombatUnit = combat.get_current_combatant()
		if current_unit.map_position != current_unit.move_position:
			find_path(current_unit.map_position)
			await return_player()
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT)

#
# Called when the user confirms, during the action select phase.
#
func fsm_unit_action_target_confirm(delta):
	if _action_selected == true and _action.requires_target == true:
		var target_comb = grid.get_combat_unit(current_tile)
		# is there a valid target?
		if target_comb != null and target_comb.alive:
			# can the action target the unit in the tile?
			if _action_valid_targets.has(target_comb):
				# destroy old UI for hover
				combat.game_ui.hide_unit_combat_exchange_preview()
				# Update the combat Unit's info as a major action has been performed
				combat.get_current_combatant().update_move_tile(combat.get_current_combatant().move_tile)
				# Update the action to have a selected target
				##action_target_selected(target_comb) ## NEEDS TO BE REPLACED
			else:
				print("Invalid Target for combat action")
				target_comb = null
				pass

func fsm_unit_select_process(delta):
	if null != grid.get_combat_unit(current_tile):
		var selected_unit : CombatUnit = grid.get_combat_unit(current_tile)
		if selected_unit and selected_unit.alive:
		#create the ui footer
		#call the correct info to draw the movement and attack range
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT_HOVER)
	if Input:
		if Input.is_action_just_pressed("combat_map_confirm") or Input.is_action_just_pressed("combat_map_menu"):
			# To be implemented : combat map main menu
			pass
		elif Input.is_action_just_pressed("combat_map_up"):
			update_current_tile(current_tile + Vector2i.UP)
		elif Input.is_action_just_pressed("combat_map_left"):
			update_current_tile(current_tile + Vector2i.LEFT)
		elif Input.is_action_just_pressed("combat_map_right"):
			update_current_tile(current_tile + Vector2i.RIGHT)
		elif Input.is_action_just_pressed("combat_map_down"):
			update_current_tile(current_tile + Vector2i.DOWN)
		camera.SimpleFollow(delta)

func fsm_unit_select_hover_process(delta):
	if Input:
		var selected_unit : CombatUnit = grid.get_combat_unit(current_tile)
		if Input.is_action_just_pressed("combat_map_confirm"):
			combat.game_ui.play_menu_confirm()
			if selected_unit.allegience == Constants.FACTION.PLAYERS:
				if !selected_unit.turn_taken: 
					selected_tile = current_tile
					set_controlled_combatant(selected_unit)
					# destroy old UI for hover here
					combat.game_ui.hide_end_turn_button()
					# created UI for selected unit here
					
					# Do State transistion if applicable
					update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT)
			else : 
			# To Be Implemented : Enemy Unit Range Map
				pass 
		elif Input.is_action_just_pressed("combat_map_unit_details"):
			if selected_unit != null and selected_unit.alive:
				if unit_detail_open == false:
					target_detailed_info.emit(selected_unit)
					unit_detail_open = true
			#populate the detail info with the unit
			#create a faction unit traversal list
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_DETAILS_SCREEN)
		elif Input.is_action_just_pressed("combat_map_cycle_right"):
			# To be implemented : allow the game to jump between units on the same faction
			pass 
		elif Input.is_action_just_pressed("combat_map_cycle_left"):
			# To be implemented : allow the game to jump between units on the same faction
			pass 
		elif Input.is_action_just_pressed("combat_map_menu"):
			# To be implemented : combat map main menu
			pass
		elif Input.is_action_just_pressed("combat_map_up"):
			update_current_tile(current_tile + Vector2i.UP)
		elif Input.is_action_just_pressed("combat_map_left"):
			update_current_tile(current_tile + Vector2i.LEFT)
		elif Input.is_action_just_pressed("combat_map_right"):
			update_current_tile(current_tile + Vector2i.RIGHT)
		elif Input.is_action_just_pressed("combat_map_down"):
			update_current_tile(current_tile + Vector2i.DOWN)
		camera.SimpleFollow(delta)

func fsm_unit_details_screen_process(delta):
	if Input:
		if Input.is_action_just_pressed("combat_map_cancel"):
			target_detailed_info.emit(null)
			unit_detail_open = false
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		elif Input.is_action_just_pressed("combat_map_cycle_right"):
			# To be implemented
			# get next unit from faction
			# update current tile position to match unit positon
			pass 
		elif Input.is_action_just_pressed("combat_map_cycle_left"):
			# To be implemented : allow the game to jump between units on the same faction
			# get prev unit from faction
			# update current tile position to match unit positon
			pass
			
func fsm_unit_selected_process(delta):
	if Input:
		if Input.is_action_just_pressed("combat_map_confirm"):
			fsm_unit_move_confirm(delta)
		if Input.is_action_just_pressed("combat_map_cancel"):
			_action_tiles.clear()
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
	#draw the units current move path and ranges
	find_path(current_tile)

func fsm_unit_action_select_process(delta):
	if Input:
		if Input.is_action_just_pressed("combat_map_confirm"):
			#This should be handled by the UI pop-up
			pass
		if Input.is_action_just_pressed("combat_map_cancel"):
			fsm_unit_action_cancel(delta)

func player_fsm_process(delta):
	match player_state:
	## UNIT SELECTION
		CombatMapConstants.PLAYER_STATE.UNIT_SELECT:
			fsm_unit_select_process(delta)
		CombatMapConstants.PLAYER_STATE.UNIT_SELECT_HOVER:
			fsm_unit_select_hover_process(delta)
	## MENUS
		CombatMapConstants.PLAYER_STATE.UNIT_DETAILS_SCREEN:
			fsm_unit_details_screen_process(delta)
		CombatMapConstants.PLAYER_STATE.GAME_MENU:
			pass
	## MOVEMENT
		CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT:
			pass
	## ACTION SELECT
		CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
			pass
	## INVENTORY
		CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY_USE:
			pass
	## TRADE
		CombatMapConstants.PLAYER_STATE.UNIT_TRADE_ACTION_TARGETTING:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_TRADE_ACTION_INVENTORY:
			pass
	## SUPPORT
		CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION_INVENTORY:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION_TARGETTING:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION:
			pass
	## SHOVE
		CombatMapConstants.PLAYER_STATE.UNIT_SHOVE_ACTION_TARGET:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_SHOVE_ACTION:
			pass
	## Combat
		CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_INVENTORY:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_TARGETTING:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION:
			pass
	## Entity
		CombatMapConstants.PLAYER_STATE.UNIT_ENTITY_ACTION_INVENTORY:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_ENTITY_ACTION:
			pass

#
# Handles the selection action input and moves the player to the correct state
#
func action_selection_handler(action:String):
	match action:
		"Combat":
			# Create the apprioriate UI
			# Move the unit to the correct state
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_INVENTORY)

##OLD WILL BE REMOVED 
""""

func begin_target_selection():
	#hide the action select
	combat.game_ui.hide_action_list()
	if _action.requires_target :
		if _action == TRADE_ACTION: 
			_action_valid_targets = get_potential_support_targets(combat.get_current_combatant(), [1])
		elif _action == SHOVE_ACTION:
			_action_valid_targets = get_potential_shove_targets(combat.get_current_combatant())
			print(str(_action_valid_targets))
		else :
			target_selection_started.emit()
	else :
		combat.call(_action.name, combat.get_current_combatant())
		target_selection_finished.emit()
		combat.get_current_combatant().map_tile.position = combat.get_current_combatant().move_tile.position
		combat.get_current_combatant().map_tile.terrain =  get_terrain_at_map_position(combat.get_current_combatant().map_tile.position)

func begin_action_item_selection():
	combat.game_ui.hide_action_list()
	if _action.requires_item :
		if _action == ATTACK_ACTION:
			combat.game_ui._set_attack_action_inventory(combat.get_current_combatant())
			update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT)
		elif _action == SUPPORT_ACTION:
			combat.game_ui._set_support_action_inventory(combat.get_current_combatant())
			update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT)
		elif _action == ITEM_ACTION:
			combat.game_ui._set_inventory_list(combat.get_current_combatant())
			update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT)
		elif _action == CHEST_ACTION:
			_selected_entity = get_entity_at_tile(combat.get_current_combatant().move_tile.position)
			## Does the chest require a key?
			if _selected_entity.required_item.is_empty():
				update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT)
				action_item_selected()
			else:
				combat.game_ui._set_item_action_inventory(combat.get_current_combatant(), get_viable_chest_items(combat.get_current_combatant()))
				update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT)
	else: 
		pass ## do nothing??

func action_target_selected(target: CombatUnit):
	_action_target_unit = target
	##combat.call(_action.name, combat.get_current_combatant(), target)
	target_selection_finished.emit()
	update_player_state(get_next_action_state())

func perform_action():
	#Hide the interactable UI
	combat.game_ui.hide_action_list()
	combat.game_ui.hide_attack_action_inventory()
	combat.game_ui.hide_action_inventory()
	combat.get_current_combatant().map_tile.position = combat.get_current_combatant().move_tile.position
	combat.get_current_combatant().map_tile.terrain = get_terrain_at_map_position(combat.get_current_combatant().move_tile.position)
	#Use logic to call the correct method in the Combat.gd
	if(_action.requires_target):
		if(_action.requires_item): #both target andi item (unit, target, item)
			combat.call(_action.name, combat.get_current_combatant(), _action_target_unit)
		else :
			#only target (unit, target)
			combat.call(_action.name, combat.get_current_combatant(), _action_target_unit)
		#only item (unit, item)
	elif(_action.requires_item and not _action.requires_target):
		if(_action.requires_entity):
			combat.call(_action.name, combat.get_current_combatant(), _selected_item, _selected_entity)
		else:
			combat.call(_action.name, combat.get_current_combatant(), _selected_item)
	else :
		#call with just method method(unit)
		combat.call(_action.name, combat.get_current_combatant())

func action_item_selected():
	if _action == ATTACK_ACTION: 
		if _selected_item is WeaponDefinition:
			combat.get_current_combatant().unit.set_equipped(_selected_item)
			_item_selected = true
			_action_valid_targets = get_potential_targets(combat.get_current_combatant(), _selected_item.attack_range)
			combat.game_ui.hide_attack_action_inventory()
			update_player_state(get_next_action_state())
	elif _action == SUPPORT_ACTION:
		if _selected_item is WeaponDefinition:
			combat.get_current_combatant().unit.set_equipped(_selected_item)
			_item_selected = true
			_action_valid_targets = get_potential_support_targets(combat.get_current_combatant(), _selected_item.attack_range)
			combat.game_ui.hide_attack_action_inventory()
			update_player_state(get_next_action_state())
	elif _action == ITEM_ACTION: 
		_item_selected = true
		combat.game_ui.disable_inventory_list_butttons()
		update_player_state(get_next_action_state())
	elif _action == CHEST_ACTION:
		_item_selected = true
		combat.game_ui.hide_action_inventory()
		update_player_state(get_next_action_state())

func use_action_selected():
	update_player_state(get_next_action_state())
	

func get_next_action_state()-> Constants.PLAYER_STATE:
	if _action and _action_selected:
		#find the first occurance of an action
		var flow_index = _action.flow.find(map_player_state_to_action_state(player_state))
		if flow_index + 1 < _action.flow.size():
			#Navigate the user to the next appriopriate state1]:
			return map_action_state_to_player_state(_action.flow[flow_index+1])
	return player_state

func get_previous_action_state() -> Constants.PLAYER_STATE:
	if _action and _action_selected:
		#print("player state = " + str(player_state))
		var flow_index = _action.flow.find(map_player_state_to_action_state(player_state))
		if flow_index == 0:
			##combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
			return Constants.PLAYER_STATE.UNIT_ACTION_SELECT
		if flow_index != 0 and flow_index -1 < _action.flow.size():
			#Navigate the user to the next appriopriate state1]:
			return map_action_state_to_player_state(_action.flow[flow_index-1])
	return player_state

func clear_action_variables():
	_action_target_unit = null
	_action_target_unit_selected = false
	_unit_action_completed = false
	_unit_action_initiated= false
	_action_ranges.clear()
	#_action_tiles.clear()
	#_action_valid_targets.clear()

func begin_action_flow():
	clear_action_variables()
	if _action:
		_action_selected = true
		if not _action.flow.is_empty():
			if _action.flow.front() == Constants.UNIT_ACTION_STATE.ITEM_SELECT: 
				begin_action_item_selection()
			elif _action.flow.front() == Constants.UNIT_ACTION_STATE.TARGET_SELECT: 
				begin_target_selection()
				update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT)
			else:
				update_player_state(Constants.PLAYER_STATE.UNIT_ACTION)

func revert_action_flow():
	if _action:
		if not _action.flow.is_empty():
			var previous_state = get_previous_action_state()
			if previous_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT:
				_action = null
				_action_selected = false
				combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
				update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_SELECT)
			elif previous_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
				_item_selected = false
				_selected_item = null
				begin_action_item_selection()
				update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT)
			elif previous_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
				_action_target_unit = null
				_action_target_unit_selected = false
				begin_target_selection()
				update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT)
			else:
				update_player_state(Constants.PLAYER_STATE.UNIT_ACTION)

func map_player_state_to_action_state(player_state: Constants.PLAYER_STATE) -> Constants.UNIT_ACTION_STATE:
	if player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
		return Constants.UNIT_ACTION_STATE.ITEM_SELECT
	elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
		return Constants.UNIT_ACTION_STATE.TARGET_SELECT
	elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_OPTION_SELECT:
		return Constants.UNIT_ACTION_STATE.OPTION_SELECT
	else :
		return Constants.UNIT_ACTION_STATE.ACTION

func map_action_state_to_player_state(action_state: Constants.UNIT_ACTION_STATE) -> Constants.PLAYER_STATE:
	if action_state == Constants.UNIT_ACTION_STATE.ITEM_SELECT:
		return Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT
	elif action_state == Constants.UNIT_ACTION_STATE.TARGET_SELECT:
		return Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT
	elif action_state == Constants.UNIT_ACTION_STATE.OPTION_SELECT:
		return Constants.PLAYER_STATE.UNIT_ACTION_OPTION_SELECT
	else :
		return Constants.PLAYER_STATE.UNIT_ACTION

"""
##
"""
func astar_path_distance(path: PackedVector2Array) -> int:
	var distance : int = 0
	for cell in path:
		distance = distance + _astargrid.get_point_weight_scale(cell)
	return distance
"""
