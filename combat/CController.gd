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
var grid: CombatMapGrid

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

#Player Variables
var current_tile_position: Vector2i

#SM variables 
var game_state: Constants.GAME_STATE = Constants.GAME_STATE.INITIALIZING
var turn_phase: Constants.TURN_PHASE = Constants.TURN_PHASE.INIT
var previous_turn_phase: Constants.TURN_PHASE = Constants.TURN_PHASE.INIT
var previous_player_state : Constants.PLAYER_STATE = Constants.PLAYER_STATE.INIT
var player_state: Constants.PLAYER_STATE = Constants.PLAYER_STATE.INIT

#Turn Info
var turn_count : int = 1

func _ready():
	#tile_map = get_node("../../Terrain/TileMap")
	#Auto Wire combat signals for modularity
	combat.connect("perform_shove", perform_shove)
	combat.connect("combatant_added", combatant_added)
	combat.connect("combatant_died", combatant_died)
	combat.connect("major_action_completed", _on_visual_combat_major_action_completed)
	combat.connect("minor_action_completed", _on_visual_combat_minor_action_completed)
	combat.connect("turn_advanced", advance_turn)
	#combat.combatExchange.connect("combat_exchange_finished", _on_combat)
	##SET GRID ENTITIES AND INFO HERE
	#Once Game initialization is complete begin player turn
	game_state = Constants.GAME_STATE.PLAYER_TURN
	print("VECTOR TO STRING : " + str(Vector2i(0,0)))

#	if Input.is_action_just_pressed("ui_accept"):	
func process_ui_confirm_inputs(delta):
	if game_state == Constants.GAME_STATE.PLAYER_TURN:
		if turn_phase == Constants.TURN_PHASE.MAIN_PHASE:
			var mouse_position = get_global_mouse_position()
			var map_position = grid.get_tile_info(mouse_position)
			if player_state == Constants.PLAYER_STATE.UNIT_SELECT:
				##Player selects a unit
				var selected_unit = grid.get_combat_unit_at_position(map_position)
				if selected_unit and selected_unit.alive and !selected_unit.turn_taken: 
					combat.game_ui.hide_end_turn_button()
					combat.game_ui.play_menu_confirm()
					set_controlled_combatant(selected_unit)
					if selected_unit.allegience == 0:
						update_player_state(Constants.PLAYER_STATE.UNIT_MOVEMENT)
			elif player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT:
				combat.game_ui.play_menu_confirm()
				## Players selects a move
				if _arrived == true:
					if map_position != combat.get_current_combatant().map_tile.position:
						if grid.is_valid_move_map_position(map_position, combat.get_current_combatant().unit.movement_class):
							move_player()
					else :
						combat.get_current_combatant().move_tile.position = combat.get_current_combatant().map_tile.position
						combat.get_current_combatant().move_tile.terrain = combat.get_current_combatant().map_tile.terrain
						combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
						update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_SELECT)
					if _arrived == true:
						find_path(map_position)
						var comb = grid.get_combat_unit_at_position(map_position)
						var local_map = tile_map.map_to_local(map_position)
						get_tile_info(map_position)
						if comb != null:	
							if comb.allegience == 1 and comb.alive:
								_attack_target_position = local_map
							else:
								_attack_target_position = null
								_blocked_target_position = local_map
						elif grid.is_unit_blocked(map_position, combat.get_current_combatant().unit.movement_class):
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
					var comb = grid.get_combat_unit_at_position(map_position)
					if comb != null and comb.alive:
						if _action_valid_targets.has(comb):
							combat.game_ui.hide_unit_combat_exchange_preview()
							combat.get_current_combatant().map_tile.position = combat.get_current_combatant().move_tile.position
							combat.get_current_combatant().map_tile.terrain = grid.get_terrain_at_map_position(combat.get_current_combatant().map_tile.position)
							action_target_selected(comb)
						else:
							print("Invalid Target")
							comb = null
							pass

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
				clear_combatant_ranges()
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
				var comb = grid.get_combat_unit_at_position(mouse_position_i)
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
			var map_position = tile_map.local_to_map(mouse_position)
			get_tile_info(map_position)
			if player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT:
				if event is InputEventMouseMotion:
					if _arrived == true:
						find_path(map_position)
						var comb = grid.get_combat_unit_at_position(map_position)
						var local_map = tile_map.map_to_local(map_position)
						grid.get_map_tile_at_map_position(map_position)
						if comb != null:	
							if comb.allegience == 1 and comb.alive:
								_attack_target_position = local_map
							else:
								_attack_target_position = null
								_blocked_target_position = local_map
						elif grid.is_unit_blocked(map_position, combat.get_current_combatant().unit.movement_class):
							_blocked_target_position = local_map
						else:
							_attack_target_position = null
							_blocked_target_position = null

