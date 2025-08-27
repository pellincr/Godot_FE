extends Resource
class_name CombatMapUnitActionTargettingResource

# Resource that generates maps and assists in finding available targets during unit actions in combatmap

var target_methods_range_map = {} # Dict<Object, Range>
var range_target_methods_map = {} # Dict<Range, Object>
var target_range_map = {} # Dict<positon : Vector2i, Range>
var range_target_map = {} # Dict<Range position: Vector2i>

var current_target_positon : Vector2i
var current_target_type : String 
var current_target_range : int #Current Distance from user
var current_method: Object #Current weapon

var _available_targets_with_method : Array[Vector2i] # all the targets that the current weapon can interact with (used in get next target, keeping same weapon)
var _available_targets_at_range_index : int # Index for the currrent array 
var _available_methods_at_target = [] # what weapons can we interact with the current target with? (used in get next weapon, keeping same target)
var _available_methods_at_target_index : int 

func clear():
	target_methods_range_map.clear()
	range_target_methods_map.clear()
	target_range_map.clear()
	range_target_map.clear()
	current_target_type = ""
	current_target_range = 0
	_available_targets_at_range_index = 0
	_available_targets_at_range_index = 0
	current_method = null
	_available_targets_with_method.clear()
	_available_methods_at_target.clear()

func create_target_methods_weapon(unit:Unit) -> Dictionary:
	var attack_range_map : Dictionary = {}
	for item in unit.inventory.get_items():
			if item is WeaponDefinition:
				if unit.can_equip(item):
					for attack_range in item.attack_range:
						if item.item_target_faction.has(itemConstants.AVAILABLE_TARGETS.ENEMY):
							if attack_range_map.has(attack_range):
								attack_range_map.get(attack_range).append(item)
							else:
								var weapons_at_range : Array[WeaponDefinition] = [item]
								attack_range_map[attack_range] = weapons_at_range
	return attack_range_map

func create_target_methods_support(unit:Unit) -> Dictionary:
	var attack_range_map : Dictionary = {}
	for item in unit.inventory.get_items():
			if item is WeaponDefinition:
				if unit.can_equip(item):
					if item.item_target_faction.has(itemConstants.AVAILABLE_TARGETS.ALLY):
						for attack_range in item.attack_range:
							if attack_range_map.has(attack_range):
								attack_range_map.get(attack_range).append(item)
							else:
								var weapons_at_range : Array[WeaponDefinition] = [item]
								attack_range_map[attack_range] = weapons_at_range
	return attack_range_map

#
# Populates map with appropriate info
#
func initalize(user_position: Vector2i, targets: Array[Vector2i], target_methods : Dictionary): #Dictionary <ranges : int, List[object] : >
	populate_target_maps(user_position, targets)
	range_target_methods_map = target_methods
	generate_target_methods_range_map()

func generate_target_methods_range_map():
	target_methods_range_map.clear()
	for key in range_target_methods_map.keys():
		# For all the keys
		if range_target_methods_map[key] is Array:
			for key_element in range_target_methods_map[key]:
				if target_methods_range_map.has(key_element):
					target_methods_range_map[key_element].append(key)
				else:
					var methods = []
					methods.append(key)
					target_methods_range_map[key_element] = methods
		else :
			target_methods_range_map[range_target_methods_map[key]] = key

#
# Populates the both the target_range_map<grid_distance, Array[target_posn]> and range_target_map<target_posn, distance>
#
func populate_target_maps(user_position: Vector2i,targets: Array[Vector2i]):
	target_range_map.clear()
	range_target_map.clear()
	for target_position in targets:
		var grid_distance = CustomUtilityLibrary.get_distance(user_position, target_position)
		if range_target_map.has(grid_distance):
			range_target_map.get(grid_distance).append(target_position)
		else :
			var positions: Array[Vector2i] = []
			positions.append(target_position)
			range_target_map[grid_distance]  = positions
		target_range_map[target_position] = grid_distance


