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
signal tile_info_updated(tile : CombatMapTile, unit: CombatUnit)
signal target_detailed_info(combat_unit : CombatUnit)

##State Machine
#@export var seed : int
var turn_count : int
var turn_order : Array[CombatMapConstants.FACTION] = [CombatMapConstants.FACTION.PLAYERS, CombatMapConstants.FACTION.ENEMIES] #Default for a two factioned map
var turn_order_index : int = 0
var turn_owner : CombatMapConstants.FACTION =  CombatMapConstants.FACTION.NULL
var player_factions :  Array[CombatMapConstants.FACTION] = [CombatMapConstants.FACTION.PLAYERS]

var game_state: CombatMapConstants.COMBAT_MAP_STATE #= CombatMapConstants.COMBAT_MAP_STATE.INITIALIZING
var previous_game_state: CombatMapConstants.COMBAT_MAP_STATE #= CombatMapConstants.COMBAT_MAP_STATE.INITIALIZING
var turn_phase: CombatMapConstants.TURN_PHASE #= CombatMapConstants.TURN_PHASE.INITIALIZING
var previous_turn_phase: CombatMapConstants.TURN_PHASE #= CombatMapConstants.TURN_PHASE.INITIALIZING
var player_state: CombatMapConstants.PLAYER_STATE #= CombatMapConstants.PLAYER_STATE.INITIALIZING
var selected_unit_player_state_stack: Stack = Stack.new()

##Controller Main Variables
@export var controlled_node : Control
@export var combat: Combat 
var tile_map : TileMap
var grid: CombatMapGrid
var camera: CombatMapCamera

var current_tile : Vector2i # Where the cursor currently is
var selected_tile : Vector2i # What we first selected (Most likely the tile containing the unit we have selected)
var target_tile : Vector2i # Our First Target
var move_tile : Vector2i # the tile we moved to

## Selector/Cursor
@export var selector : CombatMapSelector

##Player Interaction Variables
var unit_detail_open = false #TO BE UPDATED TO unit_detial_overlay
var option_menu : bool = false
var unit_detail_overlay : bool = false
#var map_focused : bool = true This may be redundant

#Movement Variables
var _arrived = true
var _path : Array[Vector2i] #to be converted to Array[Vector2i]
var _movable_tiles : Array[Vector2i]
var _attackable_tiles : Array[Vector2i]
var _interactable_tiles : Array[Vector2i]
var _weapon_attackable_tiles : Array[Vector2i]
var default_move_speed = MOVEMENT_SPEED * 5
var return_move_speed = MOVEMENT_SPEED * 5
var move_speed = default_move_speed
var _previous_position : Vector2i
var _next_position
var _position_id = 0
var _camera_follow_move : bool = false

#Action Select
#var _available_actions : Array[UnitAction]
#var _action: UnitAction
#var _action_selected: bool # Is this redundant?

#Action Variables
var targetting_resource : CombatMapUnitActionTargettingResource = CombatMapUnitActionTargettingResource.new() 
var _action_target_unit : CombatUnit
var _action_tiles : Array[Vector2i]
var _action_valid_targets : Array[CombatUnit]
var _action_ranges : Array[int] = []

#Combat Action Variables
var exchange_info: UnitCombatExchangeData
var support_exchange_info : UnitSupportExchangeData
#Item Selection Variables
var _selected_item: ItemDefinition
var _selected_entity: CombatMapEntity
var _item_selected: bool

#AI Variables
var _in_ai_process: bool = false
var _enemy_units_turn_taken: bool = false


func _ready():
	##Load Seed to ensure consistent runs
	#seed(seed)
	##Configure FSM States
	tile_map = get_node("../Terrain/TileMap")
	turn_count = 1
	game_state = CombatMapConstants.COMBAT_MAP_STATE.INITIALIZING
	previous_game_state = CombatMapConstants.COMBAT_MAP_STATE.INITIALIZING
	turn_phase = CombatMapConstants.TURN_PHASE.INITIALIZING
	previous_turn_phase = CombatMapConstants.TURN_PHASE.INITIALIZING
	player_state = CombatMapConstants.PLAYER_STATE.INITIALIZING
	##create variables needed for Combat Map
	camera = CombatMapCamera.new()
	grid = CombatMapGrid.new()
	##Assign created variables to create place in the scene tree
	grid.setup(tile_map)
	self.add_child(grid)
	self.add_child(camera)
	#Auto Wire combat signals for modularity
	combat.connect("perform_shove", perform_shove)
	combat.connect("combatant_added", combatant_added)
	combat.connect("combatant_died", combatant_died)
	combat.connect("major_action_completed", _on_visual_combat_major_action_completed)
	combat.connect("minor_action_completed", _on_visual_combat_minor_action_completed)
	combat.connect("turn_advanced", advance_turn)
	await combat.ready
	combat.populate()
	# Init & Populate dynamically created nodes
	await camera.init()
	#await combat.load_entities()
	# Prepare to transition to player turn and handle player input
	await combat.game_ui.ready
	autoCursor()
	##Set the correct states to begin FSM flow
	update_game_state(CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN)
	turn_owner = CombatMapConstants.FACTION.PLAYERS
	
#process called on frame
func _process(delta):
	queue_redraw()
	if (game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN or game_state == CombatMapConstants.COMBAT_MAP_STATE.AI_TURN):
		if(turn_phase == CombatMapConstants.TURN_PHASE.INITIALIZING):
			# initializing UI method
			update_turn_phase(CombatMapConstants.TURN_PHASE.BEGINNING_PHASE)
		elif(turn_phase == Constants.TURN_PHASE.BEGINNING_PHASE):
			#await ui.play_turn_banner(turn_owner)
			await process_terrain_effects()
			# await process_skill_effects()
			await clean_up() # --> remove debuffs / buffs, flush data structures
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

			#All players have completed their turns, and order resets
			if turn_order_index == 0:
				turn_count += 1
			progress_turn_order()
			update_turn_phase(CombatMapConstants.TURN_PHASE.BEGINNING_PHASE)
	elif game_state == CombatMapConstants.COMBAT_MAP_STATE.PROCESSING:
		if _arrived == false:
			process_unit_move(delta)

