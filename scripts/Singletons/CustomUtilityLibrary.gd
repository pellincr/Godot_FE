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


##Checks if strings are equal ignoring thier case
func equals_ignore_case(string_a: String, string_b : String) -> bool:
	return string_a.to_upper() == string_b.to_upper()

func erase_packedVector2Array(target_array: PackedVector2Array, target:Vector2) -> bool:
	if target_array.has(target):
		target_array.remove_at(target_array.find(target))
		return true
	return false
