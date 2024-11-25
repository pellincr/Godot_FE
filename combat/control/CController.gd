##Class that controls the map and user input during the main game flow
extends Node2D
class_name CController

##CONST
const grid_tex = preload("res://resources/sprites/grid/grid_marker_2.png")
const path_tex = preload("res://resources/sprites/grid/path_ellipse.png")
	#ACTIONS
const attack_action : UnitAction = preload("res://resources/definitions/actions/unit_action_attack.tres")
const wait_action : UnitAction = preload("res://resources/definitions/actions/unit_action_wait.tres")
const trade_action : UnitAction =  preload("res://resources/definitions/actions/unit_action_trade.tres")
const item_action : UnitAction =  preload("res://resources/definitions/actions/unit_action_item.tres")
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
	"unit" = null,
	"terrain" = null
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
var _occupied_spaces : Array[Vector2i]
var _blocking_spaces = [ ##UPDATE THIS FOR ALL MOVEMENT TYPES
	[],#GENERIC
	[],#MOBILE
	[],#HEAVY
	[],#MOUNTED
	[]#FLYING
]
var movement = 0:
	set = set_movement,
	get = get_movement

var _astargrid = AStarGrid2D.new()

var player_turn = true

var _attack_target_position
var _blocked_target_position
var _arrived = true

var _path : PackedVector2Array

var _next_position

var _position_id = 0

var move_speed = 192 #96 default

var _previous_position : Vector2i


var _selected_skill: String

var _selected_unit : CombatUnit
var _action_target_unit : CombatUnit
var _action_target_unit_selected : bool = false

var _unit_action_completed : bool = false
var _unit_action_initiated : bool = false
var _available_actions : Array[UnitAction]
var _action: UnitAction
var _action_selected: bool
var _action_tiles : PackedVector2Array
var _action_valid_targets : Array[CombatUnit]

var _selected_item: ItemDefinition
var _item_selected: bool

var _in_ai_process: bool = false
var _enemy_units_turn_taken: bool = false

var move_range : PackedVector2Array
var attack_range : PackedVector2Array
var skill_range : PackedVector2Array 

var game_state: Constants.GAME_STATE = Constants.GAME_STATE.INITIALIZING
var turn_phase: Constants.TURN_PHASE = Constants.TURN_PHASE.INIT
var player_state: Constants.PLAYER_STATE = Constants.PLAYER_STATE.INIT

