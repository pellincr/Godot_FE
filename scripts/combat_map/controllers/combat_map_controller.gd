##
# Combat Controller, manages all the components used in the combat map
#
##
extends Node2D
class_name CombatMapController

##GRID CONST
const GRID_TEXTURE = preload("res://resources/sprites/grid/grid_marker_2.png")
const PATH_TEXTURE = preload("res://resources/sprites/grid/path_ellipse.png")

##Unit Action imports
const ATTACK_ACTION : UnitAction = preload("res://resources/definitions/actions/unit_action_attack.tres")
const WAIT_ACTION : UnitAction = preload("res://resources/definitions/actions/unit_action_wait.tres")
const TRADE_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_trade.tres")
const ITEM_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_inventory.tres")
const USE_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_use_item.tres")
const SUPPORT_ACTION : UnitAction =  preload("res://resources/definitions/actions/unit_action_support.tres")
const SHOVE_ACTION: UnitAction = preload("res://resources/definitions/actions/unit_action_shove.tres")
const CHEST_ACTION: UnitAction = preload("res://resources/definitions/actions/unit_action_chest.tres")

##Movement Constants
const MOVEMENT_SPEED = 96

##SIGNALS
signal movement_changed(movement: int)
signal finished_move(position: Vector2i)
signal target_selection_started()
signal target_selection_finished()
signal tile_info_updated(tile : Dictionary)
signal target_detailed_info(combat_unit : CombatUnit)

##SM variables 
@export var seed : int 
var turn_count : int 
var turn_order : Array[CombatMapConstants.FACTION] = [CombatMapConstants.FACTION.PLAYERS, CombatMapConstants.FACTION.ENEMIES]
var turn_order_index : int = 0
var turn_owner : CombatMapConstants.FACTION =  CombatMapConstants.FACTION.NULL
var player_factions :  Array[CombatMapConstants.FACTION] = [CombatMapConstants.FACTION.PLAYERS]

var game_state: CombatMapConstants.COMBAT_MAP_STATE #= CombatMapConstants.COMBAT_MAP_STATE.INITIALIZING
var turn_phase: CombatMapConstants.TURN_PHASE #= CombatMapConstants.TURN_PHASE.INITIALIZING
var previous_turn_phase: CombatMapConstants.TURN_PHASE #= CombatMapConstants.TURN_PHASE.INITIALIZING
var previous_player_state : CombatMapConstants.PLAYER_STATE
var player_state: CombatMapConstants.PLAYER_STATE #= CombatMapConstants.PLAYER_STATE.INITIALIZING

##Controller Mains
@export var controlled_node : Control
@export var combat: Combat 
var grid: CombatMapGrid
var camera: CombatCamera

## Selector/Cursor
@export var selector : AnimatedSprite2D

##Player Interaction Variables 
var unit_detail_open : bool = false
var map_focused : bool = true

var current_tile_position: Vector2i
var current_tile_info : MapTile = MapTile.new()

var selected_tile_position: Vector2i
var selected_tile_info : MapTile = MapTile.new()

var targeted_tile_position: Vector2i
var targeted_tile_info : MapTile = MapTile.new()

##Movement Variables
var _arrived = true
var _path : Array[Vector2i] #PackedVector2Array
var _next_position
var _previous_position : Vector2i
var _position_id = 0
var movement = 0: #Selected unit's remaining movement
	set = set_movement,
	get = get_movement
var default_move_speed = MOVEMENT_SPEED*5
var return_move_speed = MOVEMENT_SPEED*5
var move_speed = default_move_speed

##Action Select
var _available_actions : Array[UnitAction]
var _action: UnitAction
var _action_selected: bool

##Action Variables
var _action_target_unit : CombatUnit
var _action_target_unit_selected : bool = false # is this redundant? 
var _unit_action_completed : bool = false
var _unit_action_initiated : bool = false
var _action_tiles : Array[Vector2i]#PackedVector2Array
var _action_valid_targets : Array[CombatUnit]
var _action_queue: Array 

##Item Selection Variables
var _selected_item: ItemDefinition
var _selected_entity: CombatMapEntity
var _item_selected: bool