#
# Updates _available_target_methods to contain all methods to interact at ranges 
#
func update_available_target_methods(ranges: Array):
	_available_methods_at_target.clear()
	# For each range
	for distance in ranges:
		if range_target_methods_map.has(distance):
			for method in range_target_methods_map[distance]:
				if !_available_methods_at_target.has(method):
					_available_methods_at_target.append(method)
	# get the index of our currently in use target_method
	for i in range(_available_methods_at_target.size()):
		if current_method == _available_methods_at_target[i]:
			_available_methods_at_target_index = i
			break
		else :
			_available_methods_at_target_index = 0

#
# Re-populates the _available_targets_with_method, and _available_target_methods maps. Sets the _available_tragets_at_range_index
#
func update_dynamic_maps_new_method(method):
	current_method = method
	#populate _available_targets_with_method
	if _available_targets_with_method.is_empty():
		if target_methods_range_map.has(method):
			for range in target_methods_range_map[method]:
				if range_target_map.has(range):
					#get all available targets
					_available_targets_with_method.append_array(range_target_map[range])
					for new_method in range_target_methods_map[range]:
						if ! _available_methods_at_target.has(new_method):
							_available_methods_at_target.append(new_method)
	# set the current_target's position
	current_target_positon =_available_targets_with_method[_available_targets_at_range_index]
	current_target_range = target_range_map[current_target_positon]
	for distance in target_methods_range_map.get(method):
		_available_targets_with_method.append_array(range_target_methods_map.get(distance))

# Get the next usable weapon for the target
func next_target_method():
	#get the next method
	_available_methods_at_target_index = CustomUtilityLibrary.array_next_index_with_loop(_available_methods_at_target, _available_methods_at_target_index)
	current_method = _available_methods_at_target[_available_methods_at_target_index]
	#update the arrays and indexes
	update_dynamic_maps_new_method(current_method)

# get the next available target
func next_target():
	#get the next target in the index
	_available_targets_at_range_index = CustomUtilityLibrary.array_next_index_with_loop(_available_targets_with_method,_available_targets_at_range_index)
	#does the new target have the same range?
	if current_target_range != target_range_map.get(_available_targets_with_method[_available_targets_at_range_index]):
		update_available_target_methods(target_methods_range_map[current_method])
	current_target_positon = _available_targets_with_method[_available_targets_at_range_index]

# get the previous target_method
func previous_target_method():
	# get the previous target_method
	_available_methods_at_target_index = CustomUtilityLibrary.array_previous_index_with_loop(_available_methods_at_target, _available_methods_at_target_index)
	current_method = _available_methods_at_target[_available_methods_at_target_index]
	#update the arrays and indexes
	update_dynamic_maps_new_method(current_method)

# get the previous available target
func previous_target():
	_available_targets_at_range_index = CustomUtilityLibrary.array_previous_index_with_loop(_available_targets_with_method,_available_targets_at_range_index)
	if current_target_range != target_range_map.get(_available_targets_with_method[_available_targets_at_range_index]):
		update_available_target_methods(target_methods_range_map[current_method])
	current_target_positon = _available_targets_with_method[_available_targets_at_range_index]

# create an iventory data structure to send to action inventories
func generate_unit_inventory_slot_data(attacker: Unit) -> Array[UnitInventorySlotData]:
	var _unit_inventory_info : Array[UnitInventorySlotData] = []
	var valid_list :Array[WeaponDefinition]
	#Get the list of target ranges
	for range in range_target_map.keys():
		if range_target_methods_map.has(range):
			for item in range_target_methods_map[range]:
				if not valid_list.has(item):
					valid_list.append(item)
	for item in attacker.inventory.get_items():
		var unit_inventory_slot_data :UnitInventorySlotData = UnitInventorySlotData.new() 
		if item != null:
			if item is WeaponDefinition:
				unit_inventory_slot_data.item = item
				if attacker.inventory.get_equipped_item() == item:
					unit_inventory_slot_data.equipped = true
				if item in valid_list:
					unit_inventory_slot_data.valid = true
		else :
			unit_inventory_slot_data.item = null
			unit_inventory_slot_data.equipped = false
			unit_inventory_slot_data.valid = false
		_unit_inventory_info.append(unit_inventory_slot_data)
	return _unit_inventory_info