func _ready():
	tile_map = get_node("../Terrain/TileMap")
	_astargrid.region = Rect2i(0, 0, 36, 21)
	_astargrid.cell_size = Vector2i(32, 32)
	_astargrid.offset = Vector2(16, 16)
	_astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astargrid.update()
	
	
	#build blocking spaces arrays
	for tile in tile_map.get_used_cells(0):
		var tile_blocking = tile_map.get_cell_tile_data(0, tile)
		if tile_blocking.get_custom_data("Terrain") is Terrain:
			var terrain :Terrain =  tile_blocking.get_custom_data("Terrain")
			for block_index in terrain.blocks:
				_blocking_spaces[block_index].append(tile)
	
	#combat.connect("advance_turn", advance_turn)
	#Once Game initialization is complete begin player turn
	game_state = Constants.GAME_STATE.PLAYER_TURN

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
									player_state = Constants.PLAYER_STATE.UNIT_MOVEMENT
								else : 
									#Draw the attack range for enemy, or ally
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
								if mouse_position_i != _selected_unit.map_position:
									move_player()
								else :
									_selected_unit.move_position = _selected_unit.map_position
									#finished_move.emit()
									combat.game_ui.set_action_list(get_available_unit_actions(_selected_unit))
									player_state = Constants.PLAYER_STATE.UNIT_ACTION_SELECT
					if event.button_index == MOUSE_BUTTON_RIGHT:
						if event.is_released():
							_action_tiles.clear()
							player_state = Constants.PLAYER_STATE.UNIT_SELECT
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
									move_speed = 320
									if _selected_unit.map_position != _selected_unit.move_position:
										find_path(_selected_unit.map_position)
										return_player()
									else : 
										#finished_move.emit()
										_arrived = true
										movement = _selected_unit.unit.movement
										player_state = Constants.PLAYER_STATE.UNIT_MOVEMENT
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION: 
				pass
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
				if event is InputEventMouseButton:
					if event.button_index == MOUSE_BUTTON_RIGHT:
						if event.is_released():
							combat.game_ui.hide_attack_action_inventory()
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
											_selected_unit.map_position = _selected_unit.move_position
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
	queue_redraw()
	# Player Turn
	if game_state == Constants.GAME_STATE.PLAYER_TURN:
		if(turn_phase == Constants.TURN_PHASE.INIT):
			combat.game_ui.hide_end_turn_button()
			turn_phase = Constants.TURN_PHASE.BEGINNING_PHASE
		elif(turn_phase == Constants.TURN_PHASE.BEGINNING_PHASE):
			turn_phase = Constants.TURN_PHASE.MAIN_PHASE
			player_state = Constants.PLAYER_STATE.UNIT_SELECT
		elif turn_phase == Constants.TURN_PHASE.MAIN_PHASE :
			combat.game_ui._set_tile_info(current_tile_info)
			#DO PLAYER ACTION PROCESS HERE, WE GIVE PLAYER CONTROL
			if player_state == Constants.PLAYER_STATE.UNIT_SELECT:
				combat.game_ui.show_end_turn_button()
			if player_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT:
				combat.game_ui.hide_end_turn_button()
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION:
				combat.game_ui.hide_end_turn_button()
				if not _unit_action_initiated: 
					perform_action()
					_unit_action_initiated = true
				if not _unit_action_completed and _unit_action_initiated:
					pass
				else: 
					_unit_action_completed = false
					_unit_action_initiated = false
					_selected_unit.turn_taken = true
					if _selected_unit.alive:
						_selected_unit.map_display.update_values()
					player_state = Constants.PLAYER_STATE.UNIT_SELECT
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
				pass
			elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
				combat.game_ui.hide_end_turn_button()
				var mouse_position = get_global_mouse_position()
				var mouse_position_i = tile_map.local_to_map(mouse_position)
				var comb = get_combatant_at_position(mouse_position_i)
				if comb != null and comb.alive:
					if _action_valid_targets.has(comb):
						combat.game_ui.display_unit_combat_exchange_preview(_selected_unit, comb,  get_distance(_selected_unit.move_position, comb.map_position))
						return
				combat.game_ui.hide_unit_combat_exchange_preview()
		elif(turn_phase == Constants.TURN_PHASE.ENDING_PHASE):
			#do turn end stuff for player 
			game_state = Constants.GAME_STATE.ENEMY_TURN
			turn_phase = Constants.TURN_PHASE.BEGINNING_PHASE
	#Enemy Turn
	elif game_state == Constants.GAME_STATE.ENEMY_TURN:
		combat.game_ui.hide_end_turn_button()
		#print("In Enemy Turn")
		if(turn_phase == Constants.TURN_PHASE.BEGINNING_PHASE):
			#DO THE BEGINNING PHASE STUFF HERE EX. STATUS EFFECTS REMOVE BUFFS, TERRAIN HEALING AND MORE
			
			turn_phase = Constants.TURN_PHASE.MAIN_PHASE
		elif(turn_phase == Constants.TURN_PHASE.MAIN_PHASE):
			if _in_ai_process:
				pass
			else : 
				if not _enemy_units_turn_taken:
					ai_turn()
				else :
					print("moved to enemy end phase")
					turn_phase = Constants.TURN_PHASE.ENDING_PHASE
		elif(turn_phase == Constants.TURN_PHASE.ENDING_PHASE):
			print("Enemy Ended Turn")
			_in_ai_process = false
			_enemy_units_turn_taken = false
			combat.advance_turn(Constants.FACTION.ENEMIES)
			#do stuff like spawn re-inforcements
			game_state = Constants.GAME_STATE.PLAYER_TURN
			turn_phase = Constants.TURN_PHASE.BEGINNING_PHASE
	##MOVE UNIT CODE
	if _arrived == false:
		controlled_node.position += controlled_node.position.direction_to(_next_position) * delta * move_speed
		if controlled_node.position.distance_to(_next_position) < 1:
#			_astargrid.set_point_solid(_previous_position, false)
			_occupied_spaces.erase(_previous_position)
			_astargrid.set_point_weight_scale(_previous_position, 1)
			var tile_cost = get_tile_cost(_previous_position)
			controlled_node.position = _next_position
			var new_position: Vector2i = tile_map.local_to_map(_next_position)
			##combat.get_current_combatant().move_position = new_position
			_previous_position = new_position
#			_astargrid.set_point_solid(new_position, true)
			_occupied_spaces.append(new_position)
			update_points_weight()
			var next_tile_cost = get_tile_cost(new_position)
			movement -= tile_cost
			if _position_id < _path.size() - 1 and movement > 0 and next_tile_cost <= movement:
				_position_id += 1
				_next_position = _path[_position_id]
			else:
				_arrived = true
				finished_move.emit(new_position)
				print("Unit finished move")
				if game_state == Constants.GAME_STATE.PLAYER_TURN:
					if(player_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT) :
						#Move complete on action select (cancelled move)
						#remove old space from occupied spaces
						_occupied_spaces.erase(_selected_unit.move_position)
						_astargrid.set_point_weight_scale(_selected_unit.move_position, 1)
						movement = _selected_unit.unit.movement
						player_state = Constants.PLAYER_STATE.UNIT_MOVEMENT
					elif(player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT):
						_selected_unit.move_position = new_position
						combat.game_ui.set_action_list(get_available_unit_actions(_selected_unit))
						player_state = Constants.PLAYER_STATE.UNIT_ACTION_SELECT
				else:
					pass


func _draw():
	if(game_state == Constants.GAME_STATE.PLAYER_TURN):
		if(player_state == Constants.PLAYER_STATE.UNIT_MOVEMENT):
			if(_selected_unit):
				draw_comb_range(_selected_unit)
				draw_ranges(move_range, true, attack_range,true, skill_range, true)
				drawSelectedpath()
		if(player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT):
			draw_action_tiles(_action_tiles, _action)

func advance_turn():
	turn_phase = Constants.TURN_PHASE.ENDING_PHASE

func get_combatant_at_position(target_position: Vector2i) -> CombatUnit:
	for comb in combat.combatants:
		if comb.map_position == target_position and comb.alive:
			return comb
	return null


func combatant_added(combatant):
	_occupied_spaces.append(combatant.map_position)


func combatant_died(combatant):
	_astargrid.set_point_weight_scale(combatant.map_position, 1)
	_occupied_spaces.erase(combatant.map_position)
	combatant.map_display.queue_free()


func update_points_weight():
	#Update occupied spaces for flying units
	for point in _occupied_spaces:
		
		if combat.get_current_combatant().unit.movement_class == 1:
			_astargrid.set_point_weight_scale(point, 1)
		else:
			_astargrid.set_point_weight_scale(point, INF)
		#Update point weights for blocking spaces
		for class_m in range(_blocking_spaces.size()):
			for space in _blocking_spaces[class_m]:
				if(_astargrid.is_in_bounds(space.x, space.y)):
					if combat.get_current_combatant().unit.movement_class == class_m:
						_astargrid.set_point_weight_scale(space, INF)
					else:
						_astargrid.set_point_weight_scale(space, 1)


func get_distance(point1: Vector2i, point2: Vector2i):
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)


func get_movement():
	return movement


func find_path(tile_position: Vector2i):
	if(_astargrid.is_in_bounds(tile_position.x, tile_position.y)):
		var current_position = tile_map.local_to_map(controlled_node.position)
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
		_path = _astargrid.get_point_path(current_position, tile_position)
		queue_redraw()


func move_player():
	var current_position = tile_map.local_to_map(controlled_node.position)
	_selected_unit.move_position = current_position
	var _path_size = _path.size()
	if _path_size > 1 and movement > 0:
		move_on_path(current_position)


