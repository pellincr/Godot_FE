##Class that controls the map and user input during the main game flow
extends Node2D
class_name CController

##GRID CONST
const GRID_TEXTURE = preload("res://resources/sprites/grid/grid_marker_2.png")
const PATH_TEXTURE = preload("res://resources/sprites/grid/path_ellipse.png")

##ACTIONS
const ATTACK_ACTION : UnitAction = preload("res://resources/definitions/actions/unit_action_attack.tres")
const WAIT_ACTION : UnitAction = preload("res://resources/definitions/actions/unit_action_wait.tres")
const TRADE_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_trade.tres")
const ITEM_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_inventory.tres")
const USE_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_use_item.tres")
const SUPPORT_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_support.tres")
const SHOVE_ACTION: UnitAction = preload("res://resources/definitions/actions/unit_action_shove.tres")
const CHEST_ACTION: UnitAction = preload("res://resources/definitions/actions/unit_action_chest.tres")
##SIGNALS
signal movement_changed(movement: int)
signal finished_move(position: Vector2i)
signal target_selection_started()
signal target_selection_finished()
signal tile_info_updated(tile : Dictionary)
signal target_detailed_info(combat_unit : CombatUnit)

##EXPORTS
@export var controlled_node : Control
@export var combat: Combat 

var unit_detail_open = false
var tile_map : TileMap
var current_tile_info = {
	"name" = "",
	"x" = 0,
	"y" = 0,
	"texture" = "",
	"defense" = 0,
	"avoid" = 0,
	"unit" = null,  #CombatUnit
	"terrain" = null #Terrain
}

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

var _occupied_spaces : PackedVector2Array #Array of spacing currently containing a unit
var _blocking_spaces = [ #Needs to be updated when adding additional unit types
	[],#GENERIC
	[],#MOBILE
	[],#HEAVY
	[],#MOUNTED
	[]#FLYING
]

var _astargrid = AStarGrid2D.new()
var _path : PackedVector2Array

var player_turn = true

var _attack_target_position
var _blocked_target_position

var _next_position

var _position_id = 0

#Movement Variables
var _arrived = true
var movement = 0:
	set = set_movement,
	get = get_movement
const MOVEMENT_SPEED = 96
var default_move_speed = 96*5 #96 default 
var return_move_speed = 96*5#96 default
var move_speed = default_move_speed
var _previous_position : Vector2i

var _selected_skill: String

#Action Select
var _available_actions : Array[UnitAction]
var _action: UnitAction
var _action_selected: bool # Is this redundant?

#Action Variables
var _action_target_unit : CombatUnit
var _action_target_unit_selected : bool = false # is this redundant? 
var _unit_action_completed : bool = false
var _unit_action_initiated : bool = false
var _action_tiles : PackedVector2Array
var _action_valid_targets : Array[CombatUnit]

#Item Selection Variables
var _selected_item: ItemDefinition
var _selected_entity: CombatMapEntity
var _item_selected: bool

#AI Variables
var _in_ai_process: bool = false
var _enemy_units_turn_taken: bool = false

#Drawing Variables
var move_range : PackedVector2Array
var attack_range : PackedVector2Array
var skill_range : PackedVector2Array 

#SM variables 
var game_state: Constants.GAME_STATE = Constants.GAME_STATE.INITIALIZING
var turn_phase: Constants.TURN_PHASE = Constants.TURN_PHASE.INIT
var previous_turn_phase: Constants.TURN_PHASE = Constants.TURN_PHASE.INIT
var previous_player_state : Constants.PLAYER_STATE = Constants.PLAYER_STATE.INIT
var player_state: Constants.PLAYER_STATE = Constants.PLAYER_STATE.INIT

#Turn Info
var turn_count : int = 1

func _ready():
	#configure _astargrid
	tile_map = get_node("../Terrain/TileMap")
	_astargrid.region = Rect2i(0, 0, 18, 26)
	_astargrid.cell_size = Vector2i(32, 32)
	_astargrid.offset = Vector2(16, 16)
	_astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astargrid.update()
	#Auto Wire combat signals for modularity
	combat.connect("perform_shove", perform_shove)
	combat.connect("combatant_added", combatant_added)
	combat.connect("combatant_died", combatant_died)
	combat.connect("major_action_completed", _on_visual_combat_major_action_completed)
	combat.connect("minor_action_completed", _on_visual_combat_minor_action_completed)
	combat.connect("turn_advanced", advance_turn)
	#combat.combatExchange.connect("combat_exchange_finished", _on_combat)
	#build blocking spaces arrays
	for tile in tile_map.get_used_cells(0):
		update_blocking_space_at_tile(tile)
	#Once Game initialization is complete begin player turn
	game_state = Constants.GAME_STATE.PLAYER_TURN

func update_blocking_space_at_tile(tile:Vector2i):
	if get_terrain_at_map_position(tile):
		var terrain :Terrain =  get_terrain_at_map_position(tile)
		for movement_type_index in range(_blocking_spaces.size()):
			#does terrain have the movement time in its blacklist?
			if movement_type_index in terrain.blocks:
				#does blocking tiles need to be updated
				if tile not in _blocking_spaces[movement_type_index]:
					_blocking_spaces[movement_type_index].append(tile)
			else : 
				#does the old reference to the tile need to be removed
				if tile in _blocking_spaces[movement_type_index]:
					_blocking_spaces[movement_type_index].remove(tile)

