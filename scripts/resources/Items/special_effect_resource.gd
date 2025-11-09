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
	var _percent_weight : float = 0
	for special_effect in monotype_effects_list:
		if special_effect.effect_type == SpecialEffect.SPECIAL_EFFECT_WEIGHT_TYPE.FLAT_VALUE:
			_flat_weight = _flat_weight + special_effect.effect_weight
		elif special_effect.effect_type == SpecialEffect.SPECIAL_EFFECT_WEIGHT_TYPE.PERCENTAGE:
			_percent_weight = _percent_weight + special_effect.effect_weight
	return _flat_weight + (int( float(_percent_weight/100) * one_hundred_percent_value))
	
func get_all_special_effect_types(specials: Array[SpecialEffect]) -> Array[SpecialEffect.SPECIAL_EFFECT]:
	var _arr : Array[SpecialEffect.SPECIAL_EFFECT]  = []
	for se in specials:
		if not _arr.has(se.special):
			_arr.append(se.special)
	return _arr
	
func check_activation(se: SpecialEffect, comb: CombatUnit = null) -> bool:
	if se.always_active :
		return true
	var _threshold = se.activation_threshold
	var _chance = se.activation_chance
	# Update thresholds if it is a stat based check
	if comb != null:
		match se.activation_type:
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.RANDOM_CHANCE:
				pass
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.UNIT_STAT_HP:
				_chance = comb.get_max_hp()
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.UNIT_STAT_STRENGTH:
				_chance = comb.get_strength()
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.UNIT_STAT_MAGIC:
				_chance = comb.get_magic()
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.UNIT_STAT_SKILL:
				_chance = comb.get_skill()
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.UNIT_STAT_SPEED:
				_chance = comb.get_speed()
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.UNIT_STAT_LUCK:
				_chance = comb.get_luck()
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.UNIT_STAT_DEFENSE:
				_chance = comb.get_defense()
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.UNIT_STAT_RESISTANCE:
				_chance = comb.get_resistance()
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.UNIT_STAT_MOVEMENT:
				_chance = comb.get_movement()
			SpecialEffect.SPECIAL_EFFECT_ACTIVATION_TYPE.UNIT_STAT_CONSITUTION:
				_chance = comb.get_constitution()
	# Do the roll
	return CustomUtilityLibrary.random_rolls_bool(_chance, 1, _threshold)
