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
const ATTACKABLE_TILE_TEXTURE = preload("res://resources/sprites/grid/attackable_tile.png")
const ALLY_SPAWN_TILE_TEXTURE = preload("uid://bg1eu6cpquuv1")
const MOVEABLE_TILE_TEXTURE = preload("res://resources/sprites/grid/movable_tile.png")

#Movement
const MOVEMENT_SPEED = 96

##SIGNALS
signal movement_changed(movement: int)
signal finished_move(position: Vector2i)
signal target_selection_started()
signal target_selection_finished()
signal tile_info_updated(tile : CombatMapTile, unit: CombatUnit)

signal reinforcement_phase_completed()

##State Machine
#@export var seed : int
#var turn_count : int # moved to combat
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
var background_tile_map : TileMapLayer
var active_tile_map : TileMapLayer
var grid: CombatMapGrid
var camera: CombatMapCamera

## attack range manager
var rangeManager: CombatUnitRangeManager
var show_all_enemy_range : bool = false

var current_tile : Vector2i # Where the cursor currently is
var selected_tile := Vector2i(-1,-1) # What we first selected (Most likely the tile containing the unit we have selected)
var target_tile : Vector2i # Our First Target
var move_tile : Vector2i # the tile we moved to

## Selector/Cursor
@export var selector : CombatMapSelector

##Player Interaction Variables
var paused = false


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
var _item_selected: bool

#AI Variables
var _in_ai_process: bool = false
var _enemy_units_turn_taken: bool = false


func _ready():
	##Load Seed to ensure consistent runs
	#seed(seed)
	##Configure FSM States
	#out_of_bounds_map = get_node("../Terrain/Background/OutOfBoundsBackgroundTiles")
	background_tile_map = get_node("../Terrain/BackgroundTiles")
	active_tile_map = get_node("../Terrain/ActiveMapTerrain")
	game_state = CombatMapConstants.COMBAT_MAP_STATE.INITIALIZING
	previous_game_state = CombatMapConstants.COMBAT_MAP_STATE.INITIALIZING
	turn_phase = CombatMapConstants.TURN_PHASE.INITIALIZING
	previous_turn_phase = CombatMapConstants.TURN_PHASE.INITIALIZING
	player_state = CombatMapConstants.PLAYER_STATE.INITIALIZING
	##create variables needed for Combat Map
	camera = CombatMapCamera.new()
	grid = CombatMapGrid.new()
	##Assign created variables to create place in the scene tree
	grid.setup(background_tile_map, active_tile_map)
	self.add_child(grid)
	self.add_child(camera)
	rangeManager = CombatUnitRangeManager.new(grid)
	self.add_child(rangeManager)
	#Auto Wire combat signals for modularity
	combat.connect("perform_shove", perform_shove)
	combat.connect("combatant_added", combatant_added)
	combat.connect("combatant_died", combatant_died)
	combat.connect("combat_entity_added", entity_added)
	combat.connect("major_action_completed", _on_visual_combat_major_action_completed)
	combat.connect("minor_action_completed", _on_visual_combat_minor_action_completed)
	combat.connect("turn_advanced", advance_turn)
	combat.connect("entity_processing", await_entity_resolution)
	await combat.ready
	combat.set_game_grid(grid)
	combat.populate()
	# Init & Populate dynamically created nodes
	await camera.init()
	#await combat.load_entities()
	# Prepare to transition to player turn and handle player input
	await combat.game_ui.ready
	if combat.is_tutorial:
		await combat.game_ui.tutorial_panel.tutorial_completed
	#autoCursor()
	##Set the correct states to begin FSM flow
	rangeManager.update_output_arrays()
	update_current_tile(combat.ally_spawn_tiles.front())
	if !combat.playerOverworldData.battle_prep_complete:
		update_game_state(CombatMapConstants.COMBAT_MAP_STATE.BATTLE_PREPARATION)
		update_player_state(CombatMapConstants.PLAYER_STATE.PREP_MENU)
	#Show Prep Screen
		##Start Music
		if combat.is_boss_level:
			AudioManager.play_music("battle_prep_theme_boss")
		else:
			AudioManager.play_music("battle_prep_theme")
	else:
		begin_battle()
	#begin_battle() ## THIS WILL BE CHANGED TO A SIGNAL IN THE PREP SCREEN

#process called on frame
func _process(delta):
	if not paused:
		queue_redraw()
		if (game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN or game_state == CombatMapConstants.COMBAT_MAP_STATE.AI_TURN):
			if(turn_phase == CombatMapConstants.TURN_PHASE.INITIALIZING):
				# initializing UI method
				update_turn_phase(CombatMapConstants.TURN_PHASE.BEGINNING_PHASE)
			elif(turn_phase == Constants.TURN_PHASE.BEGINNING_PHASE):
				beginning_phase_processing()
			elif turn_phase == CombatMapConstants.TURN_PHASE.BEGINNING_PHASE_PROCESS:
				pass
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
					update_game_state(CombatMapConstants.COMBAT_MAP_STATE.TURN_TRANSITION)
				elif game_state == CombatMapConstants.COMBAT_MAP_STATE.AI_TURN :
					print("Enemy Ended Turn")
					_in_ai_process = false
					_enemy_units_turn_taken = false
					print("Triggered Reinforcements")
					trigger_reinforcements()
		elif(game_state == CombatMapConstants.COMBAT_MAP_STATE.BATTLE_PREPARATION):
			player_prep_process(delta)
		elif(game_state == CombatMapConstants.COMBAT_MAP_STATE.REINFORCEMENT):
			pass
		elif(game_state == CombatMapConstants.COMBAT_MAP_STATE.TURN_TRANSITION):
			#All players have completed their turns, and order resets
			if turn_order_index == turn_order.size() - 1:
				combat.current_turn += 1
			progress_turn_order()
			update_turn_phase(CombatMapConstants.TURN_PHASE.BEGINNING_PHASE)
		elif game_state == CombatMapConstants.COMBAT_MAP_STATE.PROCESSING:
			if _arrived == false:
				process_unit_move(delta)
		elif (game_state == CombatMapConstants.COMBAT_MAP_STATE.VICTORY):
			# Do an end of the map clean up, regenerate item uses
			# Get all friendly items, and regenerate those where applicable
			pass

#draw the area
func _draw():
	draw_enemy_ranges()
	if(game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN):
		if(player_state == CombatMapConstants.PLAYER_STATE.UNIT_SELECT_HOVER):
			draw_hover_movement_ranges(_movable_tiles, true, _attackable_tiles,true)
		elif(player_state == CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT):
			draw_movement_ranges(_movable_tiles, true, _attackable_tiles,true)
			drawSelectedpath()
		if(player_state == CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_TARGETTING or player_state == CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_INVENTORY or player_state == CombatMapConstants.PLAYER_STATE.UNIT_DEMOLISH_ACTION_TARGETTING or player_state == CombatMapConstants.PLAYER_STATE.UNIT_DEMOLISH_ACTION_INVENTORY):
			draw_attack_range(_weapon_attackable_tiles)
	elif(game_state == CombatMapConstants.COMBAT_MAP_STATE.BATTLE_PREPARATION):
		#Draw the tiles for the player spaces
		for tile in combat.ally_spawn_tiles:
			draw_texture(ALLY_SPAWN_TILE_TEXTURE, Vector2(tile)  * Vector2(32, 32), Color.DARK_GOLDENROD)
		if(player_state == CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT_HOVER):
			draw_hover_movement_ranges(_movable_tiles, true, _attackable_tiles,true)


func beginning_phase_processing():
	update_turn_phase(CombatMapConstants.TURN_PHASE.BEGINNING_PHASE_PROCESS)
	#await ui.play_turn_banner(turn_owner)
	await process_terrain_effects()
	await process_special_effects()
	# await process_skill_effects()
	await clean_up() # --> remove debuffs / buffs, flush data structures
	if (game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN):
		await focus_player_camera_on_current_tile()
		update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
	update_turn_phase(CombatMapConstants.TURN_PHASE.MAIN_PHASE)

# used for to close the prep screen and start the map
func begin_battle():
	if combat.is_boss_level:
		AudioManager.play_music("player_theme_boss")
	else:
		AudioManager.play_music("player_theme")
	update_game_state(CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN)
	turn_owner = CombatMapConstants.FACTION.PLAYERS
	combat.game_ui.transition_in_animation()
	autoCursor()
	##Start Music
	

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
				# Cancelled the Unit's Move
				if(player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT):
					# Return cursor
					move_cursor(combat.get_current_combatant().map_position)
					grid.combat_unit_moved(combat.get_current_combatant().move_position,combat.get_current_combatant().map_position)
					_camera_follow_move = false
					revert_player_state()
				# Move Flow
				elif(player_state == CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT):
					combat.get_current_combatant().update_move_tile(grid.get_map_tile(new_position))
					grid.combat_unit_moved(combat.get_current_combatant().map_position,combat.get_current_combatant().move_position)
					var actions :Array[String]  = get_available_unit_actions(combat.get_current_combatant())
					combat.game_ui.create_unit_action_container(actions)
					update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT)
			else: # AI Units
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
	#progress_turn_order()


func progress_turn_order():
	# First advance the turn for current owner
	combat.advance_turn(turn_order[turn_order_index])
	# Get next person in turn order
	turn_order_index = CustomUtilityLibrary.array_next_index_with_loop(turn_order, turn_order_index)
	turn_owner = turn_order[turn_order_index]
	if turn_owner in player_factions:
		update_game_state(CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN)
		combat.game_ui.display_turn_transition_scene(CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN)
		#PLAYER MUSIC
		if combat.is_boss_level:
			AudioManager.play_music("player_theme_boss")
		else:
			AudioManager.play_music("player_theme")
	else: 
		update_game_state(CombatMapConstants.COMBAT_MAP_STATE.AI_TURN)
		combat.game_ui.display_turn_transition_scene(CombatMapConstants.COMBAT_MAP_STATE.AI_TURN)
		if combat.is_boss_level:
			AudioManager.play_music("enemy_theme_boss")
		else:
			AudioManager.play_music("enemy_theme")

func combatant_added(combatant : CombatUnit):
	grid.set_combat_unit(combatant, combatant.map_position)
	if combatant.allegience != 0:
		rangeManager.add_unit(combatant)
	rangeManager.update_effected_entries([combatant.map_position])
	rangeManager.update_output_arrays()

func entity_added(cme:CombatEntity):
	grid.set_entity(cme, cme.map_position)
	rangeManager.update_effected_entries([cme.map_position])
	