#	if Input.is_action_just_pressed("ui_accept"):	
func process_ui_confirm_inputs(delta):
	if game_state == Constants.GAME_STATE.PLAYER_TURN:
		if turn_phase == Constants.TURN_PHASE.MAIN_PHASE:
			var mouse_position = get_global_mouse_position()
			var mouse_position_i = tile_map.local_to_map(mouse_position)
			get_tile_info(mouse_position_i)
			if player_state == Constants.PLAYER_STATE.UNIT_SELECT:
				##Player selects a unit
				var selected_unit = get_combatant_at_position(mouse_position_i)
				if selected_unit and selected_unit.alive and !selected_unit.turn_taken: 
					combat.game_ui.play_menu_confirm()
					if selected_unit.allegience == 0:
						set_controlled_combatant(selected_unit)
						combat.game_ui.hide_end_turn_button()
						update_player_state(Constants.PLAYER_STATE.UNIT_MOVEMENT)
					else : 
						pass 
			elif player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT:
				combat.game_ui.play_menu_confirm()
				## Players selects a move
				if _arrived == true:
					if mouse_position_i != combat.get_current_combatant().map_tile.position:
						if not _occupied_spaces.has(mouse_position_i):
							if not _blocking_spaces[combat.get_current_combatant().unit.movement_class].has(mouse_position_i):
								move_player()
					else :
						combat.get_current_combatant().move_tile.position = combat.get_current_combatant().map_tile.position
						combat.get_current_combatant().move_tile.terrain = combat.get_current_combatant().map_tile.terrain
						combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
						update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_SELECT)
					if _arrived == true:
						find_path(mouse_position_i)
						var comb = get_combatant_at_position(mouse_position_i)
						var local_map = tile_map.map_to_local(mouse_position_i)
						get_tile_info(mouse_position_i)
						if comb != null:	
							if comb.allegience == 1 and comb.alive:
								_attack_target_position = local_map
							else:
								_attack_target_position = null
								_blocked_target_position = local_map
						elif mouse_position_i in _blocking_spaces[combat.get_current_combatant().unit.movement_class]:
							_blocked_target_position = local_map
						else:
							_attack_target_position = null
							_blocked_target_position = null
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT:
				pass
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION: 
				pass
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_OPTION_SELECT:
				pass
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
				pass
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
				if _action_selected == true and _action.requires_target == true:
					##Targeting
					var comb = get_combatant_at_position(mouse_position_i)
					if comb != null and comb.alive:
						if _action_valid_targets.has(comb):
							combat.game_ui.hide_unit_combat_exchange_preview()
							combat.get_current_combatant().map_tile.position = combat.get_current_combatant().move_tile.position
							combat.get_current_combatant().map_tile.terrain = get_terrain_at_map_position(combat.get_current_combatant().map_tile.position)
							action_target_selected(comb)
						else:
							print("Invalid Target")
							comb = null
							pass
		else :
			return

func process_ui_cancel_inputs(delta):
	if game_state == Constants.GAME_STATE.PLAYER_TURN:
		if turn_phase == Constants.TURN_PHASE.MAIN_PHASE:
			var mouse_position = get_global_mouse_position()
			var mouse_position_i = tile_map.local_to_map(mouse_position)
			get_tile_info(mouse_position_i)
			if player_state == Constants.PLAYER_STATE.UNIT_SELECT:
				if unit_detail_open:
					target_detailed_info.emit(null)
					unit_detail_open = false
			elif player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT:
				_action_tiles.clear()
				update_player_state(Constants.PLAYER_STATE.UNIT_SELECT)
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT:
				combat.game_ui.play_menu_back()
				if (_arrived):
					combat.game_ui.hide_action_list()
					##MOVE THE UNIT BACK 
					if combat.get_current_combatant().map_tile.position != combat.get_current_combatant().move_tile.position:
						find_path(combat.get_current_combatant().map_tile.position)
						return_player()
					else : 
						#finished_move.emit()
						_arrived = true
						movement = combat.get_current_combatant().unit.movement
						update_player_state(Constants.PLAYER_STATE.UNIT_MOVEMENT)
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION: 
				combat.complete_trade()
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_OPTION_SELECT:
				if(_action == ITEM_ACTION):
					combat.game_ui.remove_inventory_options_container()
					combat.game_ui.enable_inventory_list_butttons()
				revert_action_flow()
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
				combat.game_ui.hide_attack_action_inventory()
				revert_action_flow()
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
				combat.game_ui.play_menu_back()
				combat.game_ui.hide_unit_combat_exchange_preview()
				revert_action_flow()
		else :
			return

func process_ui_info_inputs(delta):
	if game_state == Constants.GAME_STATE.PLAYER_TURN:
		if turn_phase == Constants.TURN_PHASE.MAIN_PHASE:
			var mouse_position = get_global_mouse_position()
			var mouse_position_i = tile_map.local_to_map(mouse_position)
			get_tile_info(mouse_position_i)
			if player_state == Constants.PLAYER_STATE.UNIT_SELECT:
				var comb = get_combatant_at_position(mouse_position_i)
				if comb != null and comb.alive:
					if unit_detail_open == false:
						target_detailed_info.emit(comb)
						unit_detail_open = true
	