func return_player():
	var original_position = _selected_unit.map_position
	var _path_size = _path.size()
	movement = _selected_unit.unit.movement
	if _path_size >= 1:
		move_on_path(original_position)


func move_on_path(current_position):
	_previous_position = current_position
	_position_id = 1
	_next_position = _path[_position_id]
	_arrived = false
	queue_redraw()


func begin_target_selection():
	combat.game_ui.hide_action_list()
	if _action.requires_target : #does the skill require a target?
		target_selection_started.emit()
	else :
		combat.call(_action.name, combat.get_current_combatant())
		target_selection_finished.emit()
		_selected_unit.map_position = _selected_unit.move_position

func begin_action_item_selection():
	combat.game_ui.hide_action_list()
	if _action.requires_item :
		combat.game_ui._set_attack_action_inventory(_selected_unit)
	else: 
		pass ## do nothing??

func action_target_selected(target: CombatUnit):
	_action_target_unit = target
	##combat.call(_action.name, combat.get_current_combatant(), target)
	target_selection_finished.emit()
	player_state = get_next_action_state()

func perform_action():
	combat.game_ui.hide_action_list()
	_selected_unit.map_position = _selected_unit.move_position
	if(_action.requires_target):
		combat.call(_action.name, combat.get_current_combatant(), _action_target_unit)
	else :
		combat.call(_action.name, combat.get_current_combatant())
	_action_selected = false
	_action = null
	_selected_item = null
	_item_selected = false

func action_item_selected():
	if _action == attack_action: 
		if _selected_item is WeaponDefinition:
			_selected_unit.unit.set_equipped(_selected_item)
			_item_selected = true
			_action_valid_targets = get_potential_targets(_selected_unit, _selected_item.attack_range)
			combat.game_ui.hide_attack_action_inventory()
			player_state = get_next_action_state()


func get_tile_cost(tile):
	var tile_data = tile_map.get_cell_tile_data(0, tile)
	if combat.get_current_combatant().unit.movement_class != Constants.UNIT_MOVEMENT_CLASS.FLYING:
		var tile_terrain :Terrain = tile_data.get_custom_data("Terrain")
		return int (tile_terrain.cost[combat.get_current_combatant().unit.movement_class])
	else:
		return 1


func get_tile_cost_at_point(point):
	var tile = tile_map.local_to_map(point)
	var tile_data = tile_map.get_cell_tile_data(0, tile)
	if combat.get_current_combatant().unit.movement_class != Constants.UNIT_MOVEMENT_CLASS.FLYING:
		if tile_data:
			var tile_terrain :Terrain = tile_data.get_custom_data("Terrain")
			return int (tile_terrain.cost[combat.get_current_combatant().unit.movement_class])
		else : return INF
	else:
		return 1



##Draw the path between the selected Combatant and the mouse cursor
func drawSelectedpath():
	if _arrived == true and player_turn == true:
		var path_length = movement
		#Get the length of the path
		for i in range(_path.size()):
			var point = _path[i]
			var draw_color = Color.DARK_SLATE_GRAY
			if path_length > 0:
				draw_color = Color.WHITE
			if i > 0:
				path_length -= get_tile_cost_at_point(point)
			draw_texture(path_tex, point - Vector2(16, 16), draw_color)
		if _attack_target_position != null:
			draw_texture(path_tex, _attack_target_position - Vector2(16, 16), Color.CRIMSON)
		if _blocked_target_position != null:
			draw_texture(path_tex, _blocked_target_position - Vector2(16, 16))