func combatant_died(combatant: CombatUnit):
	if grid.get_combat_unit(combatant.map_position):
		grid.combat_unit_died(combatant.map_position)
	rangeManager.process_unit_die(combatant)
	if combatant.map_display:
		combatant.map_display.queue_free()

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
	pass

#Draws a units move and attack ranges
func draw_movement_ranges(move_range:Array[Vector2i], draw_move_range:bool, attack_range:Array[Vector2i], draw_attack_range:bool):
	var move_range_color = Color.BLUE
	var attack_range_color = Color.CRIMSON
	if (draw_move_range) :
		for tile in move_range :
			draw_texture(MOVEABLE_TILE_TEXTURE, Vector2(tile)  * Vector2(32, 32), move_range_color)
	if (draw_attack_range) :
		for tile in attack_range :
			if(!move_range.has(tile) or !draw_move_range) : 
				draw_texture(ATTACKABLE_TILE_TEXTURE, Vector2(tile)  * Vector2(32, 32), attack_range_color)

func draw_hover_movement_ranges(move_range:Array[Vector2i], draw_move_range:bool, attack_range:Array[Vector2i], draw_attack_range:bool):
	var move_range_color = Color(Color.BLUE,.5)
	var attack_range_color = Color(Color.CRIMSON,.5)
	if (draw_move_range) :
		for tile in move_range :
			draw_texture(MOVEABLE_TILE_TEXTURE, Vector2(tile)  * Vector2(32, 32), move_range_color)
	if (draw_attack_range) :
		for tile in attack_range :
			if(!move_range.has(tile) or !draw_move_range) : 
				draw_texture(ATTACKABLE_TILE_TEXTURE, Vector2(tile)  * Vector2(32, 32), attack_range_color)

func draw_attack_range(attack_range:Array[Vector2i]):
	for tile in attack_range : 
			draw_texture(ATTACKABLE_TILE_TEXTURE, Vector2(tile)  * Vector2(32, 32), Color(Color.CRIMSON, .5))

func draw_enemy_ranges():
	if show_all_enemy_range:
		for tile in rangeManager.enemy_range_tiles:
			draw_texture(ATTACKABLE_TILE_TEXTURE, Vector2(tile)  * Vector2(32, 32), Color(Color.CRIMSON, .35))
	else:
		for tile in rangeManager.selected_unit_range_tiles:
			draw_texture(ATTACKABLE_TILE_TEXTURE, Vector2(tile)  * Vector2(32, 32), Color(Color.CRIMSON, .35))

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


##
# Gets potential units to target
#
func get_potential_targets(cu : CombatUnit, range: Array[int] = []) -> Array[Vector2i]:
	var range_list :Array[int] = []
	if range.is_empty():
		range_list = cu.unit.get_attackable_ranges()
	else:
		range_list = range.duplicate()
	var attackable_tiles : Array[Vector2i]
	var response : Array[Vector2i]
	if range_list.is_empty() : ##There is no attack range
		return response
	attackable_tiles = get_attackable_tiles(range_list, cu)
	_action_tiles = attackable_tiles.duplicate()
	for tile in attackable_tiles :
		if grid.get_combat_unit(tile):
			if(grid.get_combat_unit(tile).allegience != cu.allegience) :
				response.append(tile)
	return response

##
# Gets potential entities in target combat_unit's range
#
func get_potential_entity_targets(cu : CombatUnit, range: Array[int] = []) -> Array[Vector2i]:
	var range_list :Array[int] = []
	if range.is_empty():
		range_list = cu.unit.get_attackable_ranges()
	else:
		range_list = range.duplicate()
	var attackable_tiles : Array[Vector2i]
	var response : Array[Vector2i]
	if range_list.is_empty() : ##There is no attack range
		return response
	attackable_tiles = get_attackable_tiles(range_list, cu)
	_action_tiles = attackable_tiles.duplicate()
	for tile in attackable_tiles :
		if grid.get_entity(tile):
			if grid.get_entity(tile).interaction_type in CombatEntityConstants.targetable_entity_types:
				if tile not in response:
					response.append(tile)
	return response


func get_potential_ally_targets(cu : CombatUnit, range: int)-> Array[CombatUnit]:
	var targetable_tiles : Array[Vector2i]
	var response : Array[CombatUnit]
	targetable_tiles = get_attackable_tiles([range], cu)
	_action_tiles = targetable_tiles.duplicate()
	for tile in targetable_tiles :
		if grid.get_combat_unit(tile) :
			if(grid.get_combat_unit(tile).allegience == cu.allegience and grid.get_combat_unit(tile) != cu) :
				response.append(grid.get_combat_unit(tile))
	return response

func get_potential_support_targets(cu : CombatUnit, range: Array[int] = []) -> Array[CombatUnit]:
	var response : Array[CombatUnit]
	var support_map : Dictionary
	support_map = cu.unit.inventory.get_available_support_ranges()
	_action_tiles.clear()
	for key in support_map.keys():
		if key == WeaponDefinition.SUPPORT_TYPES.HEAL:
			var healable_tiles = get_attackable_tiles(support_map[key], cu)
			CustomUtilityLibrary.append_array_unique(_action_tiles,healable_tiles.duplicate())
			for tile in healable_tiles :
				if grid.get_combat_unit(tile) :
					var target_tile_unit : CombatUnit = grid.get_combat_unit(tile)
					if(target_tile_unit.allegience == cu.allegience and target_tile_unit != cu) :
						if target_tile_unit.current_hp < target_tile_unit.get_max_hp():
							response.append(grid.get_combat_unit(tile))
	return response

func get_potential_support_targets_coordinates(cu : CombatUnit, range: Array[int] = []) -> Array[Vector2i]:
	var response : Array[Vector2i]
	var support_map : Dictionary
	support_map = cu.unit.inventory.get_available_support_ranges()
	_action_tiles.clear()
	for key in support_map.keys():
		if key == WeaponDefinition.SUPPORT_TYPES.HEAL:
			var healable_tiles = get_attackable_tiles(support_map[key], cu)
			CustomUtilityLibrary.append_array_unique(_action_tiles,healable_tiles.duplicate())
			for tile in healable_tiles :
				if grid.get_combat_unit(tile) :
					var target_tile_unit : CombatUnit = grid.get_combat_unit(tile)
					if(target_tile_unit.allegience == cu.allegience and target_tile_unit != cu) :
						if target_tile_unit.current_hp < target_tile_unit.get_max_hp():
							response.append(tile)
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

func interact_action_available(cu:CombatUnit)-> bool:
	var current_tile = cu.move_position
	var current_tile_ent : CombatEntity = grid.get_entity(current_tile)
	if current_tile_ent != null:
		if current_tile_ent.interaction_type == CombatEntityConstants.ENTITY_TYPE.LEVER or current_tile_ent.interaction_type == CombatEntityConstants.ENTITY_TYPE.SEARCH:
			return true
		elif current_tile_ent.interaction_type == CombatEntityConstants.ENTITY_TYPE.CHEST:
			if cu.unit.inventory.has_item_with_any_db_key(CombatEntityConstants.valid_chest_unlock_item_db_keys):
				return true
	var reachable_tiles = grid.get_range_DFS(1, cu.move_position)
	for tile in reachable_tiles:
		var tile_entity = grid.get_entity(tile)
		if  tile_entity != null:
			if tile_entity.interaction_type == CombatEntityConstants.ENTITY_TYPE.DOOR:
				if cu.unit.inventory.has_item_with_any_db_key(CombatEntityConstants.valid_door_unlock_item_db_keys):
					return true
	return false

func get_interactable_entity_positions(cu:CombatUnit, targetable_entity_positions: Array[Vector2i])-> Array[Vector2i]:
	var _arr :Array[Vector2i] = []
	for entity_position in targetable_entity_positions:
		var entity = grid.get_entity(entity_position)
		if entity_position == cu.move_position:
			if entity.interaction_type == CombatEntityConstants.ENTITY_TYPE.LEVER or entity.interaction_type == CombatEntityConstants.ENTITY_TYPE.SEARCH:
				_arr.append(entity_position)
			elif entity.interaction_type == CombatEntityConstants.ENTITY_TYPE.CHEST:
				if cu.unit.inventory.has_item_with_any_db_key(CombatEntityConstants.valid_chest_unlock_item_db_keys):
					_arr.append(entity_position)
		else:
			if entity.interaction_type == CombatEntityConstants.ENTITY_TYPE.DOOR:
				if cu.unit.inventory.has_item_with_any_db_key(CombatEntityConstants.valid_door_unlock_item_db_keys):
					_arr.append(entity_position)
	return _arr

func get_combat_entity_positions(cu:CombatUnit, targetable_entity_positions: Array[Vector2i])-> Array[Vector2i]:
	var _arr :Array[Vector2i] = []
	for entity_position in targetable_entity_positions:
		var entity = grid.get_entity(entity_position)
		if entity.interaction_type in CombatEntityConstants.targetable_entity_types:
			_arr.append(entity_position)
	return _arr

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
	if not range_list.is_empty():
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
		if combat_unit not in combat.dead_units:
			if (combat_unit.allegience == Constants.FACTION.PLAYERS and game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN) or (combat_unit.allegience == Constants.FACTION.ENEMIES and game_state == CombatMapConstants.COMBAT_MAP_STATE.AI_TURN):
				if grid.get_terrain(combat_unit.map_position): 
					var target_terrain = grid.get_terrain(combat_unit.map_position)
#					if target_terrain.active_effect_phases == turn_phase:
					if target_terrain.effect != Terrain.TERRAIN_EFFECTS.NONE:
						if target_terrain.effect == Terrain.TERRAIN_EFFECTS.HEAL:
							if combat_unit.current_hp < combat_unit.get_max_hp():
								if target_terrain.effect_scaling == Terrain.EFFECT_SCALING.PERCENTAGE:
									combat.heal_unit(combat_unit, floori(combat_unit.get_max_hp() * target_terrain.effect_weight /100))
								else:
									#print("HEALED UNIT : " + combat_unit.unit.name)
									combat.heal_unit(combat_unit, target_terrain.effect_weight)

func process_special_effects():
	var _special_effect_resource = SpecialEffectResource.new()
	for combat_unit in combat.combatants:
		if combat_unit not in combat.dead_units:
			if (combat_unit.allegience == Constants.FACTION.PLAYERS and game_state == CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN) or (combat_unit.allegience == Constants.FACTION.ENEMIES and game_state == CombatMapConstants.COMBAT_MAP_STATE.AI_TURN):
				var applicable_specials : Array[SpecialEffect] = combat_unit.unit.inventory.get_all_specials_from_inventory_and_equipped()
				if not applicable_specials.is_empty():
					# BEGINNING OF TURN HEAL
					if combat_unit.current_hp < combat_unit.get_max_hp():
						var heal_on_begin_specials : Array[SpecialEffect] = _special_effect_resource.get_all_special_effects_with_type(SpecialEffect.SPECIAL_EFFECT.HEAL_ON_TURN_BEGIN, applicable_specials)
						if not heal_on_begin_specials.is_empty():
							await combat.heal_unit(combat_unit,_special_effect_resource.calculate_aggregate_effect(heal_on_begin_specials, combat_unit.get_max_hp()))