##Processes user input if not on a menu
func _unhandled_input(event):
	## Player Turn
	if game_state == Constants.GAME_STATE.PLAYER_TURN:
		if turn_phase == Constants.TURN_PHASE.MAIN_PHASE:
			var mouse_position = get_global_mouse_position()
			var mouse_position_i = tile_map.local_to_map(mouse_position)
			get_tile_info(mouse_position_i)
			if player_state == Constants.PLAYER_STATE.UNIT_SELECT:
				if event is InputEventMouseButton:
					## Select Unit
					if event.button_index == MOUSE_BUTTON_LEFT:
						if event.is_released():
							##Player selects a unit
							var selected_unit = get_combatant_at_position(mouse_position_i)
							if selected_unit and selected_unit.alive and !selected_unit.turn_taken: 
								combat.game_ui.play_menu_confirm()
								if selected_unit.allegience == 0:
									set_controlled_combatant(selected_unit)
									combat.game_ui.hide_end_turn_button()
									update_player_state(Constants.PLAYER_STATE.UNIT_MOVEMENT)
								else : 
									pass 
					## Display info Panel
					if event.button_index == MOUSE_BUTTON_RIGHT:
						var comb = get_combatant_at_position(mouse_position_i)
						if comb != null and comb.alive:
							target_detailed_info.emit(comb)
							unit_detail_open = true
						elif unit_detail_open:
							target_detailed_info.emit(null)
							unit_detail_open = false
			elif player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT:
				if event is InputEventMouseButton:
					if event.button_index == MOUSE_BUTTON_LEFT:
						if event.is_released():
							combat.game_ui.play_menu_confirm()
							## Players selects a move
							if _arrived == true:
								if mouse_position_i != combat.get_current_combatant().map_tile.position:
									if not _occupied_spaces.has(mouse_position_i):
										if not _blocking_spaces[combat.get_current_combatant().unit.movement_class].has(mouse_position_i):
											move_player()
								else :
									combat.get_current_combatant().move_tile.position = combat.get_current_combatant().map_tile.position
									combat.get_current_combatant().move_tile.terrain = combat.get_current_combatant().map_tile.terrain
									#finished_move.emit()
									combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
									update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_SELECT)
					if event.button_index == MOUSE_BUTTON_RIGHT:
						if event.is_released():
							_action_tiles.clear()
							update_player_state(Constants.PLAYER_STATE.UNIT_SELECT)
				if event is InputEventMouseMotion:
					if _arrived == true:
						find_path(mouse_position_i)
						var comb = get_combatant_at_position(mouse_position_i)
						var local_map = tile_map.map_to_local(mouse_position_i)
						get_tile_info(mouse_position_i)
						if comb != null:	
							if comb.allegience == 1 and comb.alive:
								_attack_target_position = local_map
							else:
								_attack_target_position = null
								_blocked_target_position = local_map
						elif mouse_position_i in _blocking_spaces[combat.get_current_combatant().unit.movement_class]:
							_blocked_target_position = local_map
						else:
							_attack_target_position = null
							_blocked_target_position = null
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT:
				if event is InputEventMouseButton:
					if event.button_index == MOUSE_BUTTON_RIGHT:
							if event.is_released():
								combat.game_ui.play_menu_back()
								if (_arrived):
									combat.game_ui.hide_action_list()
									##MOVE THE UNIT BACK 
									if combat.get_current_combatant().map_tile.position != combat.get_current_combatant().move_tile.position:
										find_path(combat.get_current_combatant().map_tile.position)
										return_player()
									else : 
										#finished_move.emit()
										_arrived = true
										movement = combat.get_current_combatant().unit.movement
										update_player_state(Constants.PLAYER_STATE.UNIT_MOVEMENT)
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION: 
				if event is InputEventMouseButton:
					if event.button_index == MOUSE_BUTTON_RIGHT:
						combat.complete_trade()
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_OPTION_SELECT:
				if event is InputEventMouseButton:
					if event.button_index == MOUSE_BUTTON_RIGHT:
						if event.is_released():
							if(_action == ITEM_ACTION):
								combat.game_ui.remove_inventory_options_container()
								combat.game_ui.enable_inventory_list_butttons()
							revert_action_flow()
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
				if event is InputEventMouseButton:
					if event.button_index == MOUSE_BUTTON_RIGHT:
						if event.is_released():
							combat.game_ui.hide_attack_action_inventory()
							combat.game_ui.hide_action_inventory()
							revert_action_flow()
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
					if event is InputEventMouseButton:
						if event.button_index == MOUSE_BUTTON_LEFT:
							if event.is_released():
								if _action_selected == true and _action.requires_target == true:
									##Targeting
									var comb = get_combatant_at_position(mouse_position_i)
									if comb != null and comb.alive:
										if _action_valid_targets.has(comb):
											combat.game_ui.hide_unit_combat_exchange_preview()
											combat.get_current_combatant().map_tile.position = combat.get_current_combatant().move_tile.position
											combat.get_current_combatant().map_tile.terrain = get_terrain_at_map_position(combat.get_current_combatant().map_tile.position)
											action_target_selected(comb)
										else:
											print("Invalid Target")
											comb = null
											pass
						if event.button_index == MOUSE_BUTTON_RIGHT:
							if event.is_released():
								combat.game_ui.play_menu_back()
								combat.game_ui.hide_unit_combat_exchange_preview()
								revert_action_flow()
		else :
			return