#draw the area
func _draw():
	if(game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN):
		if(player_state == CombatMapConstants.PLAYER_STATE.UNIT_SELECT_HOVER):
			draw_hover_movement_ranges(_movable_tiles, true, _attackable_tiles,true)
		elif(player_state == CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT):
			draw_movement_ranges(_movable_tiles, true, _attackable_tiles,true)
			drawSelectedpath()
		if(player_state == CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_TARGETTING or player_state == CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_INVENTORY):
			draw_attack_range(_weapon_attackable_tiles)

func clean_up():
	selected_unit_player_state_stack.flush()
	targetting_resource.clear()

func process_unit_move(delta):
	unit_move_fix_overshoots(delta)
	#if we are ready to get the next place to move to
	if controlled_node.position.distance_to(_next_position) < 1:
		controlled_node.position = _next_position
		var new_position: Vector2i = grid.position_to_map(_next_position)
		# set the previous position to the grid position
		_previous_position = new_position
		#check if there is another tile to be moved into
		if (_position_id < _path.size() - 1):
			_position_id += 1
			_next_position = grid.map_to_position(_path[_position_id])
		else:
			update_game_state(previous_game_state)
			_arrived = true
			finished_move.emit(new_position)
			if game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN:
				# Cancel Flow
				if(player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT):
					# Return cursor
					move_cursor(combat.get_current_combatant().map_position)
					_camera_follow_move = false
					update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT)
				# Move Flow
				elif(player_state == CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT):
					combat.get_current_combatant().update_move_tile(grid.get_map_tile(new_position))
					var actions :Array[String]  = get_available_unit_actions_NEW(combat.get_current_combatant())
					combat.game_ui.create_unit_action_container(actions)
					update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT)
			else: # AI Units do nothing 
				pass

func unit_move_fix_overshoots(delta):
	#check and resolve potential overshoots
	if (delta * move_speed) > controlled_node.position.distance_to(_next_position):
			controlled_node.position = _next_position
	else :
		controlled_node.position += controlled_node.position.direction_to(_next_position) * delta * move_speed
	
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
		update_game_state(CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN)
	else : 
		update_game_state(CombatMapConstants.COMBAT_MAP_STATE.AI_TURN)

func get_entity_at_tile(tile:Vector2i)-> CombatMapEntity:
	for ent in combat.entities:
		if ent.position == tile and ent.active:
			return ent
	return null

func combatant_added(combatant : CombatUnit):
	grid.set_combat_unit(combatant, combatant.map_position)
	
func entity_added(cme: CombatMapEntity):
	pass

func combatant_died(combatant):
	if combatant.map_display:
		combatant.map_display.queue_free()

func entity_disabled(e :CombatMapEntity):
	if e.display:
		e.display.queue_free()

func find_path(goal_tile:Vector2i, origin_tile: Vector2i = Vector2i(-999,-999)):
	_path.clear()
	if(origin_tile == Vector2i(-999,-999)):
		origin_tile = grid.position_to_map(controlled_node.position)
	_path = grid.find_path(origin_tile, goal_tile)
	queue_redraw()

func move_player():
	_camera_follow_move = false
	move_speed = default_move_speed
	var current_position = grid.position_to_map(controlled_node.position)
	grid.update_astar_points(combat.get_current_combatant())
	_path = grid.find_path(move_tile,current_position)
	var _path_size = _path.size()
	if _path_size > 1: # and movement > 0:
		move_on_path(move_tile)

func return_player():
	_camera_follow_move = true
	move_speed = return_move_speed
	var original_position = combat.get_current_combatant().map_position
	var current_position = grid.position_to_map(controlled_node.position)
	grid.update_astar_points(combat.get_current_combatant())
	_path = grid.find_path(original_position,current_position)
	var _path_size = _path.size()
	if _path_size >= 1:
		move_on_path(original_position)

#
# Moves unit on specified path
#
func move_on_path(current_position):
	_previous_position = current_position
	_position_id = 1
	# Is there another space to move on the path
	if _path.size() > _position_id :
		_next_position = grid.map_to_position(_path[_position_id])
	_arrived = false
	update_game_state(CombatMapConstants.COMBAT_MAP_STATE.PROCESSING)
	queue_redraw()
	

##Draw the path between the selected Combatant and the mouse cursor
func drawSelectedpath():
	if _arrived == true :
		var path_length = combat.get_current_combatant().unit.stats.movement
		#Get the length of the path
		for i in range(_path.size()):
			var point = _path[i]
			var draw_color = Color.TRANSPARENT
			if grid.is_unit_blocked(point, combat.get_current_combatant().unit.movement_type):
				draw_color = Color.DIM_GRAY
				if path_length - grid.get_tile_cost_at_position(point, combat.get_current_combatant()) >= 0:
					draw_color = Color.WHITE
				if i > 0:
					path_length -= grid.get_tile_cost_at_position(point, combat.get_current_combatant())
			else : 
				break
			draw_texture(PATH_TEXTURE, point - Vector2(16, 16), draw_color)