func get_available_unit_actions(cu:CombatUnit) -> Array[String]: # TO BE OPTIMIZED
	#get maximum actionable distance (ex weapons that have far atk)
	#get actionable tiles
	#get a map of units w/ ranges from the map
	var action_array : Array[String] = []
	if cu.minor_action_taken == false:
		if not get_potential_ally_targets(cu, 1).is_empty():
			action_array.push_front("Trade")
	if not cu.unit.inventory.is_empty():
		action_array.append("Item")
	if cu.major_action_taken == false:
		if not get_potential_shove_targets(cu).is_empty():
			action_array.push_front("Shove")
		if interact_action_available(cu):
			action_array.push_front("Interact")
		if not get_potential_entity_targets(cu).is_empty():
			action_array.push_front("Demolish")
		if not get_potential_support_targets(cu).is_empty() and cu.unit.usable_weapon_types.has(ItemConstants.WEAPON_TYPE.STAFF): # THIS NEEDS TO BE UPDATED TO ACCOUNT FOR ALL SUPPORT WEAPONS
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
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT)

## AI Methods


func ai_perform_selected_action(ai_action: aiAction):
	if ai_action.action_type == aiAction.ACTION_TYPES.COMBAT:
		await combat.ai_process_new(ai_action)
		combat.get_current_combatant().turn_taken = true
	elif ai_action.action_type == aiAction.ACTION_TYPES.COMBAT_AND_MOVE:
		# do the move 
		ai_action.owner.update_move_tile(grid.get_map_tile(ai_action.action_position))
		ai_move(ai_action.action_position, ai_action.owner)
		#called_move = true
		await finished_move
		await get_tree().create_timer(.1).timeout
		print("@ COMPLTED WAITING CALLING AI ACTION")
		#update the combat_unit info with the new tile info
		confirm_unit_move(ai_action.owner)
		await combat.ai_process_new(ai_action)
	elif ai_action.action_type == aiAction.ACTION_TYPES.MOVE:
		# do the move 
		ai_action.owner.update_move_tile(grid.get_map_tile(ai_action.action_position))
		ai_move(ai_action.action_position, ai_action.owner)
		#called_move = true
		await finished_move
		print("@ COMPLTED WAITING CALLING AI ACTION")
		#update the combat_unit info with the new tile info
		combat.get_current_combatant().turn_taken = true
		combat.get_current_combatant().minor_action_taken = true
		combat.get_current_combatant().update_display()
		confirm_unit_move(ai_action.owner)
	elif ai_action.action_type == aiAction.ACTION_TYPES.WAIT:
		pass
	else:
		print("CController : Recieved invalid unit action type")
		#combat.get_current_combatant().turn_taken = true
		#combat.get_current_combatant().minor_action_taken = true
		#combat.get_current_combatant().update_display()
		#confirm_unit_move(ai_action.owner)

func get_ai_unit_best_move(ai_unit: CombatUnit) -> aiAction:
	grid.update_astar_points(ai_unit)
	var current_position = grid.position_to_map(controlled_node.position)
	var moveable_tiles : Array[Vector2i] = [ai_unit.map_position]
	var actionable_tiles :Array[Vector2i]
	var actionable_range : Array[int]= ai_unit.unit.get_attackable_ranges()
	var action_tile_options: Array[Vector2i]
	var selected_action: aiAction = aiAction.new()
	selected_action.action_type = aiAction.ACTION_TYPES.WAIT
	selected_action.owner = ai_unit
	#Step 1 : Get all unit's moveable tiles
	if ai_unit.ai_type != Constants.UNIT_AI_TYPE.DEFEND_POINT:
		moveable_tiles = grid.get_range_DFS(ai_unit.unit.stats.movement,current_position, ai_unit.unit.movement_type, true, ai_unit.allegience)
	# Step 2 : Perform analysis to see what the highest value aiAction is at those moveable tiles (Check if we can do any "COMBAT" actions)
	for moveable_tile in moveable_tiles:
		if grid.is_map_position_available_for_unit_move(moveable_tile, ai_unit.unit.movement_type):
			var best_tile_action: aiAction = ai_get_best_move_at_tile(ai_unit, moveable_tile, current_position, actionable_range)
			if selected_action == null or selected_action.rating < best_tile_action.rating:
				if best_tile_action.action_type != aiAction.ACTION_TYPES.WAIT:
					selected_action = best_tile_action
	# Step 3: if the unit lacks an available "COMBAT" action, so we need to find the next best thing
	if selected_action != null:
		# Step 3.A ensure that the unit's ai type is not limiting its available acitons (in this case seeking a new high value action tile)
		if ai_unit.ai_type != Constants.UNIT_AI_TYPE.DEFEND_POINT and ai_unit.ai_type != Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE:
			if selected_action.action_type == aiAction.ACTION_TYPES.WAIT:
				# Create a list of tiles that a unit could perform high value actions on
				# Look for potential tiles for the "COMBAT" action
				for targetable_unit_index: int in combat.groups[Constants.FACTION.PLAYERS]:
					# populate the correct tiles based on the current unit's range to perform "COMBAT" actions
					for range in actionable_range:
						for tile in grid.get_tiles_at_range_new(range,combat.combatants[targetable_unit_index].map_position):
							if not grid.is_position_occupied(tile):
								if tile not in actionable_tiles:
									actionable_tiles.append(tile)
				# Step 3.B Assess our tiles to find the "closest" high value actionable tile
				var closest_action_tile
				var _astar_closest_distance = 999999
				var closest_tile_in_range_to_action_tile
				for tile in actionable_tiles:
					if grid.is_valid_tile(tile):
						var _astar_path = grid.get_id_path(current_position, tile, false)
						if _astar_path:
							var _astar_distance = grid.astar_path_distance(_astar_path)
							if _astar_distance < _astar_closest_distance and _astar_distance != null:
								closest_action_tile = tile
								_astar_closest_distance = _astar_distance
				# Step 3.C Get the "closest" movable tile to the "closest" high value action tile
				for tile in _movable_tiles:
					if closest_action_tile != null: 
						# Step 3.C.I Check if we can reach that target tile, (this may be redundant due to range checking in step 1)
						if not grid.get_point_weight_scale(closest_action_tile) > 999999:
							if closest_action_tile != Vector2i(current_position):
								if closest_action_tile in moveable_tiles:
									pass #The closest_action_tile is within moveable tiles, this should not fire here as it should be caught in Step 2 (above)
								else:
									var _astar_closest_move_tile_distance_to_action  = 99999
									for moveable_tile in moveable_tiles: 
										if grid.is_position_occupied(moveable_tile):
											pass 
											# We are discounting already occupied tiles for now
										else:
											if grid.is_valid_tile(moveable_tile):
												var _astar_path = grid.get_id_path(moveable_tile,closest_action_tile)
												if _astar_path:
													var _astar_distance = grid.astar_path_distance(_astar_path)
													if _astar_distance < _astar_closest_move_tile_distance_to_action and _astar_distance != null:
														closest_tile_in_range_to_action_tile = moveable_tile
														_astar_closest_move_tile_distance_to_action = _astar_distance
														var _current_ai_action : aiAction = aiAction.new() 
														_current_ai_action.owner = ai_unit
														_current_ai_action.action_position = moveable_tile
														_current_ai_action.distance_to_high_value_tile = _astar_closest_move_tile_distance_to_action
														_current_ai_action.action_type = aiAction.ACTION_TYPES.MOVE
														_current_ai_action.generate_move_action_rating(grid.get_terrain(moveable_tile).avoid)
														if selected_action == null or _current_ai_action.rating > selected_action.rating:
															selected_action = _current_ai_action
	return selected_action

##
## Updates the selected action's action_position to choose best action considering other calculated aiActions
##
func select_best_action_position(selected_move: aiAction, move_list:Array[aiAction]):
	if selected_move.action_positions.is_empty():
		return
	#make a map of tiles and the highest potential action rating on each tile
	var _positions_value_map : Dictionary[Vector2i, int] = {}
	# populate the map for each available position
	for position in selected_move.action_positions:
		_positions_value_map[position] = selected_move.rating
	# iterate through the other move list to see potential conflicts with the selected move's positions
	for next_ai_action: aiAction in move_list:
		if next_ai_action.action_type != aiAction.ACTION_TYPES.MOVE or aiAction.ACTION_TYPES.WAIT:
			if not next_ai_action.action_positions.is_empty():
				for next_ai_action_position in next_ai_action.action_positions:
						if _positions_value_map.has(next_ai_action_position):
							if selected_move.rating - next_ai_action.rating < _positions_value_map[next_ai_action_position]:
								_positions_value_map[next_ai_action_position] = selected_move.rating - next_ai_action.rating
			elif _positions_value_map.has(next_ai_action.action_position):
				if selected_move.rating - next_ai_action.rating < _positions_value_map[next_ai_action.action_position]:
					_positions_value_map[next_ai_action.action_position] = selected_move.rating - next_ai_action.rating
	
	# Find the tile with the best value from the positions value map
	var _highest_rated_positions_after_reductions : Array[Vector2i] = []
	for key_tile in _positions_value_map.keys():
		var entry = _positions_value_map[key_tile]
		if _highest_rated_positions_after_reductions.is_empty():
			_highest_rated_positions_after_reductions.append(key_tile)
		elif _positions_value_map[_highest_rated_positions_after_reductions.front()] < _positions_value_map[key_tile]:
			_highest_rated_positions_after_reductions.clear()
			_highest_rated_positions_after_reductions.append(key_tile)
		# if it is equal we add the value, if its less we clear the array and append the value
		elif _positions_value_map[_highest_rated_positions_after_reductions.front()] == _positions_value_map[key_tile]:
			_highest_rated_positions_after_reductions.append(key_tile)
	if _highest_rated_positions_after_reductions.size() > 1:
		# if the output list is larger than 1 entry we need to do terrain analysis on the tiles to see which is better
		var _terrain_best_action_list :  Dictionary[Vector2i, int] = {}
		for tile_position in _highest_rated_positions_after_reductions:
			_terrain_best_action_list[tile_position] = aiAction.calculate_terrain_rating(grid.get_terrain(tile_position))
		# check and see what is the best tile
		var _best_terrain_tile : Array[Vector2i] = []
		for terrain_tile_key in _terrain_best_action_list.keys():
			if _best_terrain_tile.is_empty():
				_best_terrain_tile.append(terrain_tile_key)
			elif _terrain_best_action_list[_best_terrain_tile.front()] < _terrain_best_action_list[terrain_tile_key]:
				_best_terrain_tile.clear()
				_best_terrain_tile.append(terrain_tile_key)
		# if the terrain analysis comes out as a draw pick a random tile
		if _best_terrain_tile.size() > 1:
			selected_move.action_position = _best_terrain_tile.pick_random()
		else:
			selected_move.action_position = _best_terrain_tile.front()
	else :
		selected_move.action_position = _highest_rated_positions_after_reductions.front()