##AI Variables
var _in_ai_process: bool = false
var _enemy_units_turn_taken: bool = false

##Drawing Variables
var move_range : Array[Vector2i] #PackedVector2Array
var attack_range : Array[Vector2i] #PackedVector2Array
var skill_range : Array[Vector2i] #PackedVector2Array 


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
	camera = CombatCamera.new()
	##Assign created variables to create place in the scene tree
	self.add_child(grid)
	self.add_child(camera)
	##Auto Wire combat signals for modularity
	combat.connect("perform_shove", perform_shove)
	combat.connect("combatant_added", combatant_added)
	combat.connect("combatant_died", combatant_died)
	combat.connect("major_action_completed", _on_visual_combat_major_action_completed)
	combat.connect("minor_action_completed", _on_visual_combat_minor_action_completed)
	combat.connect("turn_advanced", advance_turn)
	##Init & Populate dynamically created nodes
	await camera.init()
	await combat.create_combatants()
	await combat.load_entities()
	##Prepare to transition to player turn and handle player input
	current_tile_position = combat.combatants[combat.groups[0].front()].map_position
	camera.centerCameraCenter(grid.map_to_position(current_tile_position))
	selector.position = grid.map_to_position(current_tile_position)
	##Set the correct states to begin FSM flow
	game_state = CombatMapConstants.GAME_STATE.PLAYER_TURN
	turn_owner = CombatMapConstants.FACTION.PLAYERS

#	if Input.is_action_just_pressed("ui_accept"):	
#func process_ui_confirm_inputs(delta):
	#if game_state == Constants.GAME_STATE.PLAYER_TURN:
		#if turn_phase == Constants.TURN_PHASE.MAIN_PHASE:
			#if player_state == Constants.PLAYER_STATE.UNIT_SELECT:
				###Player selects a unit
				#var selected_unit = grid.get_combat_unit(current_tile_position)
				#if selected_unit and selected_unit.alive and !selected_unit.turn_taken: 
					#combat.game_ui.hide_end_turn_button()
					#combat.game_ui.play_menu_confirm()
					#set_controlled_combatant(selected_unit)
					#if selected_unit.allegience == 0:
						#update_player_state(Constants.PLAYER_STATE.UNIT_MOVEMENT)
			#elif player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT:
				#combat.game_ui.play_menu_confirm()
				### Players selects a move
				#if _arrived == true:
					#if current_tile_position != combat.get_current_combatant().map_position:
						#if grid.is_map_position_available_for_unit_move(current_tile_position, combat.get_current_combatant().unit.movement_class):
							#move_player()
					#else :
						#combat.get_current_combatant().move_position = combat.get_current_combatant().map_position
						#combat.get_current_combatant().move_terrain = grid.get_terrain(combat.get_current_combatant().map_position)
						#combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
						#update_player_state(Constants.PLAYER_STATE.UNIT_ACTION_SELECT)
					#if _arrived == true:
						#find_path(current_tile_position)
						#var comb = grid.get_combat_unit(current_tile_position)
						#var local_map = grid.map_to_position(current_tile_position)
						#get_tile_info(current_tile_position)
						#if comb != null:	
							#if comb.allegience == 1 and comb.alive:
								#_attack_target_position = local_map
							#else:
								#_attack_target_position = null
								#_blocked_target_position = local_map
						#elif grid.is_unit_blocked(current_tile_position, combat.get_current_combatant().unit.movement_class):
							#_blocked_target_position = local_map
						#else:
							#_attack_target_position = null
							#_blocked_target_position = null
			#elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT:
				#pass
			#elif player_state == Constants.PLAYER_STATE.UNIT_ACTION: 
				#pass
			#elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_OPTION_SELECT:
				#pass
			#elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
				#pass
			#elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
				#if _action_selected == true and _action.requires_target == true:
					###Targeting
					#var comb = grid.get_combat_unit(current_tile_position)
					#if comb != null and comb.alive:
						#if _action_valid_targets.has(comb):
							#combat.game_ui.hide_unit_combat_exchange_preview()
							#combat.get_current_combatant().map_position = combat.get_current_combatant().move_position
							#combat.get_current_combatant().map_terrain = grid.get_terrain(combat.get_current_combatant().map_position)
							#action_target_selected(comb)
						#else:
							#print("Invalid Target")
							#comb = null
							#pass

