extends Node

#checks if the current RNG is successful
func random_rolls_bool(chance: int, number_of_rolls : int) -> bool:
	var aggregated_rolls = 0
	for rolls in number_of_rolls: 
		var random_number = randi() % 100
		aggregated_rolls += random_number
	var trueHit = clampi(int(aggregated_rolls/ number_of_rolls), 0, 100)
	if trueHit < chance:
		return true
	else :
		return false

#
# Converts string into Vector2i
#
func vector2i(string : String) -> Vector2i: #(0, 0) RE-WORK THIS TO HAVE ERROR CATCHING
	string.replace("(", "")
	string.replace(")", "")
	var arr = string.split(",")
	return Vector2i(int(arr[0]), int(arr[1]))

##Checks if strings are equal ignoring thier case
func equals_ignore_case(string_a: String, string_b : String) -> bool:
	return string_a.to_upper() == string_b.to_upper()

func erase_packedVector2Array(target_array: PackedVector2Array, target:Vector2) -> bool:
	if target_array.has(target):
		target_array.remove_at(target_array.find(target))
		return true
	return false

func add_unit_stat(a : UnitStat, b : UnitStat) -> UnitStat:
	var result : UnitStat = UnitStat.new()
	result.hp = a.hp + b.hp
	result.strength = a.strength + b.strength
	result.magic = a.magic + b.magic
	result.skill = a.skill + b.skill
	result.speed = a.speed + b.speed
	result.luck = a.luck + b.luck
	result.defense = a.defense + b.defense
	result.resistance = a.resistance + b.resistance
	result.movement = a.movement + b.movement
	result.constitution = a.constitution + b.constitution
	return result

func reverse_dictionary(dict: Dictionary) -> Dictionary:
	var reverse_dict = {}
	for key in dict.keys():
		# For all the keys
		if dict[key] is Array:
			for key_element in dict[key]:
				reverse_dict[key_element] = key
		else :
			reverse_dict[dict[key]] = key
	return reverse_dict

func array_next_index_with_loop(array: Array, index: int):
	var  _next_index = index
	if index + 1 < array.size():
		_next_index = _next_index + 1 
	else :
		_next_index = 0
	return _next_index

func array_previous_index_with_loop(array: Array, index: int):
	var  _next_index = index
	if index - 1 > 0:
		_next_index = _next_index - 1 
	else :
		_next_index = array.size()
	return _next_index

func get_distance(point1: Vector2i, point2: Vector2i):
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)