#process called on frame
func _process(delta):
	if Input:
		if Input.is_action_pressed("ui_confirm"):
			process_ui_confirm_inputs(delta)
		elif Input.is_action_pressed("ui_cancel"):
			process_ui_cancel_inputs(delta)
		elif Input.is_action_just_pressed("ui_info"):
			process_ui_info_inputs(delta)
	queue_redraw()
	if game_state == Constants.GAME_STATE.PLAYER_TURN:
		if(turn_phase == Constants.TURN_PHASE.INIT):
			combat.game_ui.hide_end_turn_button()
			update_turn_phase(Constants.TURN_PHASE.BEGINNING_PHASE)
		elif(turn_phase == Constants.TURN_PHASE.BEGINNING_PHASE):
			await process_terrain_effects()
			update_turn_phase(Constants.TURN_PHASE.MAIN_PHASE)
			update_player_state(Constants.PLAYER_STATE.UNIT_SELECT)
		elif turn_phase == Constants.TURN_PHASE.MAIN_PHASE :
			combat.game_ui._set_tile_info(current_tile_info)
			#DO PLAYER ACTION PROCESS HERE, WE GIVE PLAYER CONTROL
			if player_state == Constants.PLAYER_STATE.UNIT_SELECT:
				combat.game_ui.show_end_turn_button()
			if player_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT:
				combat.game_ui.hide_end_turn_button()
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION:
				if not _unit_action_initiated: 
					if _action:
						combat.game_ui.hide_end_turn_button()
						perform_action()
						_unit_action_initiated = true
				if not _unit_action_completed and _unit_action_initiated:
					#We await the action completion
					pass
				elif _unit_action_completed and _unit_action_initiated:
					_unit_action_completed = false
					_unit_action_initiated = false
					combat.get_current_combatant().turn_taken = true
					if combat.get_current_combatant().alive:
						combat.get_current_combatant().map_display.update_values()
					update_player_state(Constants.PLAYER_STATE.UNIT_SELECT)
				else :
					print("action state is hanging?")
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
				pass
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
				combat.game_ui.hide_end_turn_button()
				var mouse_position = get_global_mouse_position()
				var mouse_position_i = tile_map.local_to_map(mouse_position)
				var comb = get_combatant_at_position(mouse_position_i)
				if comb != null and comb.alive:
					if _action_valid_targets.has(comb):
						if _action == ATTACK_ACTION:
							combat.game_ui.display_unit_combat_exchange_preview(combat.get_current_combatant(), comb,  get_distance(combat.get_current_combatant().move_tile.position, comb.map_tile.position))
						elif _action == SUPPORT_ACTION:
							pass
						return
				combat.game_ui.hide_unit_combat_exchange_preview()
		elif(turn_phase == Constants.TURN_PHASE.ENDING_PHASE):
			#do turn end stuff for player 
			game_state = Constants.GAME_STATE.ENEMY_TURN
			update_turn_phase(Constants.TURN_PHASE.BEGINNING_PHASE)
	elif game_state == Constants.GAME_STATE.ENEMY_TURN:
		combat.game_ui.hide_end_turn_button()
		#print("In Enemy Turn")
		if(turn_phase == Constants.TURN_PHASE.BEGINNING_PHASE):
			#DO THE BEGINNING PHASE STUFF HERE EX. STATUS EFFECTS REMOVE BUFFS, TERRAIN HEALING AND MORE
			await process_terrain_effects()
			update_turn_phase(Constants.TURN_PHASE.MAIN_PHASE)
		elif(turn_phase == Constants.TURN_PHASE.MAIN_PHASE):
			if _in_ai_process:
				pass
			else : 
				if not _enemy_units_turn_taken:
					ai_turn()
				else :
					print("moved to enemy end phase")
					update_turn_phase(Constants.TURN_PHASE.ENDING_PHASE)
		elif(turn_phase == Constants.TURN_PHASE.ENDING_PHASE):
			print("Enemy Ended Turn")
			trigger_reinforcements()
			_in_ai_process = false
			_enemy_units_turn_taken = false
			turn_count += 1
			
			combat.advance_turn(Constants.FACTION.ENEMIES)
			#do stuff like spawn re-inforcements
			game_state = Constants.GAME_STATE.PLAYER_TURN
			update_turn_phase(Constants.TURN_PHASE.BEGINNING_PHASE)
	##MOVE UNIT CODE
	if turn_phase == Constants.TURN_PHASE.PROCESSING:
		#print("In _process Processing")
		if _arrived == false:
			#print("In Unit Move")
			#check and resolve potential overshoots
			if (delta * move_speed) > controlled_node.position.distance_to(_next_position):
				controlled_node.position = _next_position
			else :
				controlled_node.position += controlled_node.position.direction_to(_next_position) * delta * move_speed
			if controlled_node.position.distance_to(_next_position) < 1:
				CustomUtilityLibrary.erase_packedVector2Array(_occupied_spaces, _previous_position)
				_astargrid.set_point_weight_scale(_previous_position, 1)
				var tile_cost = get_tile_cost(_previous_position)
				controlled_node.position = _next_position
				var new_position: Vector2i = tile_map.local_to_map(_next_position)
				_previous_position = new_position
				_occupied_spaces.append(new_position)
				#update_points_weight()
				var next_tile_cost = get_tile_cost(new_position)
				movement -= tile_cost
				#Can we move there?
				if (_position_id < _path.size() - 1) and movement > 0 and (next_tile_cost <= movement):
					_position_id += 1
					_next_position = _path[_position_id]
				else:
					update_turn_phase(previous_turn_phase)
					_arrived = true
					finished_move.emit(new_position) #EMIT THIS LAST
					if game_state == Constants.GAME_STATE.PLAYER_TURN:
						if(player_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT) :
							#Move complete on action select (cancelled move)
							#remove old space from occupied spaces
							CustomUtilityLibrary.erase_packedVector2Array(_occupied_spaces, combat.get_current_combatant().move_tile.position)
							_astargrid.set_point_weight_scale(combat.get_current_combatant().move_tile.position, 1)
							movement = combat.get_current_combatant().unit.movement
							update_player_state(Constants.PLAYER_STATE.UNIT_MOVEMENT)
						elif(player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT):
							combat.get_current_combatant().move_tile.position = new_position
							combat.get_current_combatant().move_tile.terrain = get_terrain_at_map_position(new_position)
							combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
							update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_SELECT)
						elif(player_state == Constants.PLAYER_STATE.UNIT_ACTION):
							combat.get_current_combatant().move_tile.position = new_position
							combat.get_current_combatant().move_tile.terrain = get_terrain_at_map_position(new_position)
					elif game_state == Constants.GAME_STATE.ENEMY_TURN:
						##update_player_state(previous_player_state)
						pass