#func process_ui_cancel_inputs(delta):
	#if game_state == Constants.GAME_STATE.PLAYER_TURN:
		#if turn_phase == Constants.TURN_PHASE.MAIN_PHASE:
			#if player_state == Constants.PLAYER_STATE.UNIT_SELECT:
				#if unit_detail_open:
					#target_detailed_info.emit(null)
					#unit_detail_open = false
			#elif player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT:
				#clear_combatant_ranges()
				#_action_tiles.clear()
				#update_player_state(Constants.PLAYER_STATE.UNIT_SELECT)
			#elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT:
				#combat.game_ui.play_menu_back()
				#if (_arrived):
					#combat.game_ui.hide_action_list()
					###MOVE THE UNIT BACK 
					#if combat.get_current_combatant().map_position != combat.get_current_combatant().move_position:
						#find_path(combat.get_current_combatant().map_position)
						#return_player()
					#else : 
						##finished_move.emit()
						#_arrived = true
						#movement = combat.get_current_combatant().unit.movement
						#update_player_state(Constants.PLAYER_STATE.UNIT_MOVEMENT)
			#elif player_state == Constants.PLAYER_STATE.UNIT_ACTION: 
				#combat.complete_trade()
			#elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_OPTION_SELECT:
				#if(_action == ITEM_ACTION):
					#combat.game_ui.remove_inventory_options_container()
					#combat.game_ui.enable_inventory_list_butttons()
				#revert_action_flow()
			#elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
				#combat.game_ui.hide_attack_action_inventory()
				#revert_action_flow()
			#elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
				#combat.game_ui.play_menu_back()
				#combat.game_ui.hide_unit_combat_exchange_preview()
				#revert_action_flow()
		#else :
			#return
#
#func process_ui_info_inputs(delta):
	#if game_state == Constants.GAME_STATE.PLAYER_TURN:
		#if turn_phase == Constants.TURN_PHASE.MAIN_PHASE:
			#var mouse_position = get_global_mouse_position()
			#var map_position = grid.position_to_map(mouse_position)
			#get_tile_info(map_position)
			#if player_state == Constants.PLAYER_STATE.UNIT_SELECT:
				#var comb = grid.get_combat_unit(map_position)
				#if comb != null and comb.alive:
					#if unit_detail_open == false:
						#target_detailed_info.emit(comb)
						#unit_detail_open = true
	
##Processes user input if not on a menu
func _unhandled_input(event):
	pass
	## Player Turn
	#if game_state == Constants.GAME_STATE.PLAYER_TURN:
		#if turn_phase == Constants.TURN_PHASE.MAIN_PHASE:
			#var mouse_position = get_global_mouse_position()
			#var map_position = grid.position_to_map(mouse_position)
			#get_tile_info(map_position)
			#if player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT:
				#if event is InputEventMouseMotion:
					#if _arrived == true:
						#find_path(map_position)
						#var comb = grid.get_combat_unit(map_position)
						#var local_map = grid.map_to_position(map_position)
						#grid.get_map_tile(map_position)
						#if comb != null:	
							#if comb.allegience == 1 and comb.alive:
								#_attack_target_position = local_map
							#else:
								#_attack_target_position = null
								#_blocked_target_position = local_map
						#elif grid.is_unit_blocked(map_position, combat.get_current_combatant().unit.movement_class):
							#_blocked_target_position = local_map
						#else:
							#_attack_target_position = null
							#_blocked_target_position = null