#process called on frame
func _process(delta):
	if Input:
		if Input.is_action_just_pressed("map_confirm"):
			process_ui_confirm_inputs(delta)
		elif Input.is_action_just_pressed("map_cancel"):
			process_ui_cancel_inputs(delta)
		elif Input.is_action_just_pressed("ui_select"):
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
				var comb = grid.get_combat_unit_at_position(mouse_position_i)
				if comb != null and comb.alive:
					if _action_valid_targets.has(comb):
						if _action == ATTACK_ACTION:
							combat.game_ui.display_unit_combat_exchange_preview(combat.get_current_combatant(), comb,  CustomUtilityLibrary.get_distance(combat.get_current_combatant().move_tile.position, comb.map_tile.position))
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
				#CustomUtilityLibrary.erase_packedVector2Array(_occupied_spaces, _previous_position)
				##_astargrid.set_point_weight_scale(_previous_position, 1) ##REMOVED IT SEEMS REDUNDANT???
				var tile_cost = grid.get_tile_cost_at_point(_previous_position)
				controlled_node.position = _next_position
				var new_position: Vector2i = grid.position_to_map(_next_position)
				grid.combat_unit_moved(_previous_position, new_position)
				_previous_position = new_position
				#update_points_weight()
				var next_tile_cost = grid.get_tile_cost_at_point(new_position)
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
							##_astargrid.set_point_weight_scale(combat.get_current_combatant().move_tile.position, 1) ##REMOVED ALSO SEEMS REDUNDANT VERIFY
							movement = combat.get_current_combatant().unit.movement
							update_player_state(Constants.PLAYER_STATE.UNIT_MOVEMENT)
						elif(player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT):
							combat.get_current_combatant().move_tile.position = new_position
							combat.get_current_combatant().move_tile.terrain = grid.get_terrain_at_map_position(new_position)
							combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
							update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_SELECT)
						elif(player_state == Constants.PLAYER_STATE.UNIT_ACTION):
							combat.get_current_combatant().move_tile.position = new_position
							combat.get_current_combatant().move_tile.terrain = grid.get_terrain_at_map_position(new_position)
					elif game_state == Constants.GAME_STATE.ENEMY_TURN:
						##update_player_state(previous_player_state)
						pass

#draw the area
func _draw():
	if(game_state == Constants.GAME_STATE.PLAYER_TURN):
		if(player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT):
			if(combat.get_current_combatant()):
				draw_ranges(move_range, true, attack_range,true, skill_range, true)
				drawSelectedpath()
		elif(player_state == Constants.PLAYER_STATE.UNIT_SELECT):
			if(combat.get_current_combatant()):
				draw_ranges(move_range, true, attack_range,true, skill_range, true)
		if(player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT):
			draw_action_tiles(_action_tiles, _action)

#advance_the game turn
#connect to UI end turn
func advance_turn():
	update_turn_phase(Constants.TURN_PHASE.ENDING_PHASE)
	combat.advance_turn(Constants.FACTION.PLAYERS)

func entity_added(cme: CombatMapEntity):
	pass

func combatant_added(combatant: CombatUnit):
	pass

func combatant_died(combatant: CombatUnit):
	grid.combat_unit_died(combatant.map_position)
	combatant.map_display.queue_free()

func entity_disabled(e :CombatMapEntity): ##Update this? & flush the entity @ that position?
	grid.update_blocking_space_at_tile(e.position)

func get_movement():
	return movement

func find_path(tile_position: Vector2i):
	_path.clear()
	_path = grid.find_path(tile_position)
	queue_redraw()

func move_player():
	move_speed = default_move_speed
	var current_position = tile_map.local_to_map(controlled_node.position)
	combat.get_current_combatant().move_tile.position = current_position
	combat.get_current_combatant().move_tile.terrain = grid.get_terrain_at_map_position(current_position)
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
		combat.get_current_combatant().map_tile.terrain =  grid.get_terrain_at_map_position(combat.get_current_combatant().map_tile.position)

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
			_selected_entity = grid.get_entity_at_position(combat.get_current_combatant().move_tile.position)
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
	combat.get_current_combatant().map_tile.terrain = grid.get_terrain_at_map_position(combat.get_current_combatant().move_tile.position)
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

##Draw the path between the selected Combatant and the mouse cursor
func drawSelectedpath():
	if _arrived == true and player_turn == true:
		var path_length = movement
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

func get_tile_info(position : Vector2i): 
	##TO BE UPDATED
	tile_info_updated.emit(current_tile_info)

func clear_combatant_ranges():
	attack_range.clear()
	skill_range.clear()
	move_range.clear()
	
func calculate_combatant_ranges(combatant: CombatUnit) :
	clear_combatant_ranges()
	move_range = grid.get_range_DFS(combatant.unit.movement, combatant.map_tile.position, combatant.unit.movement_class, true)
	var edge_array = grid.find_edges(move_range)
	attack_range = grid.get_range_multi_origin_DFS(combatant.unit.inventory.get_available_attack_ranges().max(), edge_array)
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
		if grid.get_combat_unit_at_position(tile) :
			if(grid.get_combat_unit_at_position(tile).allegience != cu.allegience) :
				response.append(grid.get_combat_unit_at_position(tile))
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
		if grid.get_combat_unit_at_position(tile) :
			if(grid.get_combat_unit_at_position(tile).allegience == cu.allegience and grid.get_combat_unit_at_position(tile) != cu) :
				response.append(grid.get_combat_unit_at_position(tile))
	return response
	
