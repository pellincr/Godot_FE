extends Resource
class_name CombatTargettingResource

var target_methods_range_map = {}
var range_target_methods_map = {}
var target_range_map = {}
var range_target_map = {}

var previous_target : Vector2i 
var current_target_range:int
var current_method: Object

var _available_targets_with_method : Array[Vector2i]
var _available_targets_at_range_index : int
var _available_target_methods = []
var _available_target_methods_index : int

func initalize(user_position: Vector2i, targets: Array[Vector2i], target_methods : Dictionary): #Dictionary <name : String, ranges : List[int]>
	populate_target_maps(user_position, targets)
	target_methods_range_map = target_methods
	range_target_methods_map = CustomUtilityLibrary.reverse_dictionary(target_methods)

func populate_target_maps(user_position: Vector2i,targets: Array[Vector2i]):
	for target_position in targets:
		var grid_distance = CustomUtilityLibrary.get_distance(user_position, target_position)
		if range_target_map.has(grid_distance):
			range_target_map.get(grid_distance).append(target_position)
		else :
			var positions = []
			positions.append(target_position)
			range_target_map[grid_distance] = positions
		target_range_map[target_position] = grid_distance

func update_available_target_methods(range: Array[int]):
	_available_target_methods.clear()
	for distance in range:
		if range_target_methods_map.has(distance):
			_available_target_methods.append(range_target_methods_map[distance])
	for  i in range(_available_target_methods.size()):
		if current_method == _available_target_methods[i]:
			_available_target_methods_index = i
			break
		else :
			_available_target_methods_index = 0

func update_dynamic_maps_new_method(method):
	var current_target_positon =_available_targets_with_method[_available_targets_at_range_index]
	_available_targets_with_method.clear()
	_available_target_methods.clear()
	for distance in target_methods_range_map.get(method):
		_available_targets_with_method.append_array(range_target_methods_map.get(distance))
	for  i in range(_available_targets_with_method.size()):
		if current_target_positon == _available_targets_with_method[i]:
			_available_targets_at_range_index = i
			break
		else :
			_available_targets_at_range_index = 0

func get_next_target_method() -> Object:
	_available_target_methods_index = CustomUtilityLibrary.array_next_index_with_loop(_available_target_methods, _available_target_methods_index)
	#Does the new target method have a new range?
	if current_target_range != range_target_map[_available_targets_with_method[_available_target_methods_index]] :
		update_available_target_methods(current_method.use_range)
	return _available_target_methods[_available_target_methods_index]

func get_next_target() -> Vector2i:
	_available_targets_at_range_index = CustomUtilityLibrary.array_next_index_with_loop(_available_targets_with_method,_available_targets_at_range_index)
	if current_target_range != range_target_map[_available_targets_with_method[_available_targets_at_range_index]] :
		update_available_target_methods(current_method.use_range)
	return _available_targets_with_method[_available_targets_at_range_index]

func get_previous_target_method() -> Object:
	_available_target_methods_index = CustomUtilityLibrary.array_previous_index_with_loop(_available_target_methods, _available_target_methods_index)
	#Does the new target method have a new range?
	if current_target_range != range_target_map[_available_targets_with_method[_available_target_methods_index]] :
		update_available_target_methods(current_method.use_range)
	return _available_target_methods[_available_target_methods_index]

func get_previous_target() -> Vector2i:
	_available_targets_at_range_index = CustomUtilityLibrary.array_previous_index_with_loop(_available_targets_with_method,_available_targets_at_range_index)
	if current_target_range != range_target_map[_available_targets_with_method[_available_targets_at_range_index]] :
		update_available_target_methods(current_method.use_range)
	return _available_targets_with_method[_available_targets_at_range_index]
