extends Node

#checks if the current RNG is successful
func random_rolls_bool(chance: int, number_of_rolls : int, threshold: int = 100) -> bool:
	var aggregated_rolls = 0
	for rolls in number_of_rolls: 
		var random_number = randi() % threshold
		aggregated_rolls += random_number
	var trueHit = clampi(int(aggregated_rolls/ number_of_rolls), 0, threshold)
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

func mult_unit_stat(a : UnitStat, mult: float) -> UnitStat:
	var result : UnitStat = UnitStat.new()
	result.hp = int(a.hp * mult)
	result.strength = int(a.strength * mult)
	result.magic = int(a.magic * mult)
	result.skill = int(a.skill * mult)
	result.speed = int(a.speed * mult)
	result.luck = int(a.luck * mult)
	result.defense = int(a.defense * mult)
	result.resistance = int(a.resistance * mult)
	result.movement = a.movement
	result.constitution = a.constitution
	return result

func add_combat_unit_stat(a : CombatUnitStat, b : CombatUnitStat) -> CombatUnitStat:
	var result : CombatUnitStat = CombatUnitStat.new()
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
	result.current_hp = a.current_hp + b.current_hp
	result.damage = a.damage + b.damage
	result.hit = a.hit + b.hit
	result.avoid = a.avoid + b.avoid
	result.attack_speed = a.attack_speed + b.attack_speed
	result.critical_chance = a.critical_chance + b.critical_chance
	result.critical_multiplier = a.critical_multiplier + b.critical_multiplier
	result.critical_avoid = a.critical_avoid + b.critical_avoid
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
	if index - 1 >= 0:
		_next_index = _next_index - 1 
	else :
		_next_index = array.size() -1
	return _next_index

func get_distance(point1: Vector2i, point2: Vector2i):
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)

#Adds arr2 to arr1 if entyr in unique
func append_array_unique(arr1: Array, arr2:Array):
	for entry in arr2:
		if not arr1.has(entry):
			arr1.append(entry)
	
func sort_item(a:ItemDefinition, b:ItemDefinition):
	# First check rarity,
	if a.rarity != b.rarity:
		return sort_by_rarity(a.rarity, b.rarity)
	# Check Name
	elif a.name != a.name:
		return sort_name 
	# Check Value
	elif a.calculate_price() != b.calculate_price():
		return a.calculate_price() < b.calculate_price()

func sort_item_by_rarity(a:ItemDefinition, b:ItemDefinition):
	return sort_by_rarity(a.rarity, b.rarity)
	
func sort_by_rarity(a: Rarity, b : Rarity):
	return a.sort_score < b.sort_score

func sort_name(a:String, b: String):
	return a < b