#draw the area
func _draw():
	if(game_state == Constants.GAME_STATE.PLAYER_TURN):
		if(player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT):
			if(combat.get_current_combatant()):
				draw_comb_range(combat.get_current_combatant())
				draw_ranges(move_range, true, attack_range,true, skill_range, true)
				drawSelectedpath()
		if(player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT):
			draw_action_tiles(_action_tiles, _action)

#advance_the game turn
#connect to UI end turn
func advance_turn():
	update_turn_phase(Constants.TURN_PHASE.ENDING_PHASE)
	combat.advance_turn(Constants.FACTION.PLAYERS)

func get_combatant_at_position(target_position: Vector2i) -> CombatUnit:
	for comb in combat.combatants:
		if comb.map_tile.position == target_position and comb.alive:
			return comb
	return null

func get_entity_at_position(target_position:Vector2i)-> CombatMapEntity:
	var tile = tile_map.local_to_map(position)
	if _astargrid.is_in_boundsv(tile):
		return get_entity_at_tile(tile)
	return null

func get_entity_at_tile(tile:Vector2i)-> CombatMapEntity:
	for ent in combat.entities:
		if ent.position == tile and ent.active:
			return ent
	return null

func combatant_added(combatant):
	_occupied_spaces.append(combatant.map_tile.position)
	
func entity_added(cme: CombatMapEntity):
	pass

func combatant_died(combatant):
	_astargrid.set_point_weight_scale(combatant.map_tile.position, 1)
	CustomUtilityLibrary.erase_packedVector2Array(_occupied_spaces,combatant.map_tile.position)
	combatant.map_display.queue_free()

func entity_disabled(e :CombatMapEntity):
	update_blocking_space_at_tile(e.position)

func update_points_weight():
	for cell in tile_map.get_used_cells(0):
		if _astargrid.is_in_boundsv(cell):
			_astargrid.set_point_solid(cell, false)
			_astargrid.set_point_weight_scale(cell, get_tile_cost(cell))
	##Update occupied spaces for flying units
	for point in _occupied_spaces:
		if combat.get_current_combatant().unit.movement_class == Constants.UNIT_MOVEMENT_CLASS.FLYING:
			#_astargrid.set_point_weight_scale(point, 1)
			pass
		elif  get_combatant_at_position(point): # allow friendly units to pass through each other
			if combat.get_current_combatant().allegience == get_combatant_at_position(point).allegience:
			#	_astargrid.set_point_weight_scale(point, 1)
				pass
			else :
				#_astargrid.set_point_weight_scale(point, INF)
				_astargrid.set_point_solid(point)
		else:
			#_astargrid.set_point_weight_scale(point, INF)
			_astargrid.set_point_solid(point)
	# movement class blocked tiles
	for class_m in range(_blocking_spaces.size()):
		for point in _blocking_spaces[class_m]:
				if combat.get_current_combatant().unit.movement_class == class_m:
					if(_astargrid.is_in_bounds(point.x, point.y)):
						#_astargrid.set_point_weight_scale(point, INF)
						_astargrid.set_point_solid(point)
					else:
						#do nothing if its out of bounds?
						pass
						#_astargrid.set_point_weight_scale(point, 1)
	for e in combat.entities:
		if e.active:
			if e.terrain != null:
				if combat.get_current_combatant().unit.movement_class in e.terrain.blocks:
					if(_astargrid.is_in_boundsv(e.position)):
						_astargrid.set_point_solid(e.position)

func get_distance(point1: Vector2i, point2: Vector2i):
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)

func get_movement():
	return movement

func find_path(tile_position: Vector2i):
	_path.clear()
	if(_astargrid.is_in_boundsv(tile_position)):
		var current_position = tile_map.local_to_map(controlled_node.position)
		if _astargrid.get_point_weight_scale(tile_position) > 999999:
			#this is inherited code -- Why does it exist?
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
		#print("@ PATH FOUND : " + str(_path))
		queue_redraw()

func move_player():
	move_speed = default_move_speed
	var current_position = tile_map.local_to_map(controlled_node.position)
	combat.get_current_combatant().move_tile.position = current_position
	combat.get_current_combatant().move_tile.terrain = get_terrain_at_map_position(current_position)
	var _path_size = _path.size()
	if _path_size > 1 and movement > 0:
		move_on_path(current_position)

func return_player():
	move_speed = return_move_speed
	var original_position = combat.get_current_combatant().map_tile.position
	var _path_size = _path.size()
	movement = 99
	if _path_size >= 1:
		move_on_path(original_position)

func move_on_path(current_position):
	print("Entered move_on_path in Ccontroller")
	_previous_position = current_position
	_position_id = 1
	if _path.size() > _position_id :
		_next_position = _path[_position_id]
	_arrived = false
	update_turn_phase(Constants.TURN_PHASE.PROCESSING)
	queue_redraw()
	print("Exited move_on_path in Ccontroller")

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
		elif _action == SUPPORT_ACTION:
			combat.game_ui._set_support_action_inventory(combat.get_current_combatant())
		elif _action == ITEM_ACTION:
			combat.game_ui._set_inventory_list(combat.get_current_combatant())
		elif _action == CHEST_ACTION:
			_selected_entity = get_entity_at_position(combat.get_current_combatant().move_tile.position)
			combat.game_ui._set_item_action_inventory(combat.get_current_combatant(), get_viable_chest_items(combat.get_current_combatant()))
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