##Use DPS to retrieve the available cells from an origin point
func retrieveAvailableRange(range:int, origin: Vector2i, movement_type:int, effected_by_terrain:bool) -> PackedVector2Array:
	var visited : PackedVector2Array
	var target_tile_cost = 1
	var remaining_range
	if _arrived == true and player_turn == true:
		#if the player has movement otherwise this is meaningless
		visited.append(origin)
		if range > 0:
			#add our first tile into the front of the visited array
			#recursively call on the tiles around until range is empty
			for neighbors in tile_nieghbor_index :
				#get the correct tile in the direction
				var target_tile = tile_map.get_neighbor_cell(origin, neighbors)
				if(effected_by_terrain) :
					target_tile_cost = get_tile_cost(target_tile)
					remaining_range = range - target_tile_cost 
					if (remaining_range >= 0  and not _blocking_spaces[movement_type].has(target_tile) and not _occupied_spaces.has(target_tile)) :
						visited.append(target_tile)
						retrieveAvailableRange_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
				else : 
					remaining_range = range - target_tile_cost 
					if (remaining_range >= 0) :
						visited.append(target_tile)
						retrieveAvailableRange_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
	return visited

## Used in retreieveAvailableRange
func retrieveAvailableRange_recursion(range:int, origin: Vector2i, movement_type:int, effected_by_terrain:bool, visited:PackedVector2Array) -> PackedVector2Array:
	var target_tile_move_cost = 1
	var remaining_range
	if range > 0:
	#add our first tile into the front of the visited array
		#recursively call on the tiles around until range is empty
		for neighbors in tile_nieghbor_index :
		#get neighbor in direction
			var target_tile = tile_map.get_neighbor_cell(origin, neighbors)
			#Is the calculation for whether or not we can visit it effected by terrain?
			if(effected_by_terrain) :
				target_tile_move_cost = get_tile_cost(target_tile)
				remaining_range = range - target_tile_move_cost 
				##if the tile is within our move cost & not blacklisted by our move type
				if (remaining_range >= 0 and not _blocking_spaces[movement_type].has(target_tile) and not _occupied_spaces.has(target_tile)) :
					#visit the tile and call the recursion
					if(!visited.has(target_tile)) :
						visited.append(target_tile)
					retrieveAvailableRange_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
			else :  #if not do we have the power to reach it
				remaining_range = range - target_tile_move_cost 
				if (remaining_range >= 0) :
					##we visit the target tile and call the DFS on it
					if(!visited.has(target_tile)) : 
						visited.append(target_tile)
					retrieveAvailableRange_recursion(remaining_range, target_tile, movement_type, effected_by_terrain, visited)
	return visited

#Draws a units move and attack ranges
func draw_ranges(move_range:PackedVector2Array, draw_move_range:bool, attack_range:PackedVector2Array, draw_attack_range:bool, skill_range:PackedVector2Array, draw_skill_range:bool):
	var move_range_color = Color.BLUE
	var attack_range_color = Color.CRIMSON
	var skill_range_color = Color.GOLD
	if (draw_move_range) :
		for tile in move_range :
			draw_texture(grid_tex, tile  * Vector2(32, 32), move_range_color)
	if (draw_attack_range) :
		for tile in attack_range :
			if(!move_range.has(tile)) : 
				draw_texture(grid_tex, tile  * Vector2(32, 32), attack_range_color)
	if (draw_skill_range) :
		for tile in skill_range :
			if(!attack_range.has(tile) and !move_range.has(tile)) : 
				draw_texture(grid_tex, tile  * Vector2(32, 32), skill_range_color)

func draw_attack_range(attack_range:PackedVector2Array):
	for tile in attack_range : 
			draw_texture(grid_tex, tile  * Vector2(32, 32), Color.CRIMSON)

func draw_action_tiles(tiles:PackedVector2Array, ua:UnitAction):
	##Set the tile color based on the type of action
		for tile in tiles : 
			draw_texture(grid_tex, tile  * Vector2(32, 32), Color.CRIMSON)


func process_inputs():
	if Input.is_action_pressed("debug_button"):
		pass


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
			##combat.game_ui.set_action_list(get_available_unit_actions(_selected_unit))
			return Constants.PLAYER_STATE.UNIT_ACTION_SELECT
		if flow_index != 0 and flow_index -1 < _action.flow.size():
			#Navigate the user to the next appriopriate state1]:
			return map_action_state_to_player_state(_action.flow[flow_index-1])
	return player_state