#process called on frame
func _process(delta):
	if Input: ##MOVE THIS TO EACH STATE WHERE APPLICABLE
		if Input.is_action_just_pressed("map_confirm"):
			pass
			##process_ui_confirm_inputs(delta)
		elif Input.is_action_just_pressed("map_cancel"):
			pass
			##process_ui_cancel_inputs(delta)
		elif Input.is_action_just_pressed("ui_select"):
			pass
			##process_ui_info_inputs(delta)
		elif Input.is_action_just_pressed("combat_map_up"):
			update_current_tile(current_tile_position + Vector2i.UP)
		elif Input.is_action_just_pressed("combat_map_left"):
			update_current_tile(current_tile_position + Vector2i.LEFT)
		elif Input.is_action_just_pressed("combat_map_right"):
			update_current_tile(current_tile_position + Vector2i.RIGHT)
		elif Input.is_action_just_pressed("combat_map_down"):
			update_current_tile(current_tile_position + Vector2i.DOWN)
		camera.SimpleFollow(delta)
	queue_redraw()
	if game_state == (CombatMapConstants.GAME_STATE.PLAYER_TURN or CombatMapConstants.GAME_STATE.AI_TURN) :
		if turn_phase == CombatMapConstants.TURN_PHASE.INITIALIZING : 
			_turn_phase_init_enter()
			update_turn_phase(CombatMapConstants.TURN_PHASE.BEGINNING_PHASE)
		elif turn_phase == CombatMapConstants.TURN_PHASE.BEGINNING_PHASE :
			#await ui.play_turn_banner(turn_owner)
			await process_terrain_effects()
			# await process_skill_effects()
			# await clean_up
			# await spawn reinforcements()
			update_turn_phase(CombatMapConstants.TURN_PHASE.MAIN_PHASE)
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		elif turn_phase == CombatMapConstants.TURN_PHASE.MAIN_PHASE :
			##ALL USER INTERACTION HAPPENS DURING "PLAYER_TURN", for future proofing for multiple player controlled factions dictate player input by using turn_owner
			if game_state == CombatMapConstants.GAME_STATE.PLAYER_TURN : 
				process_player_main_phase(delta)
			## ALL AI CALCULATIONS AND ACTIONS HAPPEN ON AI TURN
			elif game_state == CombatMapConstants.GAME_STATE.AI_TURN :
				combat.game_ui.hide_end_turn_button()
				if _in_ai_process:
					pass
				else : 
					if not _enemy_units_turn_taken:
						ai_turn()
					else :
						print("moved to enemy end phase")
						update_turn_phase(CombatMapConstants.TURN_PHASE.ENDING_PHASE)
		elif(turn_phase == CombatMapConstants.TURN_PHASE.ENDING_PHASE):
			if game_state == CombatMapConstants.GAME_STATE.PLAYER_TURN : 
				pass
			elif game_state == CombatMapConstants.GAME_STATE.AI_TURN :
				print("Enemy Ended Turn")
				_in_ai_process = false
				_enemy_units_turn_taken = false
			#await clean_up()
			#await terrain_effects()
			await trigger_reinforcements() ## TO BE IMPLEMENTED TURN OWNER & TURN PHASE
			turn_order_index = CustomUtilityLibrary.array_next_index_with_loop(turn_order, turn_order_index)
			turn_owner = turn_order[turn_order_index]
			combat.advance_turn(turn_owner)
			if turn_owner in player_factions:
				game_state = CombatMapConstants.GAME_STATE.PLAYER_TURN
			else : 
				game_state = CombatMapConstants.GAME_STATE.AI_TURN 
			#All players have completed their turns, and order resets
			if turn_order_index == 0:
				turn_count += 1
			update_turn_phase(CombatMapConstants.TURN_PHASE.BEGINNING_PHASE)
	##Game Processing phase: Movement, animations, etc.
	elif game_state == CombatMapConstants.GAME_STATE.PROCESSING:
		#Move Unit Code
		if _arrived == false:
			process_unit_move(delta)

#Method intakes end_turn signal from UI and updates controller & child nodes
func advance_turn():
	pass
	#update_turn_phase(Constants.TURN_PHASE.ENDING_PHASE)
	#combat.advance_turn(Constants.FACTION.PLAYERS)

#Method calls entity manager to add a new CombatMapEntity to grid
func add_entity(cme: CombatMapEntity): ##REDUNDANT? TO BE REMOVED?
	grid.set_entity(cme, cme.position)