#
# Calculates the highest value move at a particular tile
#
func ai_get_best_move_at_tile(ai_unit: CombatUnit, tile_position: Vector2i, current_position: Vector2i, attack_range: Array[int]) -> aiAction:
	var tile_best_action: aiAction = aiAction.new()
	tile_best_action.owner = ai_unit
	tile_best_action.action_type = aiAction.ACTION_TYPES.WAIT
	tile_best_action.rating = 0
	# Check for "COMBAT" action tiles
	for range in attack_range:
		for tile in grid.get_tiles_at_range_new(range,tile_position):
			# does target tile have a unit?
			if grid.get_combat_unit(tile) != null: 
				# is the unit hostile?
				if grid.get_combat_unit(tile).allegience == Constants.FACTION.PLAYERS:
					# Can we attack?
					if not ai_unit.unit.get_usable_weapons_at_range(range).is_empty():
						if grid.get_effective_terrain(grid.get_map_tile(tile)):
							# Gives us best "COMBAT" action
							var best_action_target : aiAction = combat.ai_get_best_attack_action(ai_unit, CustomUtilityLibrary.get_distance(tile, tile_position), grid.get_combat_unit(tile), grid.get_effective_terrain(grid.get_map_tile(tile)))
							best_action_target.owner = ai_unit
							best_action_target.target_position = tile
							best_action_target.action_position = tile_position
							# return the correct action type
							if tile_position == current_position:
								best_action_target.action_type = aiAction.ACTION_TYPES.COMBAT
							else :
								best_action_target.action_type = aiAction.ACTION_TYPES.COMBAT_AND_MOVE
							# Allow the unit to have multiple locations for the action if rating is equal
							if tile_best_action.rating == best_action_target.rating:
								if tile_best_action.action_positions.is_empty():
									tile_best_action.action_positions.append(tile_best_action.action_position)
								tile_best_action.action_positions.append(tile)
							elif tile_best_action.rating < best_action_target.rating:
								tile_best_action = best_action_target
	return tile_best_action

func ai_move(target_position: Vector2i, ai_unit: CombatUnit):
	print("@ AI MOVE CALLED @ : "+ str(target_position))
	var current_position = grid.position_to_map(controlled_node.position)
	_path = grid.find_path(target_position,current_position)
	move_on_path(target_position)

func ai_turn ():
	_in_ai_process = true
	var enemy_units  = combat.get_ai_units()
	var _enemy_action_list : Array[aiAction] = []
	var _number_of_units_to_process = enemy_units.size()
	#Assess all actions for best move, for the first time
	for unit :CombatUnit in enemy_units:
		print("Began AI processing unit : "+ unit.unit.name)
		set_controlled_combatant(unit)
		var _unit_best_action : aiAction = await get_ai_unit_best_move(unit)
		_enemy_action_list.append(_unit_best_action)
		#await combat.ai_process_new(unit, best_action)
	print("finished Processing Initial Action List")
	_enemy_action_list.sort_custom(CustomUtilityLibrary.sort_aiAction)
	# Now we process the best move
	var _effected_positions : Array[Vector2i] = []
	var _effected_units_arr : Array[CombatUnit] = []
	for unit_to_process in range(_number_of_units_to_process):
		_effected_positions.clear()
		_effected_units_arr.clear()
		var _target_move : aiAction = _enemy_action_list.pop_front()
		select_best_action_position(_target_move, _enemy_action_list)
		var _action_origin_position : Vector2i = _target_move.owner.map_position
		# do the action on the combat map
		set_controlled_combatant(_target_move.owner)
		await ai_perform_selected_action(_target_move)
		# Now see who has been effected by this move?
		_effected_positions.append(_action_origin_position)
		# Ensure positions to be processed for new AI calculations are unique to avoid re-calculations
		if not _effected_positions.has(_target_move.action_position):
			_effected_positions.append(_target_move.action_position)
		if not _effected_positions.has(_target_move.target_position):
			_effected_positions.append(_target_move.target_position)
	
		# Get units effected by these positions
		for effected_position in _effected_positions:
			if rangeManager.get_units_in_range_of_tile(effected_position) != null:
				for unit in rangeManager.get_units_in_range_of_tile(effected_position):
					if unit.turn_taken == false:
						if not _effected_units_arr.has(unit) and unit.alive and unit.allegience != Constants.FACTION.PLAYERS:
								_effected_units_arr.append(unit)

		# Remove these units from the _enemy_action_list, so it can be re-populated with new best move values (we are iterating backwards to avoid issues with removing elements)
		for _enemy_action_index in range(_enemy_action_list.size() -1, -1, -1):
			if _effected_units_arr.has(_enemy_action_list[_enemy_action_index].owner):
				_enemy_action_list.remove_at(_enemy_action_index)
		# re-calculate best moves for the effected units 
		for unit in _effected_units_arr:
			set_controlled_combatant(unit)
			var _unit_best_action : aiAction = await get_ai_unit_best_move(unit)
			_enemy_action_list.append(_unit_best_action)
		# sort and iterate
		_enemy_action_list.sort_custom(CustomUtilityLibrary.sort_aiAction)
	#Finish Up
	_enemy_units_turn_taken = true
	print("finished AI Turn")
	_in_ai_process = false

func populate_combatant_tile_ranges(combatant: CombatUnit):
	grid.update_astar_points(combatant)
	_movable_tiles.clear()
	_attackable_tiles.clear()
	if combatant.ai_type == CombatMapConstants.UNIT_AI_TYPE.DEFEND_POINT:
		_attackable_tiles = populate_tiles_for_weapon(combatant.unit.inventory.get_available_attack_ranges(), combatant.map_position)
	else :
		_movable_tiles = grid.get_range_DFS(combatant.unit.stats.movement, current_tile, combatant.unit.movement_type, true, combatant.allegience)
		var edge_array = grid.find_edges(_movable_tiles)
		_attackable_tiles = grid.get_range_multi_origin_DFS(combatant.unit.get_max_attack_range(), edge_array)

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
	#if combat_unit.map_position != combat_unit.move_position:
	var update_successful :bool = grid.combat_unit_moved(combat_unit.map_position,combat_unit.move_position)
	combat_unit.update_map_tile(grid.get_map_tile(combat_unit.move_position))
	rangeManager.update_effected_entries([combat_unit.map_position,combat_unit.move_position])
	rangeManager.update_combat_unit_range_data(combat_unit)


func trigger_reinforcements():
	update_game_state(CombatMapConstants.COMBAT_MAP_STATE.REINFORCEMENT)
	combat.check_reinforcement_spawn(combat.current_turn)
	await combat.reinforcement_check_completed
	
	update_game_state(CombatMapConstants.COMBAT_MAP_STATE.TURN_TRANSITION)

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

func move_camera(position: Vector2i):
	camera.centerCameraCenter(grid.map_to_position(position))
	await get_tree().create_timer(.2).timeout

func move_and_zoom_camera(position: Vector2i, zoom_target: Vector2):
	camera.centerCameraCenter(grid.map_to_position(position))
	camera.set_zoom_target(zoom_target)
	await get_tree().create_timer(.4).timeout
#
# Updates the selected tile to a new position, but ensures it is within the grid
#
func update_current_tile(position : Vector2i):
	if grid.is_valid_tile(position):
		AudioManager.play_sound_effect("move_tile")
		current_tile = position
		get_tile_info(position)
		selector.position = grid.map_to_position(current_tile)
		combat.game_ui._set_tile_info(grid.get_map_tile(current_tile), grid.get_combat_unit(current_tile))


#
# 
#
func perform_reinforcement_camera_adjustment(grid_position: Vector2i) -> bool:
	# Check if the grid position is open
	if grid.get_combat_unit(grid_position) == null:
		camera.set_focus_target(grid.map_to_position(grid_position))
		camera.set_mode(camera.CAMERA_MODE.FOCUS)
		return true
	return false 

func focus_player_camera_on_current_tile():
	if camera.focus_target != grid.map_to_position(current_tile): 
		camera.set_focus_target(grid.map_to_position(current_tile))
		camera.set_mode(camera.CAMERA_MODE.FOCUS)
		await get_tree().create_timer(1).timeout
		camera.set_mode(camera.CAMERA_MODE.FOLLOW)
## FSM METHODS

func fsm_unit_move_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			fsm_unit_move_confirm(delta)
		elif Input.is_action_just_pressed("ui_back"):
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
	#combat.game_ui.play_menu_confirm()
	AudioManager.play_sound_effect("unit_confirm")
	if _arrived == true:
		if current_tile in _movable_tiles:
		#If the unit is currently at a position and the player is selecting a different available position
			if current_tile != combat.get_current_combatant().map_position:
				if grid.is_map_position_available_for_unit_move(current_tile, combat.get_current_combatant().unit.movement_type):
						move_tile = current_tile
						move_player()
			else : 
				combat.get_current_combatant().update_move_tile(grid.get_map_tile(selected_tile))
				var actions :Array[String]  = get_available_unit_actions(combat.get_current_combatant())
				combat.game_ui.create_unit_action_container(actions)
				update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT)
#
# Called on cancel input during unit_move state
#
func fsm_unit_move_cancel(delta):
	_action_tiles.clear()
	combat.reset_all_effective_indicators()
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)