#Draws a units move and attack ranges
func draw_movement_ranges(move_range:Array[Vector2i], draw_move_range:bool, attack_range:Array[Vector2i], draw_attack_range:bool):
	var move_range_color = Color.BLUE
	var attack_range_color = Color.CRIMSON
	if (draw_move_range) :
		for tile in move_range :
			draw_texture(GRID_TEXTURE, Vector2(tile)  * Vector2(32, 32), move_range_color)
	if (draw_attack_range) :
		for tile in attack_range :
			if(!move_range.has(tile) or !draw_move_range) : 
				draw_texture(GRID_TEXTURE, Vector2(tile)  * Vector2(32, 32), attack_range_color)

func draw_hover_movement_ranges(move_range:Array[Vector2i], draw_move_range:bool, attack_range:Array[Vector2i], draw_attack_range:bool):
	var move_range_color = Color(Color.BLUE,.25)
	var attack_range_color = Color(Color.CRIMSON,.25)
	if (draw_move_range) :
		for tile in move_range :
			draw_texture(GRID_TEXTURE, Vector2(tile)  * Vector2(32, 32), move_range_color)
	if (draw_attack_range) :
		for tile in attack_range :
			if(!move_range.has(tile) or !draw_move_range) : 
				draw_texture(GRID_TEXTURE, Vector2(tile)  * Vector2(32, 32), attack_range_color)

func draw_attack_range(attack_range:Array[Vector2i]):
	for tile in attack_range : 
			draw_texture(GRID_TEXTURE, Vector2(tile)  * Vector2(32, 32), Color.CRIMSON)

func draw_action_tiles(tiles:Array[Vector2i], ua:UnitAction):
	##Set the tile color based on the type of action
	var tile_color : Color = Color.CRIMSON
	"""if _action:
		if _action == SUPPORT_ACTION: 
			tile_color = Color.SEA_GREEN
		if _action == TRADE_ACTION:
			tile_color = Color.BLUE_VIOLET
		if _action == SHOVE_ACTION:
			tile_color = Color.ORANGE"""
	for tile in tiles : 
		draw_texture(GRID_TEXTURE, Vector2(tile)  * Vector2(32, 32), tile_color)

func get_tile_info(position : Vector2i): 
	tile_info_updated.emit(grid.get_map_tile(position), grid.get_combat_unit(position))

func get_potential_targets(cu : CombatUnit, range: Array[int] = []) -> Array[CombatUnit]:
	var range_list :Array[int] = []
	if range.is_empty():
		range_list = cu.unit.inventory.get_available_attack_ranges()
	else:
		range_list = range.duplicate()
	var attackable_tiles : Array[Vector2i]
	var response : Array[CombatUnit]
	if range_list.is_empty() : ##There is no attack range
		return response
	attackable_tiles = get_attackable_tiles(range_list, cu)
	_action_tiles = attackable_tiles.duplicate()
	for tile in attackable_tiles :
		if grid.get_combat_unit(tile):
			if(grid.get_combat_unit(tile).allegience != cu.allegience) :
				response.append(grid.get_combat_unit(tile))
	return response

func get_potential_support_targets(cu : CombatUnit, range: Array[int] = []) -> Array[CombatUnit]:
	var range_list :Array[int] = []
	if range.is_empty():
		range_list = cu.unit.inventory.get_available_support_ranges()
	else:
		range_list = range.duplicate()
	var attackable_tiles : Array[Vector2i]
	var response : Array[CombatUnit]
	if range_list.is_empty() : ##There is no range
		return response
	attackable_tiles = get_attackable_tiles(range_list, cu)
	print(str(attackable_tiles))
	_action_tiles = attackable_tiles.duplicate()
	for tile in attackable_tiles :
		if grid.get_combat_unit(tile) :
			if(grid.get_combat_unit(tile).allegience == cu.allegience and grid.get_combat_unit(tile) != cu) :
				response.append(grid.get_combat_unit(tile))
	return response
	
func get_potential_shove_targets(cu: CombatUnit) -> Array[CombatUnit]:
	var pushable_targets : Array[CombatUnit]
	for tile in grid.get_target_tile_neighbors(cu.move_position):
		if grid.get_combat_unit(tile) :
			var pushable_unit = grid.get_combat_unit(tile)
			var push_vector : Vector2i  = Vector2i(tile) - Vector2i(cu.move_position)
			var shove_tile : Vector2i = Vector2i(tile) + push_vector;
			if grid.is_map_position_available_for_unit_move(shove_tile, pushable_unit.unit.movement_type):
				pushable_targets.append(pushable_unit)
	return pushable_targets

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
	if  grid.get_entity(cu.move_position) :
		var _entity = grid.get_entity(cu.move_position)
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

#
#
#
func get_attackable_tiles(range_list: Array[int], cu: CombatUnit):
	var attackable_tiles : Array[Vector2i]
	for range in range_list:
		if cu.move_position :
			attackable_tiles.append_array(grid.get_tiles_at_range_new(range, cu.move_position))
	return attackable_tiles

#
#
#
func populate_tiles_for_weapon(range_list: Array[int], origin: Vector2i) -> Array[Vector2i]:
	var reachable_tiles : Array[Vector2i] 
	reachable_tiles = grid.get_range_DFS(range_list.max(), origin)
	if range_list.min() > 1:
		var removed_tiles : Array[Vector2i] = grid.get_range_DFS(range_list.min()- 1, origin)
		#remove the overlap where applicable
		for tile in removed_tiles:
			if reachable_tiles.has(tile):
				reachable_tiles.erase(tile)
	return reachable_tiles