#Adds a new combat unit byu calling combat unit manager
func add_combat_unit(combatant: CombatUnit): ##REDUNDANT? TO BE REMOVED?
	grid.set_combat_unit(combatant, combatant.map_position)

#Connected via signal, this is called when a combat unit has died
func combatant_died(combatant: CombatUnit):
	grid.combat_unit_died(combatant.map_position)
	combatant.map_display.queue_free()

#Connected via signal, this is called when an entity is disabled
func entity_disabled(e :CombatMapEntity): ##Update this? & flush the entity @ that position?
	grid.update_blocking_space_at_tile(e.position)

# get the selected movement, this value is what the current unit has remaining and is used to calculated move options
func get_movement():
	return movement

func find_path(tile_position: Vector2i):
	_path.clear()
	_path.append_array(grid.find_path(tile_position))
	#queue_redraw()

func move_player():
	move_speed = default_move_speed
	var current_position = grid.position_to_map(controlled_node.position)
	combat.get_current_combatant().move_position = current_position
	combat.get_current_combatant().move_terrain = grid.get_terrain(current_position)
	var _path_size = _path.size()
	if _path_size > 1 and movement > 0:
		move_on_path(current_position)

func return_player():
	move_speed = return_move_speed
	var original_position = combat.get_current_combatant().map_position
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
	update_turn_phase(CombatMapConstants.GAME_STATE.PROCESSING)
	#queue_redraw()
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
		combat.get_current_combatant().map_position = combat.get_current_combatant().move_position
		combat.get_current_combatant().map_terrain =  grid.get_terrain(combat.get_current_combatant().map_position)

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
			_selected_entity = grid.get_entity(combat.get_current_combatant().move_position)
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
	combat.get_current_combatant().map_position = combat.get_current_combatant().move_position
	combat.get_current_combatant().map_terrain = grid.get_terrain(combat.get_current_combatant().move_position)
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

#draw the area
func _draw():
	if(game_state == Constants.GAME_STATE.PLAYER_TURN):
		if(player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT):
			if(combat.get_current_combatant()):
				draw_ranges(move_range, true, attack_range,true, skill_range, true)
				drawSelectedpath()
		elif(player_state == Constants.PLAYER_STATE.UNIT_SELECT):
			if(combat.get_current_combatant()):
				pass
				draw_ranges(move_range, true, attack_range,true, skill_range, true)
		if(player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT):
			draw_action_tiles(_action_tiles, _action)

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
	if position != current_tile_position:
		current_tile_info = grid.get_map_tile(position)
		current_tile_position = position
		selector.position = grid.map_to_position(current_tile_position)

func clear_combatant_ranges():
	attack_range.clear()
	skill_range.clear()
	move_range.clear()
	
func calculate_combatant_ranges(combatant: CombatUnit) :
	clear_combatant_ranges()
	move_range = grid.get_range_DFS(combatant.unit.movement, combatant.map_position, combatant.unit.movement_class, true)
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
		if grid.get_combat_unit(tile) :
			if(grid.get_combat_unit(tile).allegience != cu.allegience) :
				response.append(grid.get_combat_unit(tile))
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
		if grid.get_combat_unit(tile) :
			if(grid.get_combat_unit(tile).allegience == cu.allegience and grid.get_combat_unit(tile) != cu) :
				response.append(grid.get_combat_unit(tile))
	return response
	
func get_potential_shove_targets(cu: CombatUnit) -> Array[CombatUnit]:
	var pushable_targets : Array[CombatUnit]
	for tile in grid.get_target_tile_neighbors(cu.move_position):
		if grid.get_combat_unit(tile) :
			var pushable_unit :CombatUnit = grid.get_combat_unit(tile)
			var push_vector : Vector2i  = Vector2i(tile) - Vector2i(cu.move_position)
			var target_tile : Vector2i = Vector2i(tile) + push_vector;
			if grid.is_map_position_available_for_unit_move(target_tile, pushable_unit.unit.movement_class):
				if grid.get_tile_cost(target_tile, pushable_unit.unit.movement_class) < 99999:
					pushable_targets.append(pushable_unit)
	return pushable_targets