func get_tile_cost(tile, unit:CombatUnit = null):
	if _astargrid.is_in_boundsv(tile):
		var tile_terrain :Terrain = get_terrain_at_map_position(tile)
		if tile_terrain:
			if unit:
				return int (tile_terrain.cost[unit.unit.movement_class])
			else: 
				return int (tile_terrain.cost[combat.get_current_combatant().unit.movement_class])
	else : 
		print("get_tile_cost called with out of bounds tile")
	return INF

func get_tile_cost_at_position(point, unit:CombatUnit = null):
	var tile = tile_map.local_to_map(point)
	if _astargrid.is_in_boundsv(tile):
		return get_tile_cost(tile, unit)
	else: 
		return INF

##Draw the path between the selected Combatant and the mouse cursor
func drawSelectedpath():
	if _arrived == true and player_turn == true:
		var path_length = movement
		#Get the length of the path
		for i in range(_path.size()):
			var point = _path[i]
			var draw_color = Color.TRANSPARENT
			if !_blocking_spaces[combat.get_current_combatant().unit.movement_class].has(point):
				draw_color = Color.DIM_GRAY
				if path_length - get_tile_cost_at_position(point, combat.get_current_combatant()) >= 0:
					draw_color = Color.WHITE
				if i > 0:
					path_length -= get_tile_cost_at_position(point, combat.get_current_combatant())
			else : 
				break
			draw_texture(PATH_TEXTURE, point - Vector2(16, 16), draw_color)


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
	if _arrived == true and player_turn == true: #this may be redundant
		#add our first tile into the front of the visited array
		
		visited.get_or_add(tiles[0], range)
		#if the player has movement otherwise this is meaningless
		if range > 0:
			for tile in tiles: 
			#recursively call on the tiles around until range is empty
				for neighbors in tile_nieghbor_index :
					#get the correct tile in the direction
					var target_tile = tile_map.get_neighbor_cell(tile, neighbors)
					if _astargrid.is_in_boundsv(target_tile):
						if(effected_by_terrain) :
							#should we even be considering this tile?
							if not _occupied_spaces.has(target_tile) or (get_combatant_at_position(target_tile) and get_combatant_at_position(target_tile).allegience == combat.get_current_combatant().allegience):
								var target_tile_cost = get_tile_cost(target_tile)
								remaining_range = range - target_tile_cost 
								if (remaining_range >= 0  and not _blocking_spaces[movement_type].has(target_tile)):
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
	if _arrived == true and player_turn == true: #this may be redundant
		#add our first tile into the front of the visited array
		visited.get_or_add(origin, range)
		#if the player has movement otherwise this is meaningless
		if range > 0:
			#recursively call on the tiles around until range is empty
			for neighbors in tile_nieghbor_index :
				#get the correct tile in the direction
				var target_tile = tile_map.get_neighbor_cell(origin, neighbors)
				if _astargrid.is_in_boundsv(target_tile):
					if(effected_by_terrain) :
						#should we even be considering this tile?
						if not _occupied_spaces.has(target_tile) or (get_combatant_at_position(target_tile) and get_combatant_at_position(target_tile).allegience == combat.get_current_combatant().allegience):
							var target_tile_cost = get_tile_cost(target_tile)
							remaining_range = range - target_tile_cost 
							if (remaining_range >= 0  and not _blocking_spaces[movement_type].has(target_tile)):
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
	if _arrived == true and player_turn == true: #this may be redundant
		#add our first tile into the front of the visited array
		visited.get_or_add(origin, range)
		#if the player has movement otherwise this is meaningless
		if range > 0:
			#recursively call on the tiles around until range is empty
			for neighbors in tile_nieghbor_index :
				#get the correct tile in the direction
				var target_tile = tile_map.get_neighbor_cell(origin, neighbors)
				if _astargrid.is_in_boundsv(target_tile):
					if(effected_by_terrain) :
						#should we even be considering this tile?
						if not _occupied_spaces.has(target_tile) or (get_combatant_at_position(target_tile) and get_combatant_at_position(target_tile).allegience == combat.get_current_combatant().allegience):
							var target_tile_cost = get_tile_cost(target_tile)
							remaining_range = range - target_tile_cost 
							if (remaining_range >= 0  and not _blocking_spaces[movement_type].has(target_tile)):
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
				var target_tile = tile_map.get_neighbor_cell(origin, neighbors)
				if _astargrid.is_in_boundsv(target_tile):
					if(effected_by_terrain) :
						#should we even be considering this tile?
						if not _occupied_spaces.has(target_tile) or (get_combatant_at_position(target_tile) and get_combatant_at_position(target_tile).allegience == combat.get_current_combatant().allegience):
							var target_tile_cost = get_tile_cost(target_tile)
							remaining_range = range - target_tile_cost 
							if (remaining_range >= 0  and not _blocking_spaces[movement_type].has(target_tile)):
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

#Draws a units move and attack ranges
func draw_ranges(move_range:PackedVector2Array, draw_move_range:bool, attack_range:PackedVector2Array, draw_attack_range:bool, skill_range:PackedVector2Array, draw_skill_range:bool):
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

func process_inputs():
	if Input.is_action_pressed("debug_button"):
		print("pressed_debug_button")

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
	#_action_tiles.clear()
	#_action_valid_targets.clear()

func begin_action_flow():
	clear_action_variables()
	if _action:
		_action_selected = true
		if not _action.flow.is_empty():
			if _action.flow.front() == Constants.UNIT_ACTION_STATE.ITEM_SELECT: 
				begin_action_item_selection()
				update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT)
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
	##var coords = tile_map.get_cell_atlas_coords(0, position)
	if position == Vector2i(current_tile_info.x, current_tile_info.y)  :
		return
	#combat.game_ui.play_cursor()
	current_tile_info.x = position.x
	current_tile_info.y = position.y
	if get_terrain_at_map_position(position):
		var terrain : Terrain =  get_terrain_at_map_position(position)
		current_tile_info.terrain = terrain
	##get the unit info
	if get_combatant_at_position(position):
		current_tile_info.unit = get_combatant_at_position(position)
	else : 
		current_tile_info.unit = null
	tile_info_updated.emit(current_tile_info)

