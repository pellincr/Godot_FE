extends Node

class_name CampaignMapGenerator

const X_DIST := 30 #x distance between rooms
const Y_DIST : = 25#y distance between rooms
const PLACEMENT_RANDOMNESS := 5 #randomly move the rooms a bit to give a bt extra feel
var FLOORS := 15 #TO BE CHANGED TO A VARYING NUMBER LATER, number of rows
var NUMBER_OF_REQUIRED_COMBAT_MAPS : int = 0
const MAP_WIDTH := 7#number of columns
const PATHS := 6#number of paths there can be


const BATTLE_ROOM_WEIGHT := 5.0 #0
const EVENT_ROOM_WEIGHT := 4.0 #2.5
const TREASURE_ROOM_WEIGHT := 1.0 #1
const ELITE_ROOM_WEIGHT := 0.0 #1.5
const SHOP_ROOM_WEIGHT := 0.0 #2.0
const RECRUITMENT_ROOM_WEIGHT := 3.0 #1.0
const KEY_BATTLE_ROOM_WEIGHT := 0.0

var random_room_type_weights = {
	CampaignRoom.TYPE.BATTLE : 0.0,
	CampaignRoom.TYPE.KEY_BATTLE : 0.0,
	CampaignRoom.TYPE.EVENT : 0.0, #6
	CampaignRoom.TYPE.TREASURE : 0.0, #6
	CampaignRoom.TYPE.ELITE : 0.0,
	CampaignRoom.TYPE.SHOP : 0.0,
	CampaignRoom.TYPE.RECRUITMENT : 0.0#6
}



var random_room_type_total_weight := 0
var test := 0
var map_data : Array[Array]


func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points := _get_random_starting_points()
	
	for column_index in starting_points:
		var current_column = column_index
		for row in FLOORS -1:
			current_column = _setup_connection(row,current_column)
	
	_setup_boss_room()
	_setup_random_room_weights()
	_setup_room_types()
	"""
	#DEBUGGER
	var i := 0
	for floor in map_data:
		print("floor %s" % i)
		var used_rooms = floor.filter(
			func(room:CampaignRoom):return room.next_rooms.size() > 0
		)
		print(used_rooms)
		i +=1
	"""
	return map_data

func _generate_initial_grid() -> Array[Array]:
	var result : Array[Array]
	for row_number in FLOORS:
		var adjacent_rooms: Array[CampaignRoom] = []
		for column_number in MAP_WIDTH:
			#create the room with the slight offset on the map
			var current_room := CampaignRoom.new()
			var offset := Vector2(randf(),randf()) * PLACEMENT_RANDOMNESS
			current_room.position = Vector2(column_number * X_DIST, row_number * -Y_DIST) + offset #negative y distance places the next row above
			current_room.row = row_number
			current_room.column = column_number
			current_room.next_rooms = []
			#Boss room has a non-random Y
			if row_number == FLOORS - 1:
				current_room.position.y = (row_number + 1) * -Y_DIST
			adjacent_rooms.append(current_room)
		result.append(adjacent_rooms)
	return result

func _get_random_starting_points() -> Array[int]:
	var y_coordinates : Array[int]
	var unique_points : int = 0
	while unique_points < 2:
		unique_points = 0
		y_coordinates = []
		for i in PATHS:
			var starting_point := randi_range(0,MAP_WIDTH-1)
			if not y_coordinates.has(starting_point):
				unique_points +=1
			y_coordinates.append(starting_point)
	return y_coordinates

func _setup_connection(row:int,col:int) -> int:
	var next_room : CampaignRoom
	var current_room := map_data[row][col] as CampaignRoom
	
	@warning_ignore("unassigned_variable")
	while not next_room or _would_cross_existing_path(row,col,next_room):
		var random_col := clampi(randi_range(col-1,col+1),0,MAP_WIDTH-1) #gets the next random column number that is either diagonal left, straight, or diagonal right from, current
		next_room = map_data[row+1][random_col]
	current_room.next_rooms.append(next_room)
	return next_room.column

func _would_cross_existing_path(row:int,col:int,room:CampaignRoom) -> bool:
	var left_neighbor : CampaignRoom
	var right_neighbor : CampaignRoom
	
	#if col == 0, there is no left neighbor. Only needs to be set if col > 0
	if col > 0:
		left_neighbor = map_data[row][col-1]
	#if col == MAP_WIDTH -1, there is no right neighbor. Only needs to be set if col < MAP_WIDTH - 1
	if col < MAP_WIDTH - 1:
		right_neighbor = map_data[row][col+1]
	
	#can't cross in the right dir if right neighbor goes to left
	if right_neighbor and room.column > col: #check if right neighbor exists and if the desired room is heading in the right direction
		for neighbor_next_room : CampaignRoom in right_neighbor.next_rooms: 
			if neighbor_next_room.column < room.column:
				return true
	#can't cross in the left dir if the neft neightbor goes to the right
	if left_neighbor and room.column < col:
		for next_room : CampaignRoom in left_neighbor.next_rooms:
			if next_room.column > room.column:
				return true
	return false

func _setup_boss_room() -> void:
	var middle := floori(MAP_WIDTH * .5)
	var boss_room := map_data[FLOORS-1][middle] as CampaignRoom
	
	for col in MAP_WIDTH:
		#connects all previous rooms to the boss room
		var current_room = map_data[FLOORS-2][col] as CampaignRoom
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[CampaignRoom]
			current_room.next_rooms.append(boss_room)
		boss_room.type = CampaignRoom.TYPE.BOSS