#
# Called in the unit_action select state, this cancels the player's previous move and returns the unit to its starting position (if it has moved)
#
func fsm_unit_action_cancel(delta = null):
	#combat.game_ui.play_menu_back()
	AudioManager.play_sound_effect("unit_return")
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
	if combat.get_available_units().is_empty():
		advance_turn()
		return
	if null != grid.get_combat_unit(current_tile):
		var selected_unit : CombatUnit = grid.get_combat_unit(current_tile)
		if selected_unit != null:
			if selected_unit.alive:
				combat.game_ui.display_unit_status()
				camera.set_footer_open(true)
				populate_combatant_tile_ranges(selected_unit)
				combat.update_effective_combat_displays(selected_unit)
				update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT_HOVER)
			return
	else :
		combat.reset_all_effective_indicators()
		combat.game_ui.hide_unit_status()
		camera.set_footer_open(false)
	if Input:
		if Input.is_action_just_pressed("ui_confirm") or Input.is_action_just_pressed("start_button"):
			combat.game_ui.create_combat_map_game_menu()
			update_player_state(CombatMapConstants.PLAYER_STATE.GAME_MENU)
		elif Input.is_action_just_pressed("combat_map_up"):
			update_current_tile(current_tile + Vector2i.UP)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		elif Input.is_action_just_pressed("combat_map_left"):
			update_current_tile(current_tile + Vector2i.LEFT)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		elif Input.is_action_just_pressed("combat_map_right"):
			update_current_tile(current_tile + Vector2i.RIGHT)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		elif Input.is_action_just_pressed("combat_map_down"):
			update_current_tile(current_tile + Vector2i.DOWN)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		elif Input.is_action_just_pressed("left_bumper") or Input.is_action_just_pressed("right_bumper"):
			update_current_tile(combat.get_first_available_unit().map_position)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		camera.SimpleFollow(delta)

func fsm_unit_select_hover_process(delta):
	if grid.get_combat_unit(current_tile) == null:
		update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		return
	# always keep the footer open
	if Input:
		var selected_unit : CombatUnit = grid.get_combat_unit(current_tile)
		if Input.is_action_just_pressed("ui_confirm"):
			#combat.game_ui.play_menu_confirm()
			AudioManager.play_sound_effect("unit_select")
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
				selected_unit.set_range_indicator(rangeManager.toggle_selected_unit(selected_unit))
				
				#pass 
		elif Input.is_action_just_pressed("details"):
			if selected_unit != null and selected_unit.alive:
				combat.game_ui.create_combat_unit_detail_panel(selected_unit)
				update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_DETAILS_SCREEN)
			#populate the detail info with the unit
			#create a faction unit traversal list
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_DETAILS_SCREEN)
		elif Input.is_action_just_pressed("right_bumper"):
			# allow the game to jump between units on the same faction
			update_current_tile(combat.get_next_unit(selected_unit, true).map_position)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		elif Input.is_action_just_pressed("left_bumper"):
			# allow the game to jump between units on the same
			update_current_tile(combat.get_next_unit(selected_unit, false).map_position)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		elif Input.is_action_just_pressed("start_button"):
			# To be implemented : combat map main menu
			pass
		elif Input.is_action_just_pressed("combat_map_up"):
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
			update_current_tile(current_tile + Vector2i.UP)
		elif Input.is_action_just_pressed("combat_map_left"):
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
			update_current_tile(current_tile + Vector2i.LEFT)
		elif Input.is_action_just_pressed("combat_map_right"):
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
			update_current_tile(current_tile + Vector2i.RIGHT)
		elif Input.is_action_just_pressed("combat_map_down"):
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
			update_current_tile(current_tile + Vector2i.DOWN)
		camera.SimpleFollow(delta)

func fsm_unit_details_screen_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_back"):
			combat.game_ui.destory_active_ui_node()
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		elif Input.is_action_just_pressed("right_bumper"):
			var next_unit : CombatUnit = combat.get_next_unit(grid.get_combat_unit(current_tile), true)
			update_current_tile(next_unit.map_position)
			combat.game_ui.update_combat_unit_detail_panel(next_unit)
			# update current tile position to match unit positon
			pass 
		elif Input.is_action_just_pressed("left_bumper"):
			# allow the game to jump between units on the same faction
			var next_unit : CombatUnit = combat.get_next_unit(grid.get_combat_unit(current_tile), false)
			update_current_tile(next_unit.map_position)
			combat.game_ui.update_combat_unit_detail_panel(next_unit)
			# get prev unit from faction
			# update current tile position to match unit positon
			pass
			
func fsm_unit_selected_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			fsm_unit_move_confirm(delta)
		if Input.is_action_just_pressed("ui_back"):
			_action_tiles.clear()
			combat.reset_all_effective_indicators()
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
	#draw the units current move path and ranges
	find_path(current_tile) 

func fsm_unit_action_select_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			#This should be handled by the UI pop-up
			pass
		if Input.is_action_just_pressed("ui_back"):
			if combat.get_current_combatant().minor_action_taken == false:
				combat.game_ui.destory_active_ui_node()
				fsm_unit_action_cancel(delta)

func fsm_game_menu_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_back"):
			fsm_game_menu_cancel()

func fsm_game_menu_cancel():
	combat.game_ui.destory_active_ui_node()
	revert_player_state()

func fsm_game_menu_end_turn():
	combat.game_ui.destory_active_ui_node()
	advance_turn()

func fsm_game_menu_main_menu():
	var main_menu = "res://Game Main Menu/main_menu.tscn"
	get_tree().change_scene_to_file(main_menu)

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
			fsm_game_menu_process(delta)
	## MOVEMENT
		CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT:
			fsm_unit_move_process(delta)
	## ACTION SELECT
		CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
			fsm_unit_action_select_process(delta)
	## INVENTORY
		CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY_ITEM_SELECTED:
			fsm_unit_inventory_item_selected_process(delta)
		CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY_ITEM_ACTION:
			pass
	## TRADE
		CombatMapConstants.PLAYER_STATE.UNIT_TRADE_ACTION_TARGETTING:
			fsm_trade_action_targetting(delta)
		CombatMapConstants.PLAYER_STATE.UNIT_TRADE_ACTION_INVENTORY:
			fsm_trade_action_inventory_process(delta)
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
	## Demolish
		CombatMapConstants.PLAYER_STATE.UNIT_DEMOLISH_ACTION_INVENTORY:
			fsm_demolish_action_inventory_process(delta)
		CombatMapConstants.PLAYER_STATE.UNIT_DEMOLISH_ACTION_TARGETTING:
			fsm_demolish_action_targetting(delta)
		CombatMapConstants.PLAYER_STATE.UNIT_DEMOLISH_ACTION:
			pass
	## Entity
		CombatMapConstants.PLAYER_STATE.UNIT_INTERACT_ACTION_TARGETTING:
			fsm_interact_targetting(delta)
		CombatMapConstants.PLAYER_STATE.UNIT_INTERACT_ACTION_INVENTORY:
			pass
		CombatMapConstants.PLAYER_STATE.UNIT_INTERACT_ACTION:
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
			_interactable_tiles = grid.get_range_DFS(combat.get_current_combatant().unit.get_max_attack_range(),combat.get_current_combatant().move_position,false, combat.get_current_combatant().allegience)
			targetting_resource.clear()
			var grid_analysis : CombatMapGridAnalysis = grid.get_analysis_on_tiles(_interactable_tiles)
			var target_positions : Array[Vector2i] = grid_analysis.get_allegience_unit_indexes(Constants.FACTION.ENEMIES)
			targetting_resource.initalize(combat.get_current_combatant().move_position, target_positions, targetting_resource.create_target_methods_weapon(combat.get_current_combatant().unit))
			var action_menu_inventory : Array[UnitInventorySlotData] = targetting_resource.generate_unit_inventory_slot_data(combat.get_current_combatant().unit)
			if combat.get_current_combatant().get_equipped() != null:
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
			combat.game_ui.create_attack_action_inventory(combat.get_current_combatant(), action_menu_inventory)
			combat.game_ui.hide_unit_status()
			camera.set_footer_open(false)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_INVENTORY)
		"Support":
			# Create the apprioriate UI
			# Move the unit to the correct state
			combat.game_ui.destory_active_ui_node()
			_interactable_tiles.clear()
			_interactable_tiles = grid.get_range_DFS(combat.get_current_combatant().unit.inventory.get_max_support_range(),combat.get_current_combatant().move_position, false, combat.get_current_combatant().allegience)
			targetting_resource.clear()
			targetting_resource.initalize(combat.get_current_combatant().move_position, get_potential_support_targets_coordinates(combat.get_current_combatant()),targetting_resource.create_target_methods_support(combat.get_current_combatant().unit))
			var action_menu_inventory : Array[UnitInventorySlotData] = targetting_resource.generate_unit_inventory_slot_data(combat.get_current_combatant().unit)
			_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
			combat.game_ui.create_support_action_inventory(combat.get_current_combatant(), action_menu_inventory)
			combat.game_ui.hide_unit_status()
			camera.set_footer_open(false)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION_INVENTORY)
		"Demolish":
			combat.game_ui.destory_active_ui_node()
			_interactable_tiles.clear()
			_interactable_tiles = grid.get_range_DFS(combat.get_current_combatant().unit.get_max_attack_range(),combat.get_current_combatant().move_position,false, combat.get_current_combatant().allegience)
			targetting_resource.clear()
			var grid_analysis : CombatMapGridAnalysis = grid.get_analysis_on_tiles(_interactable_tiles)
			var target_positions : Array[Vector2i] = get_combat_entity_positions(combat.get_current_combatant(), grid_analysis.get_targetable_entities())
			targetting_resource.initalize(combat.get_current_combatant().move_position, target_positions, targetting_resource.create_target_methods_weapon(combat.get_current_combatant().unit))
			var action_menu_inventory : Array[UnitInventorySlotData] = targetting_resource.generate_unit_inventory_slot_data(combat.get_current_combatant().unit)
			if combat.get_current_combatant().get_equipped() != null:
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
			combat.game_ui.create_demolish_action_inventory(combat.get_current_combatant(), action_menu_inventory)
			combat.game_ui.hide_unit_status()
			camera.set_footer_open(false)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_DEMOLISH_ACTION_INVENTORY)
		"Skill":
			pass
		"Trade":
			# Destroy old UI
			combat.game_ui.destory_active_ui_node()
			_interactable_tiles.clear()
			_interactable_tiles = grid.get_range_DFS(1,combat.get_current_combatant().move_position, false, combat.get_current_combatant().allegience)
			_interactable_tiles.erase(combat.get_current_combatant().move_position)
			var grid_analysis : CombatMapGridAnalysis = grid.get_analysis_on_tiles(_interactable_tiles)
			var target_positions : Array[Vector2i] = grid_analysis.get_allegience_unit_indexes(combat.get_current_combatant().allegience)
			target_tile = target_positions.front()
			targetting_resource.clear()
			targetting_resource.current_target_positon = target_tile
			targetting_resource._available_targets_with_method = target_positions
			update_current_tile(target_tile)
			camera.set_focus_target(grid.map_to_position(target_tile))
			selector.play("combat_targetting")
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_TRADE_ACTION_TARGETTING)
		"Item":
			#detroy the node
			combat.game_ui.destory_active_ui_node()
			#get the item info
			var unit_inventory_data : Array[UnitInventorySlotData] = combat.combat_unit_item_manager.generate_combat_unit_inventory_data(combat.get_current_combatant())
			#create the UI
			combat.game_ui.create_unit_item_action_inventory(combat.get_current_combatant(), unit_inventory_data)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION_INVENTORY)
			#update the state
		"Shove":
			pass
		"Rescue":
			pass
		"Interact":
			combat.game_ui.destory_active_ui_node()
			_interactable_tiles.clear()
			_interactable_tiles = grid.get_range_DFS(1,combat.get_current_combatant().move_position, false, combat.get_current_combatant().allegience)
			var grid_analysis : CombatMapGridAnalysis = grid.get_analysis_on_tiles(_interactable_tiles)
			var target_positions : Array[Vector2i] = grid_analysis.get_targetable_entities()
			target_positions =  get_interactable_entity_positions(combat.get_current_combatant(), target_positions)
			target_tile = target_positions.front()
			targetting_resource.clear()
			targetting_resource.current_target_positon = target_tile
			targetting_resource._available_targets_with_method = target_positions
			update_current_tile(target_tile)
			camera.set_focus_target(grid.map_to_position(target_tile))
			selector.play("combat_targetting")
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INTERACT_ACTION_TARGETTING)
		"Wait":
			combat.game_ui.destory_active_ui_node()
			wait_action(combat.get_current_combatant())
		"Cancel":
			combat.game_ui.destory_active_ui_node()
			fsm_unit_action_cancel()