func get_terrain_at_position(position: Vector2) ->  Terrain:
	var tile = tile_map.local_to_map(position)
	return get_terrain_at_map_position(tile)

func get_terrain_at_map_position(position: Vector2) ->  Terrain:
	if _astargrid.is_in_boundsv(position):
		#Entity terrain takes precident
		if get_entity_at_tile(position) != null:
			var _entity_at_posn = get_entity_at_tile(position)
			if _entity_at_posn.active and _entity_at_posn.terrain != null:
				return _entity_at_posn.terrain
		#Map Terrain is then used
		var tile_data = tile_map.get_cell_tile_data(0, position)
		if tile_data :
			if tile_data.get_custom_data("Terrain") is Terrain:
				return tile_data.get_custom_data("Terrain")
		print("ERROR TERRAIN IS NULL")
	else :
		print("get_terrain_at_map_position called on out of bounds tile")
	return null

func draw_comb_range(combatant: CombatUnit) :
	attack_range.clear()
	skill_range.clear()
	move_range = get_range_DFS(combatant.unit.movement, combatant.map_tile.position, combatant.unit.movement_class, true)
	var edge_array = find_edges(move_range)
	attack_range = get_range_multi_origin_DFS(combatant.unit.inventory.get_available_attack_ranges().max(), edge_array)
	skill_range = attack_range.duplicate()

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
		if get_combatant_at_position(tile) :
			if(get_combatant_at_position(tile).allegience != cu.allegience) :
				response.append(get_combatant_at_position(tile))
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
		if get_combatant_at_position(tile) :
			if(get_combatant_at_position(tile).allegience == cu.allegience and get_combatant_at_position(tile) != cu) :
				response.append(get_combatant_at_position(tile))
	return response
	
func get_potential_shove_targets(cu: CombatUnit) -> Array[CombatUnit]:
	var pushable_targets : Array[CombatUnit]
	for tile in grid_get_target_tile_neighbors(cu.move_tile.position):
		if get_combatant_at_position(tile) :
			var pushable_unit = get_combatant_at_position(tile)
			var push_vector : Vector2i  = Vector2i(tile) - Vector2i(cu.move_tile.position)
			var target_tile : Vector2i = Vector2i(tile) + push_vector;
			if not _blocking_spaces[pushable_unit.unit.movement_class].has(target_tile):
				if not _occupied_spaces.has(target_tile):
					if get_tile_cost(target_tile, pushable_unit) < 99999:
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
	if get_entity_at_position(cu.move_tile.position) :
		var _entity = get_entity_at_position(cu.move_tile.position)
		if _entity is CombatMapChestEntity:
			for item : ItemDefinition in _entity.required_item:
				if cu.unit.inventory.has(item):
					_items.append(item)
					#TO BE IMPLEMENTED if unit can use item
	return _items
func chest_action_available(cu:CombatUnit)-> bool:
	if get_entity_at_position(cu.move_tile.position) :
		var _entity = get_entity_at_position(cu.move_tile.position)
		if _entity is CombatMapChestEntity:
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
			attackable_tiles.append_array(get_tiles_at_range_new(range, cu.move_tile.position))
	return attackable_tiles

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
			var target_tile = tile_map.get_neighbor_cell(origin, neighbors)
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

func process_terrain_effects():
	for combat_unit in combat.combatants:
		if combat not in combat.dead_units:
			if (combat_unit.allegience == Constants.FACTION.PLAYERS and game_state == Constants.GAME_STATE.PLAYER_TURN) or (combat_unit.allegience == Constants.FACTION.ENEMIES and game_state == Constants.GAME_STATE.ENEMY_TURN):
				if get_terrain_at_map_position(combat_unit.map_tile.position): 
					var target_terrain = get_terrain_at_map_position(combat_unit.map_tile.position)
					if target_terrain.active_effect_phases == Constants.TURN_PHASE.keys()[turn_phase]:
						if target_terrain.effect != Terrain.TERRAIN_EFFECTS.NONE:
							if target_terrain.effect == Terrain.TERRAIN_EFFECTS.HEAL:
								if combat_unit.unit.hp < combat_unit.unit.max_hp:
									print("HEALED UNIT : " + combat_unit.unit.unit_name)
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
	update_player_state(Constants.PLAYER_STATE.UNIT_MOVEMENT)
	
# AI Methods