func process_terrain_effects():
	for combat_unit in combat.combatants:
		if combat not in combat.dead_units:
			if (combat_unit.allegience == Constants.FACTION.PLAYERS and game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN) or (combat_unit.allegience == Constants.FACTION.ENEMIES and game_state == CombatMapConstants.COMBAT_MAP_STATE.AI_TURN):
				if grid.get_terrain(combat_unit.map_position): 
					var target_terrain = grid.get_terrain(combat_unit.map_position)
					if target_terrain.active_effect_phases == CombatMapConstants.TURN_PHASE.keys()[turn_phase]:
						if target_terrain.effect != Terrain.TERRAIN_EFFECTS.NONE:
							if target_terrain.effect == Terrain.TERRAIN_EFFECTS.HEAL:
								if combat_unit.unit.hp < combat_unit.unit.stats.hp:
									print("HEALED UNIT : " + combat_unit.unit.name)
									combat.combatExchange.heal_unit(combat_unit, target_terrain.effect_weight)

func get_available_unit_actions(cu:CombatUnit) -> Array[UnitAction]:
	#get maximum actionable distance (ex weapons that have far atk)
	#get actionable tiles
	#get a map of units w/ ranges from the map
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

func get_available_unit_actions_NEW(cu:CombatUnit) -> Array[String]: # TO BE OPTIMIZED
	#get maximum actionable distance (ex weapons that have far atk)
	#get actionable tiles
	#get a map of units w/ ranges from the map
	var action_array : Array[String] = []
	if cu.minor_action_taken == false:
		if not get_potential_support_targets(cu, [1]).is_empty():
			action_array.push_front("Trade")
	if not cu.unit.inventory.is_empty():
		action_array.append("Item")
	if cu.major_action_taken == false:
		if not get_potential_shove_targets(cu).is_empty():
			action_array.push_front("Shove")
		if chest_action_available(cu):
			action_array.push_front("Chest")
		if not get_potential_support_targets(cu).is_empty():
			action_array.push_front("Support")
		if not get_potential_targets(cu).is_empty():
			action_array.push_front("Attack")
	action_array.append("Wait")
	return action_array

func _on_visual_combat_major_action_completed() -> void:
	selector.set_mode(selector.MODE.DEFAULT)
	camera.set_mode(camera.CAMERA_MODE.FOLLOW)
	update_current_tile(move_tile)
	selected_unit_player_state_stack.flush()
	

func _on_visual_combat_minor_action_completed() -> void:
	_selected_item = null
	_item_selected = false
	set_controlled_combatant(combat.get_current_combatant())
	combat.game_ui.hide_end_turn_button()
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT)

## AI Methods
#
# This method finds the best move for the AI, and checks all actionable tiles
#
func ai_process_new(ai_unit: CombatUnit) -> aiAction:
	grid.update_astar_points(ai_unit)
	var current_position = grid.position_to_map(controlled_node.position)
	var moveable_tiles : Array[Vector2i]
	var actionable_tiles :Array[Vector2i]
	var actionable_range : Array[int]= ai_unit.unit.get_attackable_ranges()
	var action_tile_options: Array[Vector2i]
	var selected_action: aiAction
	var called_move : bool = false
	#Step 1 : Get all moveable tiles
	selected_action = ai_get_best_move_at_tile(ai_unit, current_position, actionable_range)
	# Step 2, if the unit can move do analysis on movable tiles, this does not include defend point AI as they do not move
	if ai_unit.ai_type != Constants.UNIT_AI_TYPE.DEFEND_POINT:
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
							for tile in grid.get_tiles_at_range_new(range,combat.combatants[targetable_unit_index].map_position):
								if not grid.is_position_occupied(tile):
									if tile not in actionable_tiles:
										actionable_tiles.append(tile)
					print("@ FINISHED MOVE AND TARGET SEARCH, NO TARGET FOUND")
					var closet_action_tile
					var _astar_closet_distance = 99999
					var closet_tile_in_range_to_action_tile
					for tile in actionable_tiles:
						if grid.is_valid_tile(tile):
							var _astar_path = grid.get_id_path(current_tile, tile)
							if _astar_path:
								var _astar_distance = grid.astar_path_distance(_astar_path)
								if _astar_distance < _astar_closet_distance and _astar_distance != null:
									closet_action_tile = tile
									_astar_closet_distance = _astar_distance
					print("@ FOUND CLOSET ACTIONABLE TILE : [" + str(closet_action_tile) + "]")
					if closet_action_tile != null: 
						if not grid.get_point_weight_scale(closet_action_tile) > 999999:
							if closet_action_tile != Vector2i(current_position):
								if closet_action_tile in moveable_tiles:
									ai_unit.update_move_tile(grid.get_map_tile(closet_action_tile))
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
									if closet_tile_in_range_to_action_tile !=  Vector2i(current_position):
										ai_unit.update_move_tile(grid.get_map_tile(closet_tile_in_range_to_action_tile))
										ai_move(closet_tile_in_range_to_action_tile)
										called_move = true
			else:
				if called_move == false:
					if Vector2(current_position) != selected_action.action_position:
						ai_unit.update_move_tile(grid.get_map_tile(selected_action.action_position))
						ai_move(selected_action.action_position)
						called_move = true
	# Step 4, Perform the move if it is required
	if(called_move):
		print("@ AWAIT AI MOVE FINISH")
		await finished_move
		print("@ COMPLTED WAITING CALLING AI ACTION")
		#update the combat_unit info with the new tile info
		confirm_unit_move(ai_unit)
	return selected_action