#Support
func fsm_support_action_inventory_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_back"):
			fsm_support_action_inventory_cancel()

func fsm_support_action_inventory_cancel():
	var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
	if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
		combat.game_ui.destory_active_ui_node()
		var actions :Array[String]  = get_available_unit_actions(combat.get_current_combatant())
		combat.game_ui.create_unit_action_container(actions)
		combat.game_ui.display_unit_status()
		camera.set_footer_open(true)
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
			#confirm_unit_move(combat.get_current_combatant())
			combat.get_current_combatant().update_map_tile(grid.get_map_tile(combat.get_current_combatant().move_position))
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION)
			await combat.perform_support(combat.get_current_combatant(), grid.get_combat_unit(target_tile), support_exchange_info)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
			targetting_resource.clear()
		if Input.is_action_just_pressed("ui_back"):
			var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
			if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_SUPPORT_ACTION_INVENTORY:
				combat.game_ui.destory_active_ui_node()
				_interactable_tiles.clear()
				_interactable_tiles = grid.get_range_DFS(combat.get_current_combatant().unit.inventory.get_max_support_range(),combat.get_current_combatant().move_position, false, combat.get_current_combatant().allegience)
				targetting_resource.clear()
				targetting_resource.initalize(combat.get_current_combatant().move_position, get_potential_support_targets_coordinates(combat.get_current_combatant()),targetting_resource.create_target_methods_support(combat.get_current_combatant().unit))
				var action_menu_inventory : Array[UnitInventorySlotData] = targetting_resource.generate_unit_inventory_slot_data(combat.get_current_combatant().unit)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
				combat.game_ui.create_support_action_inventory(combat.get_current_combatant(), action_menu_inventory)
				revert_player_state()
				camera.set_mode(camera.CAMERA_MODE.FOLLOW)
				update_current_tile(move_tile)
		if Input.is_action_just_pressed("right_bumper"):
			if targetting_resource.method_switch_available():
				targetting_resource.next_target_method()
				combat.get_current_combatant().equip(targetting_resource.current_method)
				support_exchange_info = combat.combatExchange.generate_support_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_support_action_exchange_preview(support_exchange_info, true)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
		if Input.is_action_just_pressed("left_bumper"):
			#new weapon if applicable
			if targetting_resource.method_switch_available():
				targetting_resource.previous_target_method()
				combat.get_current_combatant().equip(targetting_resource.current_method)
				support_exchange_info = combat.combatExchange.generate_support_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_support_action_exchange_preview(support_exchange_info, true)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
		if Input.is_action_just_pressed("ui_left"):
			if targetting_resource.target_switch_available():
				targetting_resource.previous_target()
				target_tile = targetting_resource.current_target_positon
				update_current_tile(target_tile)
				camera.set_focus_target(grid.map_to_position(target_tile))
				support_exchange_info = combat.combatExchange.generate_support_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_support_action_exchange_preview(support_exchange_info, targetting_resource.method_switch_available())
		if Input.is_action_just_pressed("ui_right"):
			if targetting_resource.target_switch_available():
				targetting_resource.next_target()
				target_tile = targetting_resource.current_target_positon
				update_current_tile(target_tile)
				camera.set_focus_target(grid.map_to_position(target_tile))
				support_exchange_info = combat.combatExchange.generate_support_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
				combat.game_ui.update_support_action_exchange_preview(support_exchange_info, targetting_resource.method_switch_available())

func fsm_support_action_inventory_confirm_new_hover(item:ItemDefinition):
	_weapon_attackable_tiles = populate_tiles_for_weapon(item.attack_range,combat.get_current_combatant().move_position)


#Attack 
func fsm_attack_action_inventory_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_back"):
			fsm_attack_action_inventory_cancel()

func fsm_attack_action_inventory_cancel():
	var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
	if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
		combat.game_ui.destory_active_ui_node()
		var actions :Array[String]  = get_available_unit_actions(combat.get_current_combatant())
		combat.game_ui.create_unit_action_container(actions)
		combat.game_ui.display_unit_status()
		camera.set_footer_open(true)
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
	if grid.get_combat_unit(target_tile) != null:
		exchange_info = combat.combatExchange.generate_combat_exchange_data(combat.get_current_combatant(), grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
		targetting_resource.current_target_type = CombatMapConstants.COMBAT_UNIT
		if targetting_resource._available_methods_at_target.size() > 1:
			combat.game_ui.create_attack_action_combat_exchange_preview(exchange_info, true)
		else:
			combat.game_ui.create_attack_action_combat_exchange_preview(exchange_info)
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_TARGETTING)


func fsm_unit_combat_action_targetting(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			combat.game_ui.destory_active_ui_node()
			#confirm_unit_move(combat.get_current_combatant())
			combat.get_current_combatant().update_map_tile(grid.get_map_tile(combat.get_current_combatant().move_position))
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION)
			if targetting_resource.current_target_type == CombatMapConstants.COMBAT_UNIT:
				await combat.perform_attack(combat.get_current_combatant(), grid.get_combat_unit(target_tile), exchange_info)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
			targetting_resource.clear()
			#Enact combat exchange
			pass
		if Input.is_action_just_pressed("ui_back"):
			var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
			if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_COMBAT_ACTION_INVENTORY:
				combat.game_ui.destory_active_ui_node()
				_interactable_tiles.clear()
				_interactable_tiles = grid.get_range_DFS(combat.get_current_combatant().unit.get_max_attack_range(),combat.get_current_combatant().move_position, false, combat.get_current_combatant().allegience)
				targetting_resource.clear()
				targetting_resource.initalize(combat.get_current_combatant().move_position, grid.get_analysis_on_tiles(_interactable_tiles).get_all_targetables([Constants.FACTION.ENEMIES]),targetting_resource.create_target_methods_weapon(combat.get_current_combatant().unit))
				var action_menu_inventory : Array[UnitInventorySlotData] = targetting_resource.generate_unit_inventory_slot_data(combat.get_current_combatant().unit)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
				combat.game_ui.create_attack_action_inventory(combat.get_current_combatant(), action_menu_inventory)
				revert_player_state()
				camera.set_mode(camera.CAMERA_MODE.FOLLOW)
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
				var current_target_position = targetting_resource.current_target_positon
				targetting_resource.previous_target()
				unit_combat_action_target_change(current_target_position)
		if Input.is_action_just_pressed("ui_right"):
			if targetting_resource._available_targets_with_method.size() > 1:
				var current_target_position = targetting_resource.current_target_positon
				targetting_resource.next_target()
				unit_combat_action_target_change(current_target_position)

func unit_combat_action_target_change(current_target_position: Vector2i):
	# Default Targetting, always unit first
	target_tile = targetting_resource.current_target_positon
	update_current_tile(target_tile)
	camera.set_focus_target(grid.map_to_position(target_tile))
	var target_unit = grid.get_combat_unit(targetting_resource.current_target_positon)
	var target_entity = grid.get_entity(targetting_resource.current_target_positon)
	if target_unit != null:
		targetting_resource.current_target_type = CombatMapConstants.COMBAT_UNIT
		fsm_attack_action_update_ui(targetting_resource.current_target_type)

func fsm_attack_action_update_ui(target_type:String):
	if target_type == CombatMapConstants.COMBAT_UNIT:
		exchange_info = combat.combatExchange.generate_combat_exchange_data(combat.get_current_combatant(),grid.get_combat_unit(target_tile), targetting_resource.current_target_range)
		# check if we should allow options for swaps
		if targetting_resource._available_methods_at_target.size() > 1:
			combat.game_ui.update_weapon_attack_action_combat_exchange_preview(exchange_info, true)
		else:
			combat.game_ui.update_weapon_attack_action_combat_exchange_preview(exchange_info)

func fsm_attack_action_inventory_confirm_new_hover(item:ItemDefinition):
	if item is WeaponDefinition:
		_weapon_attackable_tiles = populate_tiles_for_weapon(item.attack_range,combat.get_current_combatant().move_position)

#Demolish
func fsm_demolish_action_inventory_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_back"):
			fsm_demolish_action_inventory_cancel()

func fsm_demolish_action_inventory_cancel():
	var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
	if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
		combat.game_ui.destory_active_ui_node()
		var actions :Array[String]  = get_available_unit_actions(combat.get_current_combatant())
		combat.game_ui.create_unit_action_container(actions)
		combat.game_ui.display_unit_status()
		camera.set_footer_open(true)
		update_current_tile(move_tile)
		revert_player_state()

func fsm_demolish_action_inventory_confirm(selected_item : ItemDefinition):
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
	if grid.get_entity(target_tile) != null:
		exchange_info = combat.combatExchange.generate_combat_exchange_data_entity(combat.get_current_combatant(),grid.get_entity(target_tile))
		targetting_resource.current_target_type = CombatMapConstants.COMBAT_ENTITY
		if targetting_resource._available_methods_at_target.size() > 1:
			combat.game_ui.create_demolish_action_combat_exchange_preview(exchange_info, grid.get_entity(target_tile),true)
		else:
			combat.game_ui.create_demolish_action_combat_exchange_preview(exchange_info, grid.get_entity(target_tile))
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_DEMOLISH_ACTION_TARGETTING)