func get_viable_chest_items(cu: CombatUnit) -> Array[ItemDefinition]:
	var _items : Array[ItemDefinition]
	if grid.get_entity(cu.move_position) :
		var _entity = grid.get_entity(cu.move_position)
		if _entity is CombatMapChestEntity:
			for item : ItemDefinition in _entity.required_item:
				if cu.unit.inventory.has(item):
					_items.append(item)
					#TO BE IMPLEMENTED if unit can use item
	return _items

func chest_action_available(cu:CombatUnit)-> bool:
	if grid.get_entity(cu.move_position) :
		var _entity = grid.get_entity(cu.move_position)
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
		if cu.move_position:
			attackable_tiles.append_array(grid.get_tiles_at_range_new(range, cu.move_position))
	return attackable_tiles

func process_terrain_effects():
	for combat_unit in combat.combatants:
		if combat not in combat.dead_units:
			if (combat_unit.allegience == Constants.FACTION.PLAYERS and game_state == Constants.GAME_STATE.PLAYER_TURN) or (combat_unit.allegience == Constants.FACTION.ENEMIES and game_state == Constants.GAME_STATE.ENEMY_TURN):
				if grid.get_terrain(combat_unit.map_position): 
					var target_terrain = grid.get_terrain(combat_unit.map_position)
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
	
## AI METHODS##
func ai_process_new(ai_unit: CombatUnit) -> aiAction:
	print("Entered ai_process in cController.gd")
	#find nearest non-solid tile to target_position
	#Get Attack Range to see what are "attackable tiles"	
	grid.update_astar_points(ai_unit) #Is this redundant? 
	var current_position = grid.position_to_map(controlled_node.position)
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
							var _astar_path = grid.find_path(current_position,tile)
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
									if closet_tile_in_range_to_action_tile && closet_tile_in_range_to_action_tile !=  Vector2(current_position):
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
	ai_unit.map_terrain = grid.get_terrain(controlled_node.position)
	ai_unit.map_position = grid.position_to_map(controlled_node.position)
	return selected_action

func ai_get_best_move_at_tile(ai_unit: CombatUnit, tile_position: Vector2i, attack_range: Array[int]) -> aiAction:
	#print("@ ENTERED ai_get_best_move_at_tile")
	#are there targets?
	var tile_best_action: aiAction = aiAction.new()
	tile_best_action.action_type = "NONE"
	tile_best_action.rating = 0
	for range in attack_range:
		for tile in grid.get_tiles_at_range_new(range,tile_position):
			if grid.get_combat_unit(tile) != null:
				if grid.get_combat_unit(tile).allegience == Constants.FACTION.PLAYERS:
					if not ai_unit.unit.get_usable_weapons_at_range(range).is_empty():
						if grid.get_terrain(tile):
							var best_action_target : aiAction = combat.ai_get_best_attack_action(ai_unit, CustomUtilityLibrary.get_distance(tile, tile_position), grid.get_combat_unit(tile), grid.get_terrain(tile))
							best_action_target.target_position = tile
							best_action_target.action_position = tile_position
							if tile_best_action.rating < best_action_target.rating:
								tile_best_action = best_action_target
	#print("@ EXITED ai_get_best_move_at_tile")
	return tile_best_action

func ai_move(target_position: Vector2i):
	print("@ AI MOVE CALLED @ : "+ str(target_position))
	var current_position = grid.position_to_map(controlled_node.position)
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

##DRAWING METHODS##
func drawSelectedpath():
	if _arrived == true and game_state == Constants.GAME_STATE.PLAYER_TURN:
		var path_length = movement
		#Get the length of the path
		for i in range(_path.size()):
			var point = _path[i]
			var draw_color = Color.TRANSPARENT
			if grid.is_unit_blocked(point, combat.get_current_combatant().unit.movement_class):
				draw_color = Color.DIM_GRAY
				if path_length - grid.get_tile_cost(grid.position_to_map(point), combat.get_current_combatant().unit.movement_class) >= 0:
					draw_color = Color.WHITE
				if i > 0:
					path_length -= grid.get_tile_cost_(grid.position_to_map(point), combat.get_current_combatant().unit.movement_class)
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