func _setup_random_room_weights() -> void:
	random_room_type_weights[CampaignRoom.TYPE.BATTLE] = BATTLE_ROOM_WEIGHT
	random_room_type_weights[CampaignRoom.TYPE.KEY_BATTLE] = KEY_BATTLE_ROOM_WEIGHT + BATTLE_ROOM_WEIGHT
	random_room_type_weights[CampaignRoom.TYPE.EVENT] = KEY_BATTLE_ROOM_WEIGHT + BATTLE_ROOM_WEIGHT + EVENT_ROOM_WEIGHT
	random_room_type_weights[CampaignRoom.TYPE.TREASURE] = KEY_BATTLE_ROOM_WEIGHT + BATTLE_ROOM_WEIGHT + TREASURE_ROOM_WEIGHT + EVENT_ROOM_WEIGHT
	random_room_type_weights[CampaignRoom.TYPE.ELITE] = ELITE_ROOM_WEIGHT + KEY_BATTLE_ROOM_WEIGHT + BATTLE_ROOM_WEIGHT + TREASURE_ROOM_WEIGHT + EVENT_ROOM_WEIGHT
	random_room_type_weights[CampaignRoom.TYPE.SHOP] = SHOP_ROOM_WEIGHT + ELITE_ROOM_WEIGHT + KEY_BATTLE_ROOM_WEIGHT + BATTLE_ROOM_WEIGHT + TREASURE_ROOM_WEIGHT + EVENT_ROOM_WEIGHT
	random_room_type_weights[CampaignRoom.TYPE.RECRUITMENT] = SHOP_ROOM_WEIGHT + ELITE_ROOM_WEIGHT + KEY_BATTLE_ROOM_WEIGHT + BATTLE_ROOM_WEIGHT + RECRUITMENT_ROOM_WEIGHT + TREASURE_ROOM_WEIGHT + EVENT_ROOM_WEIGHT
	var total_room_weight = random_room_type_weights[CampaignRoom.TYPE.RECRUITMENT]
	
	random_room_type_total_weight = total_room_weight#random_room_type_weights[CampaignRoom.TYPE.RECRUITMENT]

func _setup_room_types() -> void:
	#first floor is always a battle
	#for room : CampaignRoom in map_data[0]:
	#	if room.next_rooms.size() > 0:
	#		room.type = CampaignRoom.TYPE.BATTLE
	#for room: CampaignRoom in map_data[FLOORS/2]:
	#	if room.next_rooms.size() > 0:
	#		room.type = CampaignRoom.TYPE.TREASURE
	@warning_ignore("integer_division")
	var key_combat_room_index = int(FLOORS / NUMBER_OF_REQUIRED_COMBAT_MAPS)
	for required_combat_map_index in NUMBER_OF_REQUIRED_COMBAT_MAPS:
		for room: CampaignRoom in map_data[key_combat_room_index * required_combat_map_index]:
			if room.next_rooms.size() > 0:
				room.type = CampaignRoom.TYPE.KEY_BATTLE
	#OMITTING THE RULE THAT LAST FLOOR BEFORE BOSS IS CAMPFIRE
	for current_floor in map_data:
		for room : CampaignRoom in current_floor:
			for next_room in room.next_rooms:
				if next_room.type == CampaignRoom.TYPE.NOT_ASSIGNED:
					_set_room_randomly(next_room)
	for room : CampaignRoom in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = CampaignRoom.TYPE.EVENT

func _set_room_randomly(room_to_set : CampaignRoom) -> void:
	#OMITTING NO CAMPFIRES BEFORE FLOOR 4 RULE
	#OMITTING NO CONSECUTIVE CAMPFIRE RULE
	var consecutive_shop := true
	#OMITTING NO CAMPFIRES BEORE 2ND TO LAST ENCOUNTER
	
	var type_candidate : CampaignRoom.TYPE
	while consecutive_shop:
		type_candidate = _get_random_room_type_by_weight()
		var is_shop := type_candidate == CampaignRoom.TYPE.SHOP
		var has_shop_parent := _room_has_parent_of_type(room_to_set,CampaignRoom.TYPE.SHOP)
		
		consecutive_shop = is_shop and has_shop_parent
	
	room_to_set.type = type_candidate

func _room_has_parent_of_type(room:CampaignRoom,type:CampaignRoom.TYPE) -> bool:
	#THIS FUNCTION IS USED FOR A RULE THAT IS BEING OMITTED; THIS IS BEING KEPT INCASE WE WANT TO AVOID CONSECUTIVE ROOM TYPES IN THE FUTURE
	var parents : Array[CampaignRoom] = []
	#left parent
	if room.column > 0 and room.row > 0:
		var parent_candidate := map_data[room.row-1][room.column-1] as CampaignRoom
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	#parent below
	if room.row > 0:
		var parent_candidate := map_data[room.row-1][room.column] as CampaignRoom
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	#right parent
	if room.column < MAP_WIDTH-1  and room.row > 0:
		var parent_candidate := map_data[room.row-1][room.column+1] as CampaignRoom
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	for parent : CampaignRoom in parents:
		if parent.type == type:
			return true
	return false

func _get_random_room_type_by_weight() -> CampaignRoom.TYPE:
	var roll := randf_range(0.0,random_room_type_total_weight)
	for type:CampaignRoom.TYPE in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
	return CampaignRoom.TYPE.BATTLE