#
# Calculates the highest value move at a particular tile
#
func ai_get_best_move_at_tile(ai_unit: CombatUnit, tile_position: Vector2i, attack_range: Array[int]) -> aiAction:
	var tile_best_action: aiAction = aiAction.new()
	tile_best_action.action_type = "NONE"
	tile_best_action.rating = 0
	# Check combat action values
	for range in attack_range:
		for tile in grid.get_tiles_at_range_new(range,tile_position):
			# does the tile have a unit?
			if grid.get_combat_unit(tile) != null: 
				# is the unit hostile?
				if grid.get_combat_unit(tile).allegience == Constants.FACTION.PLAYERS:
					if not ai_unit.unit.get_usable_weapons_at_range(range).is_empty():
						if grid.get_effective_terrain(grid.get_map_tile(tile)):
							var best_action_target : aiAction = combat.ai_get_best_attack_action(ai_unit, CustomUtilityLibrary.get_distance(tile, tile_position), grid.get_combat_unit(tile), grid.get_effective_terrain(grid.get_map_tile(tile)))
							best_action_target.target_position = tile
							best_action_target.action_position = tile_position
							if tile_best_action.rating < best_action_target.rating:
								tile_best_action = best_action_target
	return tile_best_action

func ai_move(target_position: Vector2i):
	print("@ AI MOVE CALLED @ : "+ str(target_position))
	var current_position = grid.position_to_map(controlled_node.position)
	_path = grid.find_path(target_position,current_position)
	move_on_path(target_position)

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

func populate_combatant_tile_ranges(combatant: CombatUnit):
	grid.update_astar_points(combatant)
	_movable_tiles.clear()
	_movable_tiles = grid.get_range_DFS(combatant.unit.stats.movement, current_tile, combatant.unit.movement_type, true)
	_attackable_tiles.clear()
	var edge_array = grid.find_edges(_movable_tiles)
	_attackable_tiles = grid.get_range_multi_origin_DFS(combatant.unit.inventory.get_max_attack_range(), edge_array)

func set_controlled_combatant(combatant: CombatUnit):
	#combat.get_current_combatant() = combatant
	combat.set_current_combatant(combatant)
	controlled_node = combatant.map_display
	populate_combatant_tile_ranges(combatant)

func perform_shove(pushed_unit: CombatUnit, push_vector:Vector2i):
	var final_tile = grid.get_map_tile(pushed_unit.map_tile.position + push_vector);
	if grid.is_map_position_available_for_unit_move(final_tile.position, pushed_unit.unit.movement_type):
		set_controlled_combatant(pushed_unit)
		find_path(final_tile.position)
		pushed_unit.update_move_tile(final_tile.position)
		move_player()
		await finished_move
		confirm_unit_move(pushed_unit)
		combat.complete_shove()

#
# Calls Grid function to update map, and finalizes the tile updates to the combat_unit. This replaces the map_tile
#
func confirm_unit_move(combat_unit: CombatUnit):
	grid.combat_unit_moved(combat_unit.map_position,combat_unit.move_position)
	combat_unit.update_map_tile(grid.get_map_tile(combat_unit.move_position))

func trigger_reinforcements():
	combat.spawn_reinforcements(turn_count)

func update_player_state(new_state : CombatMapConstants.PLAYER_STATE):
	queue_current_state()
	player_state = new_state

func revert_player_state():
	var current_state : CombatControllerPlayerStateData = dequeue_previous_state()
	player_state = current_state._player_state
	current_tile = current_state._current_tile
	selected_tile = current_state._selected_tile
	target_tile = current_state._target_tile
	move_tile = current_state._move_tile 
	update_current_tile(current_tile)
	selector.set_mode(current_state._selector_mode)

func queue_current_state():
	if selected_unit_player_state_stack != null:
		var current_state : CombatControllerPlayerStateData = CombatControllerPlayerStateData.new(player_state, current_tile, selected_tile, target_tile, move_tile, selector.current_mode)
		selected_unit_player_state_stack.push(current_state)

func get_previous_player_state_data() -> CombatControllerPlayerStateData:
	if selected_unit_player_state_stack != null:
		return selected_unit_player_state_stack.peek()
	return null

func dequeue_previous_state() -> CombatControllerPlayerStateData:
	if selected_unit_player_state_stack != null:
		return selected_unit_player_state_stack.pop()
	return null

func update_turn_phase(new_state : CombatMapConstants.TURN_PHASE):
	print("$$ CALLED UPDATE TURN PHASE : With target turn phase : " + str(new_state))
	if new_state != turn_phase:
		previous_turn_phase = turn_phase
		turn_phase = new_state
	else: 
		print("$$ CALLED UPDATE TURN PHASE : With current turn phase")

func update_game_state(new_state : CombatMapConstants.COMBAT_MAP_STATE):
	previous_game_state = game_state
	game_state = new_state
	
#
# Moves the player's cursor to their first unit
#
func autoCursor():
	update_current_tile(combat.combatants[combat.groups[0].front()].map_position)
	camera.centerCameraCenter(grid.map_to_position(current_tile))
	selector.position = grid.map_to_position(current_tile)

func move_cursor(position: Vector2i):
	update_current_tile(position)
	camera.centerCameraCenter(grid.map_to_position(position))
	selector.position = grid.map_to_position(position)

#
# Updates the selected tile to a new position, but ensures it is within the grid
#
func update_current_tile(position : Vector2i):
	if grid.is_valid_tile(position):
		current_tile = position
		get_tile_info(position)
		selector.position = grid.map_to_position(current_tile)
		combat.game_ui._set_tile_info(grid.get_map_tile(current_tile), grid.get_combat_unit(current_tile))

## FSM METHODS
#
# Called on cancel in the UNIT_SELECT state
#
func fsm_unit_select_cancel(delta):
	if unit_detail_open:
		target_detailed_info.emit(null)
		unit_detail_open = false

func fsm_unit_move_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			fsm_unit_move_confirm(delta)
		elif Input.is_action_just_pressed("ui_cancel"):
			fsm_unit_move_cancel(delta)
		elif Input.is_action_just_pressed("combat_map_up"):
			update_current_tile(current_tile + Vector2i.UP)
		elif Input.is_action_just_pressed("combat_map_left"):
			update_current_tile(current_tile + Vector2i.LEFT)
		elif Input.is_action_just_pressed("combat_map_right"):
			update_current_tile(current_tile + Vector2i.RIGHT)
		elif Input.is_action_just_pressed("combat_map_down"):
			update_current_tile(current_tile + Vector2i.DOWN)
		camera.SimpleFollow(delta)