func fsm_demolish_action_targetting(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			combat.game_ui.destory_active_ui_node()
			combat.get_current_combatant().update_map_tile(grid.get_map_tile(combat.get_current_combatant().move_position))
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_DEMOLISH_ACTION)
			if targetting_resource.current_target_type == CombatMapConstants.COMBAT_ENTITY:
				await combat.perform_attack_entity(combat.get_current_combatant(), grid.get_entity(target_tile), exchange_info)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
			targetting_resource.clear()
			#Enact combat exchange
			pass
		if Input.is_action_just_pressed("ui_back"):
			var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
			if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_DEMOLISH_ACTION_INVENTORY:
				combat.game_ui.destory_active_ui_node()
				_interactable_tiles.clear()
				_interactable_tiles = grid.get_range_DFS(combat.get_current_combatant().unit.get_max_attack_range(),combat.get_current_combatant().move_position, false, combat.get_current_combatant().allegience)
				targetting_resource.clear()
				targetting_resource.initalize(combat.get_current_combatant().move_position, grid.get_analysis_on_tiles(_interactable_tiles).get_targetable_entities(),targetting_resource.create_target_methods_weapon(combat.get_current_combatant().unit))
				var action_menu_inventory : Array[UnitInventorySlotData] = targetting_resource.generate_unit_inventory_slot_data(combat.get_current_combatant().unit)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
				combat.game_ui.create_demolish_action_inventory(combat.get_current_combatant(), action_menu_inventory)
				revert_player_state()
				camera.set_mode(camera.CAMERA_MODE.FOLLOW)
				update_current_tile(move_tile)
		if Input.is_action_just_pressed("right_bumper"):
			if targetting_resource._available_methods_at_target.size() > 1:
				targetting_resource.next_target_method()
				combat.get_current_combatant().equip(targetting_resource.current_method)
				exchange_info = combat.combatExchange.generate_combat_exchange_data_entity(combat.get_current_combatant(), grid.get_entity(target_tile))
				combat.game_ui.update_weapon_demolish_action_combat_exchange_preview(exchange_info, grid.get_entity(target_tile), true)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
		if Input.is_action_just_pressed("left_bumper"):
			#new weapon if applicable
			if targetting_resource._available_methods_at_target.size() > 1:
				targetting_resource.previous_target_method()
				combat.get_current_combatant().equip(targetting_resource.current_method)
				exchange_info = combat.combatExchange.generate_combat_exchange_data_entity(combat.get_current_combatant(), grid.get_entity(target_tile))
				combat.game_ui.update_weapon_demolish_action_combat_exchange_preview(exchange_info, grid.get_entity(target_tile), true)
				_weapon_attackable_tiles = populate_tiles_for_weapon(combat.get_current_combatant().get_equipped().attack_range,combat.get_current_combatant().move_position)
		if Input.is_action_just_pressed("ui_left"):
			if targetting_resource._available_targets_with_method.size() > 1:
				var current_target_position = targetting_resource.current_target_positon
				targetting_resource.previous_target()
				unit_demolish_action_target_change(current_target_position)
		if Input.is_action_just_pressed("ui_right"):
			if targetting_resource._available_targets_with_method.size() > 1:
				var current_target_position = targetting_resource.current_target_positon
				targetting_resource.next_target()
				unit_demolish_action_target_change(current_target_position)

func unit_demolish_action_target_change(current_target_position: Vector2i):
	target_tile = targetting_resource.current_target_positon
	update_current_tile(target_tile)
	camera.set_focus_target(grid.map_to_position(target_tile))
	var target_entity = grid.get_entity(targetting_resource.current_target_positon)
	if target_entity != null:
		targetting_resource.current_target_type = CombatMapConstants.COMBAT_ENTITY
		fsm_demolish_action_update_ui(targetting_resource.current_target_type)

func fsm_demolish_action_update_ui(target_type:String):
	if target_type == CombatMapConstants.COMBAT_ENTITY:
	# create the entity exchange info
		exchange_info = combat.combatExchange.generate_combat_exchange_data_entity(combat.get_current_combatant(),grid.get_entity(target_tile))
		# check if we should allow options for swaps
		if targetting_resource._available_methods_at_target.size() > 1:
			combat.game_ui.update_weapon_demolish_action_combat_exchange_preview(exchange_info,grid.get_entity(target_tile), true)
		else:
			combat.game_ui.update_weapon_demolish_action_combat_exchange_preview(exchange_info,grid.get_entity(target_tile))

func fsm_demolish_action_inventory_confirm_new_hover(item:ItemDefinition):
	if item is WeaponDefinition:
		_weapon_attackable_tiles = populate_tiles_for_weapon(item.attack_range,combat.get_current_combatant().move_position)

##Inventory
func fsm_unit_inventory_item_selected(data:UnitInventorySlotData):
	combat.game_ui.create_unit_inventory_action_item_selected_menu(data)
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY_ITEM_SELECTED)

func fsm_unit_inventory_item_selected_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_back"):
				combat.game_ui.destory_active_ui_node()
				combat.game_ui.get_active_ui_node().re_grab_focus()
				revert_player_state()

func fsm_unit_inventory_equip(item:ItemDefinition):
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY_ITEM_ACTION)
	combat.game_ui.destory_active_ui_node()
	if item is WeaponDefinition:
		await combat.get_current_combatant().equip(item)
	var unit_inventory_data : Array[UnitInventorySlotData] = combat.combat_unit_item_manager.generate_combat_unit_inventory_data(combat.get_current_combatant())
	combat.game_ui.update_unit_item_action_inventory(combat.get_current_combatant(), unit_inventory_data)
	revert_player_state()
	revert_player_state()

func fsm_unit_inventory_arrange(item:ItemDefinition):
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY_ITEM_ACTION)
	combat.game_ui.destory_active_ui_node()
	await combat.get_current_combatant().unit.inventory.arrange(item)
	var unit_inventory_data : Array[UnitInventorySlotData] = combat.combat_unit_item_manager.generate_combat_unit_inventory_data(combat.get_current_combatant())
	combat.game_ui.update_unit_item_action_inventory(combat.get_current_combatant(), unit_inventory_data)
	revert_player_state()
	revert_player_state()

func fsm_unit_inventory_discard(item:ItemDefinition):
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY_ITEM_ACTION)
	combat.game_ui.destory_active_ui_node()
	await combat.get_current_combatant().unit.inventory.discard_item(item)
	var unit_inventory_data : Array[UnitInventorySlotData] = combat.combat_unit_item_manager.generate_combat_unit_inventory_data(combat.get_current_combatant())
	combat.game_ui.update_unit_item_action_inventory(combat.get_current_combatant(), unit_inventory_data)
	revert_player_state()
	revert_player_state()

func fsm_unit_inventory_un_equip(item:ItemDefinition):
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY_ITEM_ACTION)
	combat.game_ui.destory_active_ui_node()
	await combat.get_current_combatant().un_equip_current_weapon()
	var unit_inventory_data : Array[UnitInventorySlotData] = combat.combat_unit_item_manager.generate_combat_unit_inventory_data(combat.get_current_combatant())
	combat.game_ui.update_unit_item_action_inventory(combat.get_current_combatant(), unit_inventory_data)
	revert_player_state()
	revert_player_state()

func fsm_unit_inventory_use(item:ItemDefinition):
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INVENTORY_ITEM_ACTION)
	combat.game_ui.destory_active_ui_node()
	#combat.get_current_combatant().update_map_tile(grid.get_map_tile(combat.get_current_combatant().move_position))
	confirm_unit_move(combat.get_current_combatant())
	if item is ConsumableItemDefinition:
		await combat.combat_unit_item_manager.use_item(combat.get_current_combatant(), item)
	var unit_inventory_data : Array[UnitInventorySlotData] = combat.combat_unit_item_manager.generate_combat_unit_inventory_data(combat.get_current_combatant())
	combat.game_ui.destory_all_active_ui_nodes_in_stack()
	combat.major_action_complete()
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)

#Wait
func wait_action(cu: CombatUnit):
	combat.get_current_combatant().turn_taken = true
	#combat.get_current_combatant().update_map_tile(grid.get_map_tile(combat.get_current_combatant().move_position))
	confirm_unit_move(cu)
	if combat.get_current_combatant().alive:
		combat.get_current_combatant().map_display.update_values()
		update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
	selector.set_mode(selector.MODE.DEFAULT)

#Interact
func fsm_interact_targetting(delta):
	if Input:
			if Input.is_action_just_pressed("ui_confirm"):
				## What Kind of Entity is it? 
				var target_entity :CombatEntity = grid.get_entity(target_tile)
				if target_entity.interaction_type != CombatEntityConstants.ENTITY_TYPE.CHEST and target_entity.interaction_type != CombatEntityConstants.ENTITY_TYPE.DOOR:
					fsm_do_target_entity_interaction()
				elif target_entity.interaction_type == CombatEntityConstants.ENTITY_TYPE.CHEST: 
					var action_menu_inventory : Array[UnitInventorySlotData] = combat.combat_unit_item_manager.generate_interaction_inventory_data(combat.get_current_combatant(), CombatEntityConstants.valid_chest_unlock_item_db_keys)
					combat.game_ui.create_interact_action_inventory(combat.get_current_combatant(), action_menu_inventory)
					update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INTERACT_ACTION_INVENTORY)
				elif target_entity.interaction_type == CombatEntityConstants.ENTITY_TYPE.DOOR:
					var action_menu_inventory : Array[UnitInventorySlotData] = combat.combat_unit_item_manager.generate_interaction_inventory_data(combat.get_current_combatant(), CombatEntityConstants.valid_door_unlock_item_db_keys)
					combat.game_ui.create_interact_action_inventory(combat.get_current_combatant(), action_menu_inventory)
					update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INTERACT_ACTION_INVENTORY)
			if Input.is_action_just_pressed("ui_back"):
				var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
				if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
					var actions :Array[String]  = get_available_unit_actions(combat.get_current_combatant())
					combat.game_ui.create_unit_action_container(actions)
					update_current_tile(move_tile)
					revert_player_state()
					camera.set_mode(camera.CAMERA_MODE.FOLLOW)
			if Input.is_action_just_pressed("ui_left"):
				if targetting_resource._available_targets_with_method.size() > 1:
					targetting_resource.previous_target_no_new_methods()
					target_tile = targetting_resource.current_target_positon
					update_current_tile(target_tile)
					camera.set_focus_target(grid.map_to_position(target_tile))
			if Input.is_action_just_pressed("ui_right"):
				if targetting_resource._available_targets_with_method.size() > 1:
					targetting_resource.next_target_no_new_methods()
					target_tile = targetting_resource.current_target_positon
					update_current_tile(target_tile)
					camera.set_focus_target(grid.map_to_position(target_tile))