func begin_action_flow():
	if _action:
		_action_selected = true
		if not _action.flow.is_empty():
			if _action.flow.front() == Constants.UNIT_ACTION_STATE.ITEM_SELECT: 
				begin_action_item_selection()
				player_state = Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT
			elif _action.flow.front() == Constants.UNIT_ACTION_STATE.TARGET_SELECT: 
				begin_target_selection()
				player_state = Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT
			else:
				player_state = Constants.PLAYER_STATE.UNIT_ACTION


func revert_action_flow():
	if _action:
		if not _action.flow.is_empty():
			var previous_state = get_previous_action_state()
			if previous_state == Constants.PLAYER_STATE.UNIT_ACTION_SELECT:
				_action = null
				_action_selected = false
				combat.game_ui.set_action_list(get_available_unit_actions(_selected_unit))
				player_state = Constants.PLAYER_STATE.UNIT_ACTION_SELECT
			elif previous_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
				_item_selected = false
				_selected_item = null
				begin_action_item_selection()
				player_state = Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT
			elif previous_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
				_action_target_unit = null
				_action_target_unit_selected = false
				begin_target_selection()
				player_state = Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT
			else:
				player_state = Constants.PLAYER_STATE.UNIT_ACTION

func map_player_state_to_action_state(player_state: Constants.PLAYER_STATE) -> Constants.UNIT_ACTION_STATE:
	if player_state == Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT:
		return Constants.UNIT_ACTION_STATE.ITEM_SELECT
	elif player_state == Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT:
		return Constants.UNIT_ACTION_STATE.TARGET_SELECT
	else :
		return Constants.UNIT_ACTION_STATE.ACTION

func map_action_state_to_player_state(action_state: Constants.UNIT_ACTION_STATE) -> Constants.PLAYER_STATE:
	if action_state == Constants.UNIT_ACTION_STATE.ITEM_SELECT:
		return Constants.PLAYER_STATE.UNIT_ACTION_ITEM_SELECT
	elif action_state == Constants.UNIT_ACTION_STATE.TARGET_SELECT:
		return Constants.PLAYER_STATE.UNIT_ACTION_TARGET_SELECT
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
	combat.game_ui.play_cursor()
	current_tile_info.x = position.x
	current_tile_info.y = position.y
	var tile_data = tile_map.get_cell_tile_data(0, position)
	if(tile_data != null):
		if tile_data.get_custom_data("Terrain"):
			var terrain :Terrain =  tile_data.get_custom_data("Terrain")
			current_tile_info.terrain = terrain
		#if(tile_data.get_custom_data("Tile_Name") != null):
			#current_tile_info.name = tile_data.get_custom_data("Tile_Name")
		#if(tile_data.get_custom_data("Avoid") != null):
			#current_tile_info.avoid = tile_data.get_custom_data("Avoid")
		#if(tile_data.get_custom_data("Defense") != null):
			#current_tile_info.defense = tile_data.get_custom_data("Defense")	
	##get the unit info
	if get_combatant_at_position(position):
		current_tile_info.unit = get_combatant_at_position(position)
	else : 
		current_tile_info.unit = null
	tile_info_updated.emit(current_tile_info)

func get_terrain_at_position(position: Vector2) ->  Terrain:
	var terrain_at_position: Terrain = null
	var tile = tile_map.local_to_map(position)
	var tile_data = tile_map.get_cell_tile_data(0, tile)
	if tile_data :
		if tile_data.get_custom_data("Terrain") is Terrain:
			terrain_at_position =  tile_data.get_custom_data("Terrain")
	else :
		print("ERROR TERRAIN IS NULL")
	return terrain_at_position

func get_terrain_at_map_position(position: Vector2) ->  Terrain:
	var terrain_at_position: Terrain = null
	var tile_data = tile_map.get_cell_tile_data(0, position)
	if tile_data :
		if tile_data.get_custom_data("Terrain") is Terrain:
			terrain_at_position =  tile_data.get_custom_data("Terrain")
	else :
		print("ERROR TERRAIN IS NULL")
	return terrain_at_position