#
# Moves the unit, visually and in code to its new position by calling move player when the user presses confirms the move
#
func fsm_unit_move_confirm(delta):
	combat.game_ui.play_menu_confirm()
	if _arrived == true:
		if current_tile in _movable_tiles:
		#If the unit is currently at a position and the player is selecting a different available position
			if current_tile != combat.get_current_combatant().map_position:
				if grid.is_map_position_available_for_unit_move(current_tile, combat.get_current_combatant().unit.movement_type):
						move_tile = current_tile
						move_player()
			else : 
				combat.get_current_combatant().update_move_tile(grid.get_map_tile(selected_tile))
				var actions :Array[String]  = get_available_unit_actions_NEW(combat.get_current_combatant())
				combat.game_ui.create_unit_action_container(actions)
				update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT)
#
# Called on cancel input during unit_move state
#
func fsm_unit_move_cancel(delta):
	_action_tiles.clear()
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)

#
# Called in the unit_action select state, this cancels the player's previous move and returns the unit to its starting position (if it has moved)
#
func fsm_unit_action_cancel(delta = null):
	combat.game_ui.play_menu_back()
	if (_arrived):
		#Did the unit traverse any tiles in the move?
		var current_unit : CombatUnit = combat.get_current_combatant()
		if current_unit.map_position != current_unit.move_position:
			find_path(current_unit.map_position)
			return_player()
			# State transition after completed move
		else: 
			# State transition
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT)

func fsm_unit_select_process(delta):
	if null != grid.get_combat_unit(current_tile):
		var selected_unit : CombatUnit = grid.get_combat_unit(current_tile)
		if selected_unit and selected_unit.alive:
		#create the ui footer
		#call the correct info to draw the movement and attack range
			populate_combatant_tile_ranges(selected_unit)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT_HOVER)
			return
	if Input:
		if Input.is_action_just_pressed("ui_confirm") or Input.is_action_just_pressed("start_button"):
			combat.game_ui.create_combat_map_game_menu()
			update_player_state(CombatMapConstants.PLAYER_STATE.GAME_MENU)
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
	if grid.get_combat_unit(current_tile) == null:
		update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		return
	# always keep the footer open
	if Input:
		var selected_unit : CombatUnit = grid.get_combat_unit(current_tile)
		if Input.is_action_just_pressed("ui_confirm"):
			combat.game_ui.play_menu_confirm()
			if selected_unit.allegience == Constants.FACTION.PLAYERS:
				if !selected_unit.turn_taken: 
					selected_tile = current_tile
					set_controlled_combatant(selected_unit)
					update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT)
				else:
					combat.game_ui.create_combat_map_game_menu()
					update_player_state(CombatMapConstants.PLAYER_STATE.GAME_MENU)
			else : 
			# To Be Implemented : Enemy Unit Range Map
				pass 
		elif Input.is_action_just_pressed("details"):
			if selected_unit != null and selected_unit.alive:
				if unit_detail_open == false:
					target_detailed_info.emit(selected_unit)
					unit_detail_open = true
			#populate the detail info with the unit
			#create a faction unit traversal list
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_DETAILS_SCREEN)
		elif Input.is_action_just_pressed("right_bumper"):
			# To be implemented : allow the game to jump between units on the same faction
			pass 
		elif Input.is_action_just_pressed("left_bumper"):
			# To be implemented : allow the game to jump between units on the same faction
			pass 
		elif Input.is_action_just_pressed("start_button"):
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
		if Input.is_action_just_pressed("ui_cancel"):
			target_detailed_info.emit(null)
			unit_detail_open = false
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		elif Input.is_action_just_pressed("right_bumper"):
			# To be implemented
			# get next unit from faction
			# update current tile position to match unit positon
			pass 
		elif Input.is_action_just_pressed("left_bumper"):
			# To be implemented : allow the game to jump between units on the same faction
			# get prev unit from faction
			# update current tile position to match unit positon
			pass
			
func fsm_unit_selected_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			fsm_unit_move_confirm(delta)
		if Input.is_action_just_pressed("ui_cancel"):
			_action_tiles.clear()
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
	#draw the units current move path and ranges
	find_path(current_tile)

func fsm_unit_action_select_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			#This should be handled by the UI pop-up
			pass
		if Input.is_action_just_pressed("ui_cancel"):
			combat.game_ui.destory_active_ui_node()
			fsm_unit_action_cancel(delta)

func fsm_game_menu_cancel():
	combat.game_ui.destory_active_ui_node()
	revert_player_state()

func fsm_game_menu_end_turn():
	combat.game_ui.destory_active_ui_node()
	advance_turn()