func ai_process_new(ai_unit: CombatUnit) -> aiAction:
	print("Entered ai_process in cController.gd")
	#find nearest non-solid tile to target_position
	#Get Attack Range to see what are "attackable tiles"	
	update_points_weight() #Is this redundant? 
	var current_position = tile_map.local_to_map(controlled_node.position)
	var moveable_tiles : PackedVector2Array
	var actionable_tiles :PackedVector2Array
	var actionable_range : Array[int]= ai_unit.unit.get_attackable_ranges()
	var action_tile_options: PackedVector2Array
	var selected_action: aiAction
	var called_move : bool = false
	#Step 1 : Get all moveable tiles
	print("@ BEGAN TILE ANALYSIS WITH CURRENT TILE")
	selected_action = ai_get_best_move_at_tile(ai_unit, current_position, actionable_range)
	# Step 2, if the unit can move do analysis on movable tiles
	if ai_unit.ai_type != Constants.UNIT_AI_TYPE.DEFEND_POINT:
		print("@ BEGAN MOVABLE TILE ANALYSIS")
		moveable_tiles = get_range_DFS(ai_unit.unit.movement,current_position, ai_unit.unit.movement_class, true)
		for moveable_tile in moveable_tiles:
			if moveable_tile not in _occupied_spaces:
				if not _astargrid.get_point_weight_scale(moveable_tile) > 999999:
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
					print("@ CREATING ACTIONABLE TILE LIST")
					print("@ OCCUPIED SPACES : " + str(_occupied_spaces))
					for targetable_unit_index: int in combat.groups[Constants.FACTION.PLAYERS]:
						for range in actionable_range:
							for tile in get_tiles_at_range_new(range,combat.combatants[targetable_unit_index].map_tile.position):
								if tile not in _occupied_spaces:
									if tile not in actionable_tiles:
										actionable_tiles.append(tile)
					print("@ FINISHED MOVE AND TARGET SEARCH, NO TARGET FOUND")
					var closet_action_tile
					var _astar_closet_distance = 99999
					var closet_tile_in_range_to_action_tile
					for tile in actionable_tiles:
						if _astargrid.is_in_boundsv(tile):
							var _astar_path = _astargrid.get_point_path(current_position,tile)
							if _astar_path:
								var _astar_distance = astar_path_distance(_astar_path)
								if _astar_distance < _astar_closet_distance and _astar_distance != null:
									closet_action_tile = tile
									_astar_closet_distance = _astar_distance
					print("@ FOUND CLOSET ACTIONABLE TILE : [" + str(closet_action_tile) + "]")
					if closet_action_tile != null: 
						if not _astargrid.get_point_weight_scale(closet_action_tile) > 999999:
							if closet_action_tile != Vector2(current_position):
								if closet_action_tile in moveable_tiles:
									ai_move(closet_action_tile)
									called_move = true
								else:
									print("@ MOVEABLE TILES : [" + str(moveable_tiles) + "]")
									var _astar_closet_move_tile_distance_to_action  = 99999
									for moveable_tile in moveable_tiles: 
										if moveable_tile not in _occupied_spaces:
											if _astargrid.is_in_boundsv(moveable_tile):
												var _astar_path = _astargrid.get_id_path(moveable_tile,closet_action_tile)
												if _astar_path:
													var _astar_distance = astar_path_distance(_astar_path)
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
	ai_unit.map_terrain = get_terrain_at_position(controlled_node.position)
	ai_unit.map_tile.position = tile_map.local_to_map(controlled_node.position)
	return selected_action

func ai_get_best_move_at_tile(ai_unit: CombatUnit, tile_position: Vector2i, attack_range: Array[int]) -> aiAction:
	#print("@ ENTERED ai_get_best_move_at_tile")
	#are there targets?
	var tile_best_action: aiAction = aiAction.new()
	tile_best_action.action_type = "NONE"
	tile_best_action.rating = 0
	for range in attack_range:
		for tile in get_tiles_at_range_new(range,tile_position):
			if get_combatant_at_position(tile) != null:
				if get_combatant_at_position(tile).allegience == Constants.FACTION.PLAYERS:
					if not ai_unit.unit.get_usable_weapons_at_range(range).is_empty():
						if get_terrain_at_map_position(tile):
							var best_action_target : aiAction = combat.ai_get_best_attack_action(ai_unit, get_distance(tile, tile_position), get_combatant_at_position(tile), get_terrain_at_map_position(tile))
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
	var current_position = tile_map.local_to_map(controlled_node.position)
	find_path(target_position)
	move_on_path(current_position)

func ai_turn ():
	_in_ai_process = true
	var enemy_units  = combat.get_ai_units()
	for unit :CombatUnit in enemy_units:
		print("Began AI processing unit : "+ unit.unit.unit_name)
		set_controlled_combatant(unit)
		await combat.ai_process_new(unit)
		print("finished Processing Unit : " + unit.unit.unit_name)
	_enemy_units_turn_taken = true
	print("finished AI Turn")
	_in_ai_process = false

#Getter & Setters
func set_selected_skill(skill: String):
	_selected_skill = skill

func set_selected_item(item: ItemDefinition):
	_selected_item = item

func set_unit_action(action: UnitAction):
	_action = action

func set_movement(value):
	movement = value
	movement_changed.emit(value)

func set_controlled_combatant(combatant: CombatUnit):
	#combat.get_current_combatant() = combatant
	combat.set_current_combatant(combatant)
	controlled_node = combatant.map_display
	movement = combatant.effective_move
	update_points_weight()

func perform_shove(pushed_unit: CombatUnit, push_vector:Vector2i):
	var target_tile = pushed_unit.map_tile.position + push_vector;
	if not _blocking_spaces[pushed_unit.unit.movement_class].has(target_tile):
		if not _occupied_spaces.has(target_tile):
			if get_tile_cost(target_tile, pushed_unit) < 99999:
				set_controlled_combatant(pushed_unit)
				find_path(target_tile)
				move_player()
				await finished_move
				pushed_unit.map_tile.position = target_tile
				pushed_unit.map_tile.terrain = get_terrain_at_map_position(target_tile)
				combat.complete_shove()

func trigger_reinforcements():
	combat.spawn_reinforcements(turn_count)

func update_player_state(new_state : Constants.PLAYER_STATE):
	previous_player_state = player_state
	player_state = new_state

func update_turn_phase(new_state : Constants.TURN_PHASE):
	print("$$ CALLED UPDATE TURN PHASE : With target turn phase : " + str(new_state))
	if new_state != turn_phase:
		previous_turn_phase = turn_phase
		turn_phase = new_state
	else: 
		print("$$ CALLED UPDATE TURN PHASE : With current turn phase")

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