func get_potential_shove_targets(cu: CombatUnit) -> Array[CombatUnit]:
	var pushable_targets : Array[CombatUnit]
	for tile in grid.get_target_tile_neighbors(cu.move_tile.position):
		if grid.get_combat_unit_at_position(tile) :
			var pushable_unit = grid.get_combat_unit_at_position(tile)
			var push_vector : Vector2i  = Vector2i(tile) - Vector2i(cu.move_tile.position)
			var target_tile : Vector2i = Vector2i(tile) + push_vector;
			if grid.is_map_position_available_for_unit_move(target_tile, pushable_unit.unit.movement_class):
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
	if grid.get_entity_at_position(cu.move_tile.position) :
		var _entity = grid.get_entity_at_position(cu.move_tile.position)
		if _entity is CombatMapChestEntity:
			for item : ItemDefinition in _entity.required_item:
				if cu.unit.inventory.has(item):
					_items.append(item)
					#TO BE IMPLEMENTED if unit can use item
	return _items

func chest_action_available(cu:CombatUnit)-> bool:
	if grid.get_entity_at_position(cu.move_tile.position) :
		var _entity = grid.get_entity_at_position(cu.move_tile.position)
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
			attackable_tiles.append_array(grid.get_tiles_at_range_new(range, cu.move_tile.position))
	return attackable_tiles

func process_terrain_effects():
	for combat_unit in combat.combatants:
		if combat not in combat.dead_units:
			if (combat_unit.allegience == Constants.FACTION.PLAYERS and game_state == Constants.GAME_STATE.PLAYER_TURN) or (combat_unit.allegience == Constants.FACTION.ENEMIES and game_state == Constants.GAME_STATE.ENEMY_TURN):
				if grid.get_terrain_at_map_position(combat_unit.map_tile.position): 
					var target_terrain = grid.get_terrain_at_map_position(combat_unit.map_tile.position)
					if target_terrain.active_effect_phases == Constants.TURN_PHASE.keys()[turn_phase]:
						if target_terrain.effect != Terrain.TERRAIN_EFFECTS.NONE:
							if target_terrain.effect == Terrain.TERRAIN_EFFECTS.HEAL:
								if combat_unit.unit.hp < combat_unit.unit.max_hp:
									print("HEALED UNIT : " + combat_unit.unit.unit_name)
									combat.combatExchange.heal_unit(combat_unit, target_terrain.effect_weight)

#TO DO OPTIMIZE THIS FUNCTION
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
	grid.update_astar_points() #Is this redundant? 
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
		moveable_tiles = grid.get_range_DFS(ai_unit.unit.movement,current_position, ai_unit.unit.movement_class, true)
		for moveable_tile in moveable_tiles:
			if !grid.is_position_occupied(moveable_tile):
				if not grid.get_point_weight_scale(moveable_tile) > 999999:
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
	ai_unit.map_terrain = grid.get_terrain_at_position(controlled_node.position)
	ai_unit.map_tile.position = tile_map.local_to_map(controlled_node.position)
	return selected_action

func ai_get_best_move_at_tile(ai_unit: CombatUnit, tile_position: Vector2i, attack_range: Array[int]) -> aiAction:
	#print("@ ENTERED ai_get_best_move_at_tile")
	#are there targets?
	var tile_best_action: aiAction = aiAction.new()
	tile_best_action.action_type = "NONE"
	tile_best_action.rating = 0
	for range in attack_range:
		for tile in grid.get_tiles_at_range_new(range,tile_position):
			if grid.get_combat_unit_at_position(tile) != null:
				if grid.get_combat_unit_at_position(tile).allegience == Constants.FACTION.PLAYERS:
					if not ai_unit.unit.get_usable_weapons_at_range(range).is_empty():
						if grid.get_terrain_at_map_position(tile):
							var best_action_target : aiAction = combat.ai_get_best_attack_action(ai_unit, CustomUtilityLibrary.get_distance(tile, tile_position), grid.get_combat_unit_at_position(tile), grid.get_terrain_at_map_position(tile))
							best_action_target.target_position = tile
							best_action_target.action_position = tile_position
							if tile_best_action.rating < best_action_target.rating:
								tile_best_action = best_action_target
	#print("@ EXITED ai_get_best_move_at_tile")
	return tile_best_action

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
	calculate_combatant_ranges(combatant)
	combat.set_current_combatant(combatant)
	controlled_node = combatant.map_display
	movement = combatant.effective_move
	grid.update_astar_points()

func perform_shove(pushed_unit: CombatUnit, push_vector:Vector2i):
	var target_tile = pushed_unit.map_tile.position + push_vector;
	if grid.is_map_position_available_for_unit_move(target_tile,pushed_unit.unit.movement_class):
		if grid.get_tile_cost(target_tile, pushed_unit) < 99999:
			set_controlled_combatant(pushed_unit)
			find_path(target_tile)
			move_player()
			await finished_move
			pushed_unit.map_tile.position = target_tile
			pushed_unit.map_tile.terrain = grid.get_terrain_at_map_position(target_tile)
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