#
# Main part of the FSM 
#
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
			fsm_unit_move_process(delta)
	## ACTION SELECT
		CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
			fsm_unit_action_select_process(delta)
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
			fsm_support_action_inventory_process(delta)
		CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION_TARGETTING:
			fsm_support_action_targetting(delta)
		CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION:
			pass
	## SHOVE
		CombatMapConstants.PLAYER_STATE.UNIT_SHOVE_ACTION_TARGET:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_SHOVE_ACTION:
			pass
	## Combat
		CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_INVENTORY:
			fsm_attack_action_inventory_process(delta)
		CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_TARGETTING:
			fsm_unit_combat_action_targetting(delta)
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
func unit_action_selection_handler(action:String):
	match action:
		"Attack":
			# Create the apprioriate UI
			# Move the unit to the correct state
			combat.game_ui.destory_active_ui_node()
			_interactable_tiles.clear()
			_interactable_tiles = grid.get_range_DFS(combat.get_current_combatant().unit.inventory.get_max_attack_range(),combat.get_current_combatant().move_position, 0, false)
			targetting_resource.clear()
			var grid_analysis : CombatMapGridAnalysis = grid.get_analysis_on_tiles(_interactable_tiles)
			targetting_resource.initalize(combat.get_current_combatant().move_position, grid_analysis.get_allegience_unit_indexes(Constants.FACTION.ENEMIES), targetting_resource.create_target_methods_weapon(combat.get_current_combatant().unit))
			var action_menu_inventory : Array[UnitInventorySlotData] = targetting_resource.generate_unit_inventory_slot_data(combat.get_current_combatant().unit)
			_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
			combat.game_ui.create_attack_action_inventory(combat.get_current_combatant(), action_menu_inventory)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_INVENTORY)
	match action:
		"Support":
			# Create the apprioriate UI
			# Move the unit to the correct state
			combat.game_ui.destory_active_ui_node()
			_interactable_tiles.clear()
			_interactable_tiles = grid.get_range_DFS(combat.get_current_combatant().unit.inventory.get_max_attack_range(),combat.get_current_combatant().move_position, 0, false)
			targetting_resource.clear()
			targetting_resource.initalize(combat.get_current_combatant().move_position, grid.get_analysis_on_tiles(_interactable_tiles).get_allegience_unit_indexes(Constants.FACTION.PLAYERS),targetting_resource.create_target_methods_support(combat.get_current_combatant().unit))
			var action_menu_inventory : Array[UnitInventorySlotData] = targetting_resource.generate_unit_inventory_slot_data(combat.get_current_combatant().unit)
			_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
			combat.game_ui.create_support_action_inventory(combat.get_current_combatant(), action_menu_inventory)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION_INVENTORY)
	match action:
		"Skill":
			pass
	match action:
		"Shove":
			pass
	match action:
		"Rescue":
			pass
	match action:
		"Interact":
			pass
	match action:
		"Wait":
			combat.game_ui.destory_active_ui_node()
			wait_action(combat.get_current_combatant())
	match action:
		"Cancel":
			combat.game_ui.destory_active_ui_node()
			fsm_unit_action_cancel()


#Support
func fsm_support_action_inventory_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_cancel"):
			var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
			if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
				combat.game_ui.destory_active_ui_node()
				var actions :Array[String]  = get_available_unit_actions_NEW(combat.get_current_combatant())
				combat.game_ui.create_unit_action_container(actions)
				update_current_tile(move_tile)
				revert_player_state()

func fsm_support_action_inventory_confirm(selected_item : ItemDefinition):
	# equip selected item and call menu needed to progress flow
	combat.get_current_combatant().equip(selected_item)
	combat.game_ui.destory_active_ui_node()
	# destroy the old menu
	targetting_resource.update_dynamic_maps_new_method(combat.get_current_combatant().get_equipped())
	target_tile = targetting_resource.current_target_positon
	update_current_tile(target_tile)
	camera.set_focus_target(grid.map_to_position(target_tile))
	camera.set_mode(camera.CAMERA_MODE.FOCUS)
	selector.play("combat_targetting")
	support_exchange_info = combat.combatExchange.generate_support_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
	if targetting_resource._available_methods_at_target.size() > 1:
		combat.game_ui.create_support_action_exchange_preview(support_exchange_info, true)
	else:
		combat.game_ui.create_support_action_exchange_preview(support_exchange_info)
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION_TARGETTING)
	
func fsm_support_action_targetting(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			#Destroy old UI
			combat.game_ui.destory_active_ui_node()
			#Finalize the move
			confirm_unit_move(combat.get_current_combatant())
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION)
			await combat.perform_support(combat.get_current_combatant(), grid.get_combat_unit(target_tile), support_exchange_info)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
			targetting_resource.clear()
		if Input.is_action_just_pressed("ui_cancel"):
			var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
			if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_INVENTORY:
				combat.game_ui.destory_active_ui_node()
				_interactable_tiles.clear()
				_interactable_tiles = grid.get_range_DFS(combat.get_current_combatant().unit.inventory.get_max_attack_range(),combat.get_current_combatant().move_position, 0, false)
				targetting_resource.clear()
				targetting_resource.initalize(combat.get_current_combatant().move_position, grid.get_analysis_on_tiles(_interactable_tiles).get_allegience_unit_indexes(Constants.FACTION.ENEMIES),targetting_resource.create_target_methods_weapon(combat.get_current_combatant().unit))
				var action_menu_inventory : Array[UnitInventorySlotData] = targetting_resource.generate_unit_inventory_slot_data(combat.get_current_combatant().unit)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
				combat.game_ui.create_support_action_inventory(combat.get_current_combatant(), action_menu_inventory)
				revert_player_state()
				update_current_tile(move_tile)
		if Input.is_action_just_pressed("right_bumper"):
			if targetting_resource._available_methods_at_target.size() > 1:
				targetting_resource.next_target_method()
				combat.get_current_combatant().equip(targetting_resource.current_method)
				support_exchange_info = combat.combatExchange.generate_support_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_support_action_exchange_preview(support_exchange_info, true)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
		if Input.is_action_just_pressed("left_bumper"):
			#new weapon if applicable
			if targetting_resource._available_methods_at_target.size() > 1:
				targetting_resource.previous_target_method()
				combat.get_current_combatant().equip(targetting_resource.current_method)
				support_exchange_info = combat.combatExchange.generate_support_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_support_action_exchange_preview(support_exchange_info, true)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
		if Input.is_action_just_pressed("ui_left"):
			if targetting_resource._available_targets_with_method.size() > 1:
				targetting_resource.previous_target()
				target_tile = targetting_resource.current_target_positon
				update_current_tile(target_tile)
				camera.set_focus_target(grid.map_to_position(target_tile))
				support_exchange_info = combat.combatExchange.generate_combat_support_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_weapon_attack_action_combat_exchange_preview(exchange_info, true)
		if Input.is_action_just_pressed("ui_right"):
			if targetting_resource._available_targets_with_method.size() > 1:
				targetting_resource.next_target()
				target_tile = targetting_resource.current_target_positon
				update_current_tile(target_tile)
				camera.set_focus_target(grid.map_to_position(target_tile))
				support_exchange_info = combat.combatExchange.generate_combat_support_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_weapon_attack_action_combat_exchange_preview(exchange_info, true)

