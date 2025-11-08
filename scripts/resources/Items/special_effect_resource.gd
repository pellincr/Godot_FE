extends Resource
class_name SpecialEffectResource

func has(target_effect :SpecialEffect.SPECIAL_EFFECT, specials: Array[SpecialEffect]) -> bool:
	for special_effect in specials:
		if special_effect.special == target_effect:
			return true
	return false

func get_all_special_effects_with_type(target_effect :SpecialEffect.SPECIAL_EFFECT, specials: Array[SpecialEffect]) ->  Array[SpecialEffect]:
	var _arr : Array[SpecialEffect] = []
	for special_effect in specials:
		if special_effect.special == target_effect:
			_arr.append(special_effect)
	return _arr

func get_various_special_effects_with_type(target_effects :Array[SpecialEffect.SPECIAL_EFFECT], specials: Array[SpecialEffect]) -> Array[SpecialEffect]:
	var _arr : Array[SpecialEffect] = []
	for special_effect in specials:
		if target_effects.has(special_effect.special):
			_arr.append(special_effect)
	return _arr

# Calculates the total value for the effect combining flat & percent so effect operation only happens once
func calculate_aggregate_effect(monotype_effects_list :Array[SpecialEffect], one_hundred_percent_value: int) -> int:
	var _flat_weight :int = 0
	var _percent_weight : int = 0
	for special_effect in monotype_effects_list:
		if special_effect.effect_type == SpecialEffect.SPECIAL_EFFECT_WEIGHT_TYPE.FLAT_VALUE:
			_flat_weight = _flat_weight + special_effect.effect_weight
		elif special_effect.effect_type == SpecialEffect.SPECIAL_EFFECT_WEIGHT_TYPE.PERCENTAGE:
			_percent_weight = _percent_weight + special_effect.effect_weight
	return _flat_weight + (int(_percent_weight *one_hundred_percent_value))
	
func get_all_special_effect_types(specials: Array[SpecialEffect]) -> Array[SpecialEffect.SPECIAL_EFFECT]:
	var _arr : Array[SpecialEffect.SPECIAL_EFFECT]  = []
	for se in specials:
		if not _arr.has(se.special):
			_arr.append(se.special)
	return _arr
	