func draw_comb_range(combatant: CombatUnit) :
	attack_range.clear()
	skill_range.clear()
	move_range = retrieveAvailableRange(combatant.unit.movement, combatant.map_position, 0, true)
	var edge_array = find_edges(move_range)
	for tile in edge_array :
		if combatant.unit.inventory.equipped:
			attack_range.append_array(retrieveAvailableRange(combatant.unit.inventory.equipped.attack_range.max(), tile, 0, false))
		skill_range.append_array(retrieveAvailableRange(0, tile, 0, false))


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


func get_attackable_tiles(range_list: Array[int], cu: CombatUnit):
	var attackable_tiles : PackedVector2Array
	for range in range_list:
		if cu.move_position :
			attackable_tiles.append_array(get_tiles_at_range(range, cu.move_position)[1])
	return attackable_tiles


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


func get_available_unit_actions(cu:CombatUnit) -> Array[UnitAction]:
	var action_array : Array[UnitAction] = []
	if not cu.unit.inventory.is_empty():
		action_array.append(item_action)
	if not get_potential_targets(cu).is_empty():
		action_array.push_front(attack_action)
	action_array.append(wait_action)
	return action_array


func _on_visual_combat_major_action_completed() -> void:
	_unit_action_completed = true
	pass # Replace with function body.


# AI Methods

func ai_process(ai_unit: CombatUnit, target_position: Vector2i):
	print("Entered ai_process in cController.gd")
	#find nearest non-solid tile to target_position
	#Get Attack Range to see what are "attackable tiles"	
	var current_position = tile_map.local_to_map(controlled_node.position)
	var moveable_tiles : PackedVector2Array= retrieveAvailableRange(ai_unit.unit.movement,current_position, 0, true)
	var actionable_range : Array[int]= ai_unit.unit.get_attackable_ranges()
	var actionable_tiles :PackedVector2Array
	var has_actionable_move : bool = false
	print("@ MOVABLE_TILES : " + str(moveable_tiles))
	for targetable_unit_index: int in combat.groups[Constants.FACTION.PLAYERS]:
		for range in actionable_range:
			for tile in get_tiles_at_range(range,combat.combatants[targetable_unit_index].map_position)[1]:
				if not actionable_tiles.has(tile):
					actionable_tiles.append(tile)
	print("@ ACTIONABLE_TILES : " + str(actionable_tiles))
	for moveable_tile in moveable_tiles:
		if actionable_tiles.has(moveable_tile):
			print("@ TILE MOVE TARGETTED : " + str(moveable_tile))
			if not _occupied_spaces.has(moveable_tile):
				for tile in tiles_to_check:
					if !_astargrid.get_point_weight_scale(moveable_tile) > 999999:
						ai_move(moveable_tile)
						has_actionable_move = true
					break
	if not has_actionable_move: 
		print("@ TARGET TILE : " + str(target_position))
		for tile in actionable_tiles:
			print("@ astar check " + str(_astargrid.get_point_weight_scale(tile)))
			if !_astargrid.get_point_weight_scale(tile) > 999999:
				ai_move(tile )
				break
	await finished_move
	print("Actual Node position is " + str(tile_map.local_to_map(controlled_node.position)))
	ai_unit.map_terrain = get_terrain_at_position(controlled_node.position)
	ai_unit.map_position = tile_map.local_to_map(controlled_node.position)

func get_closet_tile(target: Vector2, array:PackedVector2Array):
	pass

func ai_move(target_position: Vector2i):
	print("AI attempting to move to "+ str(target_position))
	var current_position = tile_map.local_to_map(controlled_node.position)
	find_path(target_position)
	move_on_path(current_position)


func ai_turn ():
	_in_ai_process = true
	var enemy_units  = combat.get_ai_units()
	for unit  :CombatUnit in enemy_units:
		print(unit.unit.unit_name)
	for unit :CombatUnit in enemy_units:
		print("Began AI processing unit : "+ unit.unit.unit_name)
		set_controlled_combatant(unit)
		await combat.ai_process(unit)
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
	if combatant.allegience == 0:
		_selected_unit = combatant
		#player_turn = false
	combat.set_current_combatant(combatant)
	controlled_node = combatant.map_display
	movement = combatant.unit.movement
	update_points_weight()