func fsm_support_action_inventory_confirm_new_hover(item:ItemDefinition):
	_weapon_attackable_tiles = populate_tiles_for_weapon(item.attack_range,combat.get_current_combatant().move_position)


#Attack 
func fsm_attack_action_inventory_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_cancel"):
			var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
			if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
				combat.game_ui.destory_active_ui_node()
				var actions :Array[String]  = get_available_unit_actions_NEW(combat.get_current_combatant())
				combat.game_ui.create_unit_action_container(actions)
				update_current_tile(move_tile)
				revert_player_state()

func fsm_attack_action_inventory_confirm(selected_item : ItemDefinition):
	# equip selected item and call menu needed to progress flow
	combat.get_current_combatant().equip(selected_item)
	combat.game_ui.destory_active_ui_node()
	# destroy the old menu
	targetting_resource.update_dynamic_maps_new_method(combat.get_current_combatant().get_equipped())
	target_tile = targetting_resource.current_target_positon
	update_current_tile(target_tile)
	camera.set_focus_target(grid.map_to_position(target_tile))
	camera.set_mode(camera.CAMERA_MODE.FOCUS)
	selector.play("combat_targetting")
	exchange_info = combat.combatExchange.generate_combat_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
	if targetting_resource._available_methods_at_target.size() > 1:
		combat.game_ui.create_attack_action_combat_exchange_preview(exchange_info, true)
	else:
		combat.game_ui.create_attack_action_combat_exchange_preview(exchange_info)
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_TARGETTING)
	
func fsm_unit_combat_action_targetting(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			combat.game_ui.destory_active_ui_node()
			confirm_unit_move(combat.get_current_combatant())
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION)
			await combat.perform_attack(combat.get_current_combatant(), grid.get_combat_unit(target_tile), exchange_info)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
			targetting_resource.clear()
			#Enact combat exchange
			pass
		if Input.is_action_just_pressed("ui_cancel"):
			var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
			if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_INVENTORY:
				combat.game_ui.destory_active_ui_node()
				_interactable_tiles.clear()
				_interactable_tiles = grid.get_range_DFS(combat.get_current_combatant().unit.inventory.get_max_attack_range(),combat.get_current_combatant().move_position, 0, false)
				targetting_resource.clear()
				targetting_resource.initalize(combat.get_current_combatant().move_position, grid.get_analysis_on_tiles(_interactable_tiles).get_allegience_unit_indexes(Constants.FACTION.ENEMIES),targetting_resource.create_target_methods_weapon(combat.get_current_combatant().unit))
				var action_menu_inventory : Array[UnitInventorySlotData] = targetting_resource.generate_unit_inventory_slot_data(combat.get_current_combatant().unit)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
				combat.game_ui.create_attack_action_inventory(combat.get_current_combatant(), action_menu_inventory)
				revert_player_state()
				update_current_tile(move_tile)
		if Input.is_action_just_pressed("right_bumper"):
			if targetting_resource._available_methods_at_target.size() > 1:
				targetting_resource.next_target_method()
				combat.get_current_combatant().equip(targetting_resource.current_method)
				exchange_info = combat.combatExchange.generate_combat_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_weapon_attack_action_combat_exchange_preview(exchange_info, true)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
		if Input.is_action_just_pressed("left_bumper"):
			#new weapon if applicable
			if targetting_resource._available_methods_at_target.size() > 1:
				targetting_resource.previous_target_method()
				combat.get_current_combatant().equip(targetting_resource.current_method)
				exchange_info = combat.combatExchange.generate_combat_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_weapon_attack_action_combat_exchange_preview(exchange_info, true)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
		if Input.is_action_just_pressed("ui_left"):
			if targetting_resource._available_targets_with_method.size() > 1:
				targetting_resource.previous_target()
				target_tile = targetting_resource.current_target_positon
				update_current_tile(target_tile)
				camera.set_focus_target(grid.map_to_position(target_tile))
				exchange_info = combat.combatExchange.generate_combat_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_weapon_attack_action_combat_exchange_preview(exchange_info, true)
		if Input.is_action_just_pressed("ui_right"):
			if targetting_resource._available_targets_with_method.size() > 1:
				targetting_resource.next_target()
				target_tile = targetting_resource.current_target_positon
				update_current_tile(target_tile)
				camera.set_focus_target(grid.map_to_position(target_tile))
				var exchange_info = combat.combatExchange.generate_combat_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_weapon_attack_action_combat_exchange_preview(exchange_info, true)

func fsm_attack_action_inventory_confirm_new_hover(item:ItemDefinition):
	_weapon_attackable_tiles = populate_tiles_for_weapon(item.attack_range,combat.get_current_combatant().move_position)
#Wait
func wait_action(cu: CombatUnit):
	combat.get_current_combatant().turn_taken = true
	confirm_unit_move(cu)
	if combat.get_current_combatant().alive:
		combat.get_current_combatant().map_display.update_values()
		update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