func fsm_interact_action_inventory_confirm(use_item: ItemDefinition):
	combat.game_ui.destory_active_ui_node()
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INTERACT_ACTION)
	combat.get_current_combatant().update_map_tile(grid.get_map_tile(combat.get_current_combatant().move_position))
	await combat.entity_interact_use_item(combat.get_current_combatant(), use_item, grid.get_entity(target_tile))
	combat.major_action_complete()
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)

func fsm_do_target_entity_interaction():
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_INTERACT_ACTION)
	combat.get_current_combatant().update_map_tile(grid.get_map_tile(combat.get_current_combatant().move_position))
	await combat.entity_interact(combat.get_current_combatant(), grid.get_entity(target_tile))
	combat.major_action_complete()
	update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)

func await_entity_resolution():
	var previous_state = game_state
	game_state = CombatMapConstants.COMBAT_MAP_STATE.PROCESSING
	await combat.entity_processing_completed
	game_state = previous_state

##TRADE ACTION

# Trade Action targetting
func fsm_trade_action_targetting(delta):
	if Input:
		if Input.is_action_just_pressed("ui_confirm"):
			#Destroy old UI
			#combat.game_ui.destory_active_ui_node() # ADD BACK WHEN TARGETTING INVENTORY IS MADE
			combat.game_ui.create_trade_action_inventory(combat.get_current_combatant(), grid.get_combat_unit(target_tile))
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_TRADE_ACTION_INVENTORY)
			targetting_resource.clear()
		if Input.is_action_just_pressed("ui_back"):
			var prev_state_info : CombatControllerPlayerStateData = get_previous_player_state_data()
			if prev_state_info._player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
				#combat.game_ui.destory_active_ui_node() # ADD BACK WHEN TARGETTING INVENTORY IS MADE
				var actions :Array[String]  = get_available_unit_actions(combat.get_current_combatant())
				combat.game_ui.create_unit_action_container(actions)
				combat.game_ui.display_unit_status()
				camera.set_footer_open(true)
				update_current_tile(move_tile)
				revert_player_state()
		if Input.is_action_just_pressed("ui_left"):
			if targetting_resource._available_targets_with_method.size() > 1:
				targetting_resource.previous_target_no_new_methods()
				target_tile = targetting_resource.current_target_positon
				update_current_tile(target_tile)
				camera.set_focus_target(grid.map_to_position(target_tile))
		if Input.is_action_just_pressed("ui_right"):
			if targetting_resource._available_targets_with_method.size() > 1:
				targetting_resource.next_target_no_new_methods()
				target_tile = targetting_resource.current_target_positon
				update_current_tile(target_tile)
				camera.set_focus_target(grid.map_to_position(target_tile))
# Trade Action Menu
func fsm_trade_action_inventory_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_back"):
				combat.game_ui.destory_active_ui_node()
				if combat.get_current_combatant().minor_action_taken == false:
					_interactable_tiles.clear()
					_interactable_tiles = grid.get_range_DFS(1,combat.get_current_combatant().move_position, false, combat.get_current_combatant().allegience)
					_interactable_tiles.erase(combat.get_current_combatant().move_position)
					var grid_analysis : CombatMapGridAnalysis = grid.get_analysis_on_tiles(_interactable_tiles)
					var target_positions : Array[Vector2i] = grid_analysis.get_allegience_unit_indexes(combat.get_current_combatant().allegience)
					target_tile = target_positions.front()
					targetting_resource.clear()
					targetting_resource.current_target_positon = target_tile
					targetting_resource._available_targets_with_method = target_positions
					update_current_tile(target_tile)
					camera.set_focus_target(grid.map_to_position(target_tile))
					revert_player_state()
					selector.play("combat_targetting")
				else:
					var actions :Array[String]  = get_available_unit_actions(combat.get_current_combatant())
					combat.game_ui.create_unit_action_container(actions)
					update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT)

func unit_completed_external_trade():
	combat.get_current_combatant().minor_action_taken = true
	combat.get_current_combatant().update_map_tile(grid.get_map_tile(combat.get_current_combatant().move_position))
	

# Battle Prep unit select FSM
func fsm_prep_unit_select(delta):
	#Does the current grid position have a unit?
	if null != grid.get_combat_unit(current_tile):
		var selected_unit : CombatUnit = grid.get_combat_unit(current_tile)
		if selected_unit != null:
			if selected_unit.alive:
				combat.game_ui.display_unit_status()
				camera.set_footer_open(true)
				populate_combatant_tile_ranges(selected_unit)
				update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT_HOVER)
			return
	else :
		combat.game_ui.hide_unit_status()
		camera.set_footer_open(false)
	if Input:
		if Input.is_action_just_pressed("start_button"):
			if combat.ally_spawn_tiles.has(current_tile):
				swap_units(current_tile)
		elif Input.is_action_just_pressed("ui_back"):
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_MENU)
			combat.game_ui.return_to_battle_prep_screen()
			#combat.game_ui.create_combat_map_game_menu() ## **CRAIG** CHANGE TO PREP MAP MENU
			#update_player_state(CombatMapConstants.PLAYER_STATE.GAME_MENU) 
		elif Input.is_action_just_pressed("combat_map_up"):
			update_current_tile(current_tile + Vector2i.UP)
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
		elif Input.is_action_just_pressed("combat_map_left"):
			update_current_tile(current_tile + Vector2i.LEFT)
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
		elif Input.is_action_just_pressed("combat_map_right"):
			update_current_tile(current_tile + Vector2i.RIGHT)
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
		elif Input.is_action_just_pressed("combat_map_down"):
			update_current_tile(current_tile + Vector2i.DOWN)
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
		elif Input.is_action_just_pressed("left_bumper") or Input.is_action_just_pressed("right_bumper"):
			update_current_tile(combat.get_next_unit().map_position)
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
		camera.SimpleFollow(delta)

# Battle Prep Unit Hover FSM, only active when a unit is in the current tile
func fsm_prep_unit_select_hover_process(delta):
	#ensure there is a unit in the tile
	if grid.get_combat_unit(current_tile) == null:
		update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
		return
	if Input:
		var selected_unit : CombatUnit = grid.get_combat_unit(current_tile)
		if Input.is_action_just_pressed("ui_confirm"):
			#combat.game_ui.play_menu_confirm()
			AudioManager.play_sound_effect("unit_select")
			if selected_unit.allegience == Constants.FACTION.PLAYERS:
				## ADD LOGIC FOR UNIT SWAP HERE
				swap_units(current_tile)
			else:
				selected_unit.set_range_indicator(rangeManager.toggle_selected_unit(selected_unit))
		elif Input.is_action_just_pressed("ui_back") or Input.is_action_just_pressed("ui_back"):
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_MENU)
			combat.game_ui.return_to_battle_prep_screen()
		elif Input.is_action_just_pressed("details"):
			if selected_unit != null and selected_unit.alive:
				combat.game_ui.create_combat_unit_detail_panel(selected_unit)
				update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_DETAILS_SCREEN)
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_DETAILS_SCREEN)
		elif Input.is_action_just_pressed("right_bumper"):
			# allow the game to jump between units on the same faction
			update_current_tile(combat.get_next_unit(selected_unit, true).map_position)
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
		elif Input.is_action_just_pressed("left_bumper"):
			# allow the game to jump between units on the same
			update_current_tile(combat.get_next_unit(selected_unit, false).map_position)
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
		elif Input.is_action_just_pressed("start_button"):
			# To be implemented : combat map main menu
			pass
		elif Input.is_action_just_pressed("combat_map_up"):
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
			update_current_tile(current_tile + Vector2i.UP)
		elif Input.is_action_just_pressed("combat_map_left"):
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
			update_current_tile(current_tile + Vector2i.LEFT)
		elif Input.is_action_just_pressed("combat_map_right"):
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
			update_current_tile(current_tile + Vector2i.RIGHT)
		elif Input.is_action_just_pressed("combat_map_down"):
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
			update_current_tile(current_tile + Vector2i.DOWN)
		camera.SimpleFollow(delta)

# Battle Prep Unit details screen FSM
func fsm_prep_unit_details_screen_process(delta):
	if Input:
		if Input.is_action_just_pressed("ui_back"):
			#Close the menu and progress the state
			combat.game_ui.destory_active_ui_node()
			update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
		elif Input.is_action_just_pressed("right_bumper"):
			#Progress the menu to the next unit
			var next_unit : CombatUnit = combat.get_next_unit(grid.get_combat_unit(current_tile), true)
			update_current_tile(next_unit.map_position)
			combat.game_ui.update_combat_unit_detail_panel(next_unit)
		elif Input.is_action_just_pressed("left_bumper"):
			#Progress the menu to the previous unit
			var next_unit : CombatUnit = combat.get_next_unit(grid.get_combat_unit(current_tile), false)
			update_current_tile(next_unit.map_position)
			combat.game_ui.update_combat_unit_detail_panel(next_unit)
		elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
			combat.game_ui.inspect_combat_unit_detail_panel()

func _on_swap_unit_spaces() -> void:
	update_player_state(CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT)
	#if needed check to see if selected party is larger than 0
	#autoCursor()

func player_prep_process(delta):
	match player_state:
		CombatMapConstants.PLAYER_STATE.PREP_MENU:
			pass
		CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT:
			fsm_prep_unit_select(delta)
		CombatMapConstants.PLAYER_STATE.PREP_UNIT_SELECT_HOVER:
			fsm_prep_unit_select_hover_process(delta)
		CombatMapConstants.PLAYER_STATE.PREP_UNIT_DETAILS_SCREEN:
			fsm_prep_unit_details_screen_process(delta)

func _on_battle_prep_start_battle():
	begin_battle()

func swap_units(selected_position:Vector2i):
	if selected_tile == Vector2i(-1,-1) or current_tile == selected_tile:
		selected_tile = selected_position
	else:
		var combatant1 := grid.get_combat_unit(selected_tile)
		var combatant2 := grid.get_combat_unit(selected_position)
		if combatant1:
			combat.remove_friendly_combatant(combatant1.unit)
		if combatant2:
			combat.remove_friendly_combatant(combatant2.unit)
		if combatant1:
			combat.add_combatant(combatant1,selected_position)
		if combatant2:
			combat.add_combatant(combatant2,selected_tile)
		selected_tile = Vector2i(-1,-1)
		#Don't worry it works lol
