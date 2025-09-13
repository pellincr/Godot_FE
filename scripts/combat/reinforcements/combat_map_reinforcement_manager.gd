extends Node
class_name CombatMapReinforcementManager

signal spawn_reinforcement(combat_unit: CombatUnit)
signal reinforcement_spawn_completed()

@export var zone_map : Dictionary
@export var reinforcement_data : MapReinforcementData
@export var reinforcement_zone_triggered : Dictionary #<String_key, bool>
@export var reinforcement_unit_data : Dictionary # <String_key, Array[CombatUnitData]>

@export var game_grid : CombatMapGrid

func check_reinforcement_spawn(turn_number : int, ally_unit_positions: Array[Vector2i]):
	# First Check the turn re-inforcements 
	var _arr_reinforcement_unit_keys :Array[String] = []
	var turn_key = generate_reinforcement_unit_data_map_key(CombatMapConstants.REINFORCEMENT_TYPE.TURN_COUNT, turn_number)
	if reinforcement_unit_data.has(turn_key):
		_arr_reinforcement_unit_keys.append(turn_key)
	# Check for zone triggers & reinforcements
	for position in ally_unit_positions:
		for zone in zone_map.keys():
			#has the zone been triggered?
			if reinforcement_zone_triggered[zone] == false:
				# does the zone have a unit in it so it should be triggered
				if zone_map.get(zone).has(position):
					var zone_key = generate_reinforcement_unit_data_map_key(CombatMapConstants.REINFORCEMENT_TYPE.MAP_ZONE_ENTERED, zone)
					_arr_reinforcement_unit_keys.append(zone_key)
					reinforcement_zone_triggered[zone] = true
	if not _arr_reinforcement_unit_keys.is_empty():
		await spawn_reinforcement_groups(_arr_reinforcement_unit_keys)


func populate_reinforcement_unit_data(input_reinforcement_unit_data: Array[CombatUnitGroupReinforcementData]):
	if input_reinforcement_unit_data:
		for group in input_reinforcement_unit_data: 
			for turn in group.turns:
				var key : String = generate_reinforcement_unit_data_map_key(group.trigger_type, turn, group.zone_id)
				if reinforcement_unit_data.has(key):
						reinforcement_unit_data[key].append_array(group.units)
				else : 
					var unit_data_array : Array[CombatUnitData] = []
					unit_data_array.append_array(group.units)
					reinforcement_unit_data[key] = unit_data_array

func generate_reinforcement_unit_data_map_key(method: CombatMapConstants.REINFORCEMENT_TYPE, turn_count : int = -1, zone_id : String = "") -> String:
	match method:
		CombatMapConstants.REINFORCEMENT_TYPE.TURN_COUNT:
			return str("TURN_COUNT_" + str(turn_count))
		CombatMapConstants.REINFORCEMENT_TYPE.MAP_ZONE_ENTERED:
			return str("MAP_ZONE_ENTERED_" + zone_id)
	return "INVALID_KEY"

func spawn_reinforcement_groups(groups : Array[String]):
	if not groups.is_empty():
		for group in groups:
			await spawn_reinforcement_group(group)

func spawn_reinforcement_group(group : String):
	var _unit_array = reinforcement_unit_data.get(group)
	for _unit : CombatUnitData in _unit_array:
		await spawn_reinforcement_unit(_unit)

func spawn_reinforcement_unit(unit_data: CombatUnitData):
	if game_grid.is_position_occupied(unit_data.map_position) == false:
		var _unit_data = Unit.create_generic_unit(unit_data.unit_type_key, unit_data.inventory, unit_data.name, unit_data.level, unit_data.level_bonus, unit_data.hard_mode_leveling)
		var _combat_unit = CombatUnit.create(_unit_data, Constants.FACTION.ENEMIES, unit_data.ai_type,unit_data.is_boss)
		var position = unit_data.map_position
		print("spawn reinforcement_unit emitted")
		spawn_reinforcement.emit(_combat_unit, position)
		await reinforcement_spawn_completed

func populate_zone_map(zone_data_list : Array[CombatMapReinforcementZoneData]):
	for zone_data : CombatMapReinforcementZoneData in zone_data_list:
		var _zone_data_arr: Array[Vector2i] = []
		if zone_data.mapping_method == zone_data.ZONE_MAPPING_METHODS.CORNER:
			for x_cordinate in range(zone_data.zone_bottom_left_vertex.x, zone_data.zone_top_right_vertex.x):
				for  y_cordinate in range(zone_data.zone_bottom_left_vertex.y, zone_data.zone_top_right_vertex.y):
					var tile : Vector2i  = Vector2i(x_cordinate,y_cordinate)
					_zone_data_arr.append(tile)
		elif zone_data.mapping_method == zone_data.ZONE_MAPPING_METHODS.COORDINATE:
			_zone_data_arr.append_array(zone_data.zone)
		#assign the zone list to the zone ID
		if zone_map.has(zone_data.zone_id):
			zone_map[zone_data.zone_id].append_array(_zone_data_arr)
		else: 
			zone_map[zone_data.zone_id] = _zone_data_arr
			reinforcement_zone_triggered[zone_data.zone_id] = false

func populate(map_reinforcement_data: MapReinforcementData):
	if map_reinforcement_data != null:
		populate_zone_map(map_reinforcement_data.zones)
		populate_reinforcement_unit_data(map_reinforcement_data.reinforcements)

func _on_reinforcement_spawn_completed():
	print("reinforcement_unit spawned successfully")
	reinforcement_spawn_completed.emit()