##GETTERS & SETTERS ##

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
	grid.update_astar_points(combatant)

func perform_shove(pushed_unit: CombatUnit, push_vector:Vector2i):
	var target_tile = pushed_unit.map_position + push_vector;
	if grid.is_map_position_available_for_unit_move(target_tile,pushed_unit.unit.movement_class):
		if grid.get_tile_cost(target_tile, pushed_unit.unit.movement_class) < 99999:
			set_controlled_combatant(pushed_unit)
			find_path(target_tile)
			move_player()
			await finished_move
			pushed_unit.map_position = target_tile
			pushed_unit.map_terrain = grid.get_terrain(target_tile)
			combat.complete_shove()

func trigger_reinforcements():
	#unit_manager.spawn_reinforcements(turn_count, turn_owner, turn_phase)
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

func update_current_tile(position : Vector2i):
	if grid.is_valid_tile(position):
		get_tile_info(position)
		selector.position = grid.map_to_position(current_tile_position)
		combat.game_ui._set_tile_info(current_tile_info)


#Called in the state machine on the enter of the INIT state of the turn phase
func _turn_phase_init_enter():
	combat.game_ui.hide_end_turn_button()
	
##
# Called on frame and is used to handle user interaction during the player's main phase
##
func process_player_main_phase(delta):
	combat.game_ui._set_tile_info(current_tile_info)
	if player_state == CombatMapConstants.PLAYER_STATE.UNIT_SELECT:
		combat.game_ui.show_end_turn_button()
	if player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT:
		combat.game_ui.hide_end_turn_button()
	elif player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION:
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
			update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_SELECT)
		else :
			print("action state is hanging?")
	elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
		pass
	elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
		combat.game_ui.hide_end_turn_button()
		var mouse_position = get_global_mouse_position()
		var map_position = grid.position_to_map(mouse_position)
		var comb = grid.get_combat_unit(map_position)
		if comb != null and comb.alive:
			if _action_valid_targets.has(comb):
				if _action == ATTACK_ACTION:
					combat.game_ui.display_unit_combat_exchange_preview(combat.get_current_combatant(), comb,  CustomUtilityLibrary.get_distance(combat.get_current_combatant().move_position, comb.map_position))
				elif _action == SUPPORT_ACTION:
					pass
				return
		combat.game_ui.hide_unit_combat_exchange_preview()

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
			movement -= tile_cost
			#Can the unit move to the next tile in the path?
			if (_position_id < _path.size() - 1) and movement > 0 and (next_tile_cost <= movement):
				_position_id += 1
				_next_position = _path[_position_id]
			else:
				update_turn_phase(previous_turn_phase)
				_arrived = true
				finished_move.emit(new_position) #EMIT THIS LAST
				if game_state == CombatMapConstants.GAME_STATE.PLAYER_TURN:
					if(player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT) :
						#Move complete on action select (cancelled move)
						#remove old space from occupied spaces
						##_astargrid.set_point_weight_scale(combat.get_current_combatant().move_tile.position, 1) ##REMOVED ALSO SEEMS REDUNDANT VERIFY
						movement = combat.get_current_combatant().unit.movement
						update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT)
					elif(player_state == CombatMapConstants.PLAYER_STATE.UNIT_MOVEMENT):
						combat.get_current_combatant().move_position = new_position
						combat.get_current_combatant().move_terrain = grid.get_terrain(new_position)
						combat.game_ui.set_action_list(get_available_unit_actions(combat.get_current_combatant()))
						update_player_state(CombatMapConstants.PLAYER_STATE.UNIT_ACTION_SELECT)
					elif(player_state == CombatMapConstants.PLAYER_STATE.UNIT_ACTION):
						combat.get_current_combatant().move_position = new_position
						combat.get_current_combatant().move_terrain = grid.get_terrain(new_position)
