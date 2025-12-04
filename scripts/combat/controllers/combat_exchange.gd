extends Node

class_name CombatExchange

#const crit_sound = preload("res://resources/sounds/combat/Crit.wav")
#const hit_sound = preload("res://resources/sounds/combat/hit.wav")
#const heal_sound = preload("res://resources/sounds/combat/heal.wav")
#const miss_sound = preload("res://resources/sounds/combat/miss.wav")
#const no_damage_sound = preload("res://resources/sounds/combat/no_damage.wav")
const combat_exchange_display = preload("res://ui/combat/combat_exchange/combat_exchange_display/CombatExchangeDisplay.tscn")

signal unit_defeated(unit: CombatUnit)
signal entity_destroyed(entity: CombatEntity)
signal entity_destroyed_processing_completed()
signal item_broken_popup_create(item: ItemDefinition)
signal item_broken_popup_completed()
signal item_expended_popup_create(item: ItemDefinition)
signal item_expended_popup_completed()
signal combat_exchange_finished(friendly_unit_alive: bool)
signal unit_hit_ui(hit_unit: Unit)
signal update_information(text: String)
signal play_audio(sound: AudioStream)
signal play_audio_finished()
signal gain_experience(u: CombatUnit, new_value:int)
signal unit_gain_experience_finished()
signal give_items(items: Array[ItemDefinition], source: String, target: CombatUnit)
signal give_items_complete()

enum EXCHANGE_OUTCOME 
{
	DAMAGE_DEALT,
	ENEMY_DEFEATED,
	PLAYER_DEFEATED,
	NO_DAMAGE,
	MISS,
	ALLY_SUPPORTED
}

var audio_player_busy: bool = false
var in_experience_flow: bool = false
var ce_display : CombatExchangeDisplay
var se_resource : SpecialEffectResource = SpecialEffectResource.new()

var active_funciton

func perform_hit(attacker: CombatUnit, target: CombatUnit, hit_chance:int, critical_chance:int):
	var attacker_specials = attacker.unit.inventory.get_all_specials_from_inventory_and_equipped()
	var target_specials = target.unit.inventory.get_all_specials_from_inventory_and_equipped()
	var damage_dealt
	if check_hit(hit_chance):
		if check_critical(critical_chance) :
			# Is the critical augmented?
			if se_resource.has(SpecialEffect.SPECIAL_EFFECT.NEGATES_FOE_DEFENSE_ON_CRITICAL, attacker_specials):
				damage_dealt = floori(attacker.unit.inventory.get_equipped_weapon().critical_multiplier * calc_damage(attacker, target, true))
			else:
				damage_dealt = floori(attacker.unit.inventory.get_equipped_weapon().critical_multiplier * calc_damage(attacker, target))
			#Check for devil reversal
			if se_resource.has(SpecialEffect.SPECIAL_EFFECT.DEVIL_REVERSAL, attacker_specials):
				var backfire_chance : int = 31 - attacker.get_luck()
				var roll = randi_range(0,100)
				if roll <= backfire_chance: 
					await do_damage(attacker,damage_dealt, true)
				else: 
					await do_damage(target,damage_dealt, true)
			await do_damage(target,damage_dealt, true)
		else : 
			#calc default damage
			damage_dealt = calc_damage(attacker, target)
			#Check for devil reversal
			if se_resource.has(SpecialEffect.SPECIAL_EFFECT.DEVIL_REVERSAL, attacker_specials):
				var backfire_chance : int = 31 - attacker.get_luck()
				var roll = randi_range(0,100)
				if roll <= backfire_chance: 
					await do_damage(attacker,damage_dealt)
				else: 
					await do_damage(target,damage_dealt)
			await do_damage(target,damage_dealt)
		if se_resource.has(SpecialEffect.SPECIAL_EFFECT.VAMPYRIC, attacker_specials):
			var _vampyric_effects = se_resource.get_all_special_effects_with_type(SpecialEffect.SPECIAL_EFFECT.VAMPYRIC, attacker_specials)
			await trigger_heal_unit(attacker, se_resource.calculate_aggregate_effect(_vampyric_effects, damage_dealt))
		#Durability Code
		var broken_item = attacker.unit.inventory.use_item(attacker.get_equipped())
		if broken_item != null:
			item_broken_popup_create.emit(broken_item)
			await item_broken_popup_completed
		elif attacker.unit.inventory.get_equipped_weapon().expended:
			item_expended_popup_create.emit(attacker.unit.inventory.get_equipped_weapon())
			await item_expended_popup_completed
	else : ## Attack has missed
		await hit_missed(target)

func perform_hit_entity(attacker: CombatUnit, target: CombatEntity, hit_damage: int):
	if attacker.get_equipped() != null:
		await do_damage_entity(target,hit_damage)
		attacker.unit.inventory.use_item(attacker.get_equipped())

func do_damage_entity(target: CombatEntity, damage:int):
	if(damage == 0):
		DamageNumbers.no_damage(32* target.map_position + Vector2i(16,16))
		await DamageNumbers.complete
	if (damage > 0):
		DamageNumbers.display_number(damage, (32* target.map_position + Vector2i(16,16)), false)
		target.hp = target.hp - damage
		await DamageNumbers.complete
		if target.hp <= 0:
			target.destroyed = true
			entity_destroyed.emit(target)
			await entity_destroyed_processing_completed

func perform_heal(healer: CombatUnit, recipient: CombatUnit, amount: int):
	#check that it can be used
	var _healing_tool = healer.unit.inventory.get_equipped_weapon()
	if _healing_tool != null:
		if _healing_tool is WeaponDefinition:
			if _healing_tool.support_type == WeaponDefinition.SUPPORT_TYPES.HEAL:
			# Do the heal
				await heal_unit(recipient, amount)
				#Durability Code
				var broken_item = healer.unit.inventory.use_item(healer.get_equipped())
				if broken_item != null:
					item_broken_popup_create.emit(broken_item)
					await item_broken_popup_completed
				elif healer.unit.inventory.get_equipped_weapon().expended:
					item_expended_popup_create.emit(healer.unit.inventory.get_equipped_weapon())
					await item_expended_popup_completed


# Calculates the heal and any bonuses if applicable
func trigger_heal_unit(combat_unit: CombatUnit, amount:int):
	var _healing_amount = amount
	var healed_unit_specials = combat_unit.unit.inventory.get_all_specials_from_inventory_and_equipped()
	if healed_unit_specials.has(SpecialEffect.SPECIAL_EFFECT.INCOMING_HEALING_AUGMENT):
		var _heal_bonus_effects = se_resource.get_all_special_effects_with_type(SpecialEffect.SPECIAL_EFFECT.INCOMING_HEALING_AUGMENT, healed_unit_specials)
		_healing_amount = _healing_amount + se_resource.calculate_aggregate_effect(_heal_bonus_effects, _healing_amount)
	await heal_unit(combat_unit, _healing_amount)

# Does the heal itself
func heal_unit(unit: CombatUnit, amount: int):
	#await use_audio_player(heal_sound)
	AudioManager.play_sound_effect_pitch_randomized("unit_heal")
	unit.current_hp = clampi(amount + unit.current_hp, unit.current_hp, unit.get_max_hp())
	DamageNumbers.heal((32* unit.move_position + Vector2i(16,16)), amount)
	unit.map_display.update_values()
	if ce_display != null:
		await ce_display.update_unit_hp(unit, unit.current_hp)
	await DamageNumbers.complete

func hit_missed(dodging_unit: CombatUnit):
	await AudioManager.play_sound_effect_pitch_randomized("sword_swing_light")
	DamageNumbers.miss(32* dodging_unit.map_position + Vector2i(16,16))
	await DamageNumbers.complete

func complete_combat_exchange(player_unit:CombatUnit, enemy_unit:CombatUnit, combat_exchange_outcome: EXCHANGE_OUTCOME):
	# get unit specials 
	var player_unit_specials : Array[SpecialEffect]
	var enemy_unit_specials : Array[SpecialEffect]
	if player_unit != null:
		player_unit_specials = player_unit.unit.inventory.get_all_specials_from_inventory_and_equipped()
	if enemy_unit != null:
		enemy_unit_specials = enemy_unit.unit.inventory.get_all_specials_from_inventory_and_equipped()
	
	#check if the player unit has broken or expended its weapon and equip a new one
	if player_unit.unit.inventory.equipped == false:
		player_unit.unit.equip_next_available_weapon()
	elif player_unit.unit.inventory.get_equipped_weapon().expended and player_unit.unit.inventory.equipped:
		player_unit.unit.inventory.send_back()
		player_unit.unit.equip_next_available_weapon()
	
	if se_resource.has(SpecialEffect.SPECIAL_EFFECT.HEAL_ON_COMBAT_EXCHANGE_END, player_unit_specials):
		var _heal_weight = se_resource.get_all_special_effects_with_type(SpecialEffect.SPECIAL_EFFECT.HEAL_ON_COMBAT_EXCHANGE_END, player_unit_specials)
		await heal_unit(player_unit, _heal_weight)
	if se_resource.has(SpecialEffect.SPECIAL_EFFECT.HEAL_ON_COMBAT_EXCHANGE_END, enemy_unit_specials):
		var _heal_weight = se_resource.get_all_special_effects_with_type(SpecialEffect.SPECIAL_EFFECT.HEAL_ON_COMBAT_EXCHANGE_END, enemy_unit_specials)
		await heal_unit(enemy_unit, _heal_weight)
	if ce_display != null:
		ce_display.queue_free()
	if combat_exchange_outcome == EXCHANGE_OUTCOME.PLAYER_DEFEATED:
		emit_signal("unit_defeated", player_unit)
		combat_exchange_finished.emit(false)
		return
	elif combat_exchange_outcome == EXCHANGE_OUTCOME.MISS or combat_exchange_outcome == EXCHANGE_OUTCOME.NO_DAMAGE:
		emit_signal("gain_experience", player_unit, 1)
		update_ai_type(enemy_unit)
		await unit_gain_experience_finished
	elif combat_exchange_outcome == EXCHANGE_OUTCOME.DAMAGE_DEALT:
		emit_signal("gain_experience", player_unit, calculate_experience_gain_hit(player_unit, enemy_unit))
		update_ai_type(enemy_unit)
		await unit_gain_experience_finished
	elif combat_exchange_outcome == EXCHANGE_OUTCOME.ENEMY_DEFEATED:
		emit_signal("unit_defeated", enemy_unit)
		emit_signal("gain_experience", player_unit, calculate_experience_gain_kill(player_unit, enemy_unit))
		await unit_gain_experience_finished
		if enemy_unit.drops_item:
			var dropped_items : Array[ItemDefinition]
			dropped_items.append(enemy_unit.unit.inventory.items.pop_back())
			give_items.emit(dropped_items, CombatMapConstants.COMBAT_EXCHANGE, player_unit)
			await give_items_complete
	elif combat_exchange_outcome == EXCHANGE_OUTCOME.ALLY_SUPPORTED:
		emit_signal("gain_experience", player_unit, 20)
		await unit_gain_experience_finished
	combat_exchange_finished.emit(true)

func do_damage(target: CombatUnit, damage:int, is_critical: bool = false):
	#check and see if it actually does any damage
	#var outcome : int
	if(damage == 0):
		#outcome = DAMAGE_OUTCOME.NO_DAMAGE
		#await use_audio_player(no_damage_sound)
		#AudioManager.play_sound_effect_pitch_randomized("unit_no_damage")
		AudioManager.play_sound_effect_pitch_randomized("sword_swing_light")
		AudioManager.play_sound_effect_pitch_randomized("no_damage")
		DamageNumbers.no_damage(32* target.map_position + Vector2i(16,16))
		#play no damage noise
		await DamageNumbers.complete
	if (damage > 0):
		target.current_hp -= damage
		#outcome = DAMAGE_OUTCOME.DAMAGE_DEALT
		if is_critical:
			#await use_audio_player(crit_sound)
			#AudioManager.play_sound_effect_pitch_randomized("unit_crit")
			#AudioManager.play_sound_effect_pitch_randomized("sword_swing_heavy")
			AudioManager.play_sound_effect("crit_sound")
			AudioManager.play_sound_effect_pitch_randomized("flesh_impact")
			DamageNumbers.display_number(damage, (32* target.map_position + Vector2i(16,16)), true)
		else :
			#await use_audio_player(hit_sound)
			#AudioManager.play_sound_effect_pitch_randomized("unit_hit")
			AudioManager.play_sound_effect_pitch_randomized("sword_swing_light")
			AudioManager.play_sound_effect_pitch_randomized("flesh_impact")
			DamageNumbers.display_number(damage, (32* target.map_position + Vector2i(16,16)), false)
		target.map_display.update_values()
		await ce_display.update_unit_hp(target, target.current_hp) and DamageNumbers.complete
	##check and see if the unit has died
	if target.current_hp <= 0:
		#outcome = DAMAGE_OUTCOME.OPPONENT_DEFEATED
		target.map_display.update_values()
		await target.map_display.update_complete
		target.alive = false
		#broadcast unit death
	#return outcome

func calc_hit_staff(attacker: Unit, target: CombatUnit, staff: WeaponDefinition) :
	return clamp((staff.hit + attacker.skill + attacker.magic) - target.calc_map_avoid_staff(), 0, 100)

func calc_hit(attacker: CombatUnit, target: CombatUnit) -> int:
	const wpn_triangle_hit_bonus = 20
	var wpn_triangle_hit_active_bonus = 0
	if (check_weapon_triangle(attacker.unit, target.unit) == attacker.unit): 
		wpn_triangle_hit_active_bonus = wpn_triangle_hit_bonus
	elif (check_weapon_triangle(attacker.unit, target.unit) == target.unit): 
		wpn_triangle_hit_active_bonus = - wpn_triangle_hit_bonus
	return clamp(attacker.get_hit() + wpn_triangle_hit_active_bonus - target.calc_map_avoid(), 0, 100)

func calc_crit(attacker: CombatUnit, target: CombatUnit) -> int:
	if se_resource.get_all_special_effect_types(target.unit.inventory.get_all_specials_from_inventory_and_equipped()).has(SpecialEffect.SPECIAL_EFFECT.CRITICAL_PROOF) or se_resource.get_all_special_effect_types(attacker.unit.inventory.get_all_specials_from_inventory_and_equipped()).has(SpecialEffect.SPECIAL_EFFECT.CRITICAL_PROOF):
		return 0
	return clamp(attacker.get_critical_chance() - target.get_critical_avoid(), 0, 100)

func calc_damage(attacker: CombatUnit, target: CombatUnit, defense_negated : bool = false) -> int:
	var max_damage
	var damage
	const wpn_triangle_damage_bonus = 2
	const effective_damage_multiplier = 3 #this is 3x but we account for non crit wpn damage in calc now so it is -1'd in formula
	var effective = false
	var wpn_triangle_active_bonus = 0
	var defense_mult = 1
	
	var attacker_specials = attacker.unit.inventory.get_all_specials_from_inventory_and_equipped()
	var target_specials = target.unit.inventory.get_all_specials_from_inventory_and_equipped() 
	#is the weapon effective?
	effective = check_effective(attacker.unit, target.unit)
	#does the attacker have weapon triangle advantage? 
	if (check_weapon_triangle(attacker.unit, target.unit) == attacker.unit): 
		wpn_triangle_active_bonus = wpn_triangle_damage_bonus
	elif (check_weapon_triangle(attacker.unit, target.unit) == target.unit):
		wpn_triangle_active_bonus = - wpn_triangle_damage_bonus
	
	#calculate the maximum damage output before factoring in defenses
	if(effective): 
		max_damage = attacker.get_damage() + wpn_triangle_active_bonus + ((effective_damage_multiplier-1) * attacker.get_equipped().damage)
	else :
		max_damage = attacker.get_damage() + wpn_triangle_active_bonus
	# check the damage type of the source
	
	if defense_negated or se_resource.get_all_special_effect_types(attacker_specials).has(SpecialEffect.SPECIAL_EFFECT.NEGATES_FOE_DEFENSE):
		defense_mult = 0
	if attacker.get_equipped().item_damage_type == Constants.DAMAGE_TYPE.PHYSICAL : 
		damage = clampi(max_damage - (target.get_defense() * defense_mult),0, 999)
	elif attacker.get_equipped().item_damage_type == Constants.DAMAGE_TYPE.MAGIC :
		damage = clampi(max_damage - (target.get_resistance() * defense_mult),0, 999)
	elif attacker.get_equipped().item_damage_type == Constants.DAMAGE_TYPE.TRUE:
		damage = max_damage
	else :
		damage = 0
	return damage

func check_hit(hit_chance: int) -> bool:
	return CustomUtilityLibrary.random_rolls_bool(hit_chance, 2)

func check_critical(critical_chance: int) -> bool:
	return CustomUtilityLibrary.random_rolls_bool(critical_chance, 1)

func check_can_attack(attacker: CombatUnit, defender:CombatUnit, distance:int) -> bool:
	var attacker_weapon = attacker.get_equipped()
	if attacker_weapon is WeaponDefinition:
		#if attacker_weapon.item_target_faction.has(defender.allegience):
		if attacker_weapon.attack_range.has(distance):
			if attacker_weapon.item_target_faction.has(ItemConstants.AVAILABLE_TARGETS.ENEMY):
				return true
	return false

func check_can_retaliate(attacker: CombatUnit, defender:CombatUnit, distance:int) -> bool:
	var defender_weapon = defender.get_equipped()
	var defender_specials =  se_resource.get_all_special_effect_types(defender.unit.inventory.get_all_specials_from_inventory_and_equipped())
	if defender_weapon is WeaponDefinition:
		if not defender_specials.has(SpecialEffect.SPECIAL_EFFECT.CANNOT_RETALIATE):
		#if attacker_weapon.item_target_faction.has(defender.allegience):
			if defender_weapon.attack_range.has(distance):
				if defender_weapon.item_target_faction.has(ItemConstants.AVAILABLE_TARGETS.ENEMY):
					return true
	return false


func generate_combat_exchange_data(attacker: CombatUnit, defender:CombatUnit, distance:int) -> UnitCombatExchangeData:
	#How many hits are performed?
	var return_object : UnitCombatExchangeData = UnitCombatExchangeData.new()
	return_object.attacker = attacker
	return_object.defender = defender
	
	var turn_order :Array[String] = []
	var wpn_triangle = check_weapon_triangle(attacker.unit, defender.unit)
	var defender_can_attack: bool = false
	
	var attacker_hit_chance : int = 0
	var attacker_damage : int = 0
	var attacker_critical_chance : int = 0
	var attacker_effective : bool = false
	var attacker_turns : int = 1
		
	var defender_hit_chance : int = 0
	var defender_damage : int = 0
	var defender_critical_chance : int = 0
	var defender_effective : bool = false
	var defender_turns : int = 1
	
	attacker_hit_chance = calc_hit(attacker, defender)
	attacker_damage = calc_damage(attacker, defender)
	attacker_critical_chance = calc_crit(attacker, defender)
	attacker_effective = check_effective(attacker.unit, defender.unit)
	
	var turn_vector :Vector2i = calc_unit_turn_count(attacker, defender, attacker_turns, defender_turns)
	attacker_turns = turn_vector.x
	defender_turns = turn_vector.y
	
	defender_can_attack = check_can_retaliate(attacker, defender, distance)
	if defender_can_attack:
		defender_hit_chance = calc_hit(defender, attacker)
		defender_damage = calc_damage(defender, attacker)
		defender_critical_chance = calc_crit(defender,attacker)
		defender_effective = check_effective(defender.unit, attacker.unit)
	else :
		defender_turns = 0

	turn_order = create_turn_order(attacker, defender, attacker_turns, defender_turns)
	
	for turn in turn_order:
		var turn_data : UnitCombatExchangeTurnData = UnitCombatExchangeTurnData.new()
		if CustomUtilityLibrary.equals_ignore_case(turn, "ATTACKER"):
			turn_data.owner = attacker
			turn_data.attack_damage = attacker_damage
			turn_data.damage_type = attacker.get_equipped().item_damage_type
			turn_data.effective_damage = attacker_effective
			turn_data.attack_count = attacker.get_equipped().attacks_per_combat_turn
			turn_data.critical = attacker_critical_chance
			turn_data.hit = attacker_hit_chance
		elif CustomUtilityLibrary.equals_ignore_case(turn, "DEFENDER"):
			turn_data.owner = defender
			turn_data.attack_damage = defender_damage
			turn_data.damage_type = defender.get_equipped().item_damage_type
			turn_data.effective_damage = defender_effective
			turn_data.attack_count = defender.get_equipped().attacks_per_combat_turn
			turn_data.critical = defender_critical_chance
			turn_data.hit = defender_hit_chance
		return_object.exchange_data.append(turn_data)
	
	return_object.attacker_critical = attacker_critical_chance
	return_object.attacker_hit = attacker_hit_chance
	return_object.attacker_effective = attacker_effective
	return_object.defender_critical= defender_critical_chance
	return_object.defender_hit = defender_hit_chance
	return_object.defender_effective = defender_effective
	return_object.weapon_triange = wpn_triangle
	return_object.populate()
	return return_object

func generate_support_exchange_data(supporter: CombatUnit, target:CombatUnit, distance:int) -> UnitSupportExchangeData:
	#How many hits are performed?
	var return_object : UnitSupportExchangeData = UnitSupportExchangeData.new()
	var supporter_specials = supporter.unit.inventory.get_all_specials_from_inventory_and_equipped()
	var target_specials = target.unit.inventory.get_all_specials_from_inventory_and_equipped()
	
	return_object.supporter = supporter
	return_object.target = target
	var turn_count = 1
	for turn in turn_count:
		var turn_data : UnitSupportExchangeTurnData = UnitSupportExchangeTurnData.new()
		turn_data.attack_count = supporter.get_equipped().attacks_per_combat_turn
		turn_data.effect_type = supporter.get_equipped().status_ailment
		turn_data.effect_weight = supporter.get_damage()
		
		if se_resource.has(SpecialEffect.SPECIAL_EFFECT.INCOMING_HEALING_AUGMENT, target_specials):
		#if target_specials.has(SpecialEffect.SPECIAL_EFFECT.INCOMING_HEALING_AUGMENT):
			var _heal_bonus_effects = se_resource.get_all_special_effects_with_type(SpecialEffect.SPECIAL_EFFECT.INCOMING_HEALING_AUGMENT, target.unit.inventory.get_all_specials_from_inventory_and_equipped())
			turn_data.effect_weight = turn_data.effect_weight + se_resource.calculate_aggregate_effect(_heal_bonus_effects, turn_data.effect_weight)
		return_object.exchange_data.append(turn_data)
	return_object.populate()
	return return_object

func generate_combat_exchange_data_entity(attacker: CombatUnit, defender:CombatEntity) -> UnitCombatExchangeData:
	var return_object : UnitCombatExchangeData = UnitCombatExchangeData.new()
	return_object.attacker = attacker
	var net_attack_speed = attacker.get_attack_speed() - defender.attack_speed
	var net_turn_count = int(net_attack_speed / floor(4))
	var attacker_turns = 1
	if net_turn_count > 0:
		attacker_turns = attacker_turns + abs(net_turn_count)
	var effective = false
	var attacker_damage = 0
	if(effective): 
		attacker_damage = clampi(attacker.get_damage() + (2 * attacker.get_equipped().damage) - defender.defense, 0, 9999)
	else :
		attacker_damage = clampi(attacker.get_damage() - defender.defense, 0, 9999)
	for attack in attacker_turns:
		var turn_data : UnitCombatExchangeTurnData = UnitCombatExchangeTurnData.new()
		turn_data.owner = attacker
		turn_data.attack_damage = attacker_damage
		turn_data.damage_type = attacker.get_equipped().item_damage_type
		turn_data.effective_damage = false
		turn_data.attack_count = attacker.get_equipped().attacks_per_combat_turn
		turn_data.critical = 0
		turn_data.hit = 100
		return_object.exchange_data.append(turn_data)
	return_object.calc_net_damage()
	return_object.calc_predicted_hp_entity(defender.hp)
	return return_object
	
func create_turn_order(attacker: CombatUnit, defender:CombatUnit, a_turn_count: int, d_turn_count: int) -> Array[String]:
	var _arr : Array[String]  =[]
	var i :int = a_turn_count
	var j :int = d_turn_count
	while i > 0 or j>0:
		if i > 0:
			_arr.append("ATTACKER")
			i = i -1
		if j > 0:
			_arr.append("DEFENDER")
			j = j -1
	return _arr

func calc_unit_turn_count(attacker: CombatUnit, defender:CombatUnit, attacker_turns: int, defender_turns: int) ->Vector2i: #Vector(attacker_turns, defender_turns)
	var _attacker_specials = se_resource.get_all_special_effect_types(attacker.unit.inventory.get_all_specials_from_inventory_and_equipped())
	var _defender_specials = se_resource.get_all_special_effect_types(attacker.unit.inventory.get_all_specials_from_inventory_and_equipped())
	
	var net_attack_speed = attacker.get_attack_speed() - defender.get_attack_speed()
	var additional_turn_threshold = 4
	var net_turn_count = 0
	var _nas = abs(net_attack_speed)
	while _nas - additional_turn_threshold > 0:
		net_turn_count = net_turn_count + 1
		_nas = _nas - additional_turn_threshold
		additional_turn_threshold = additional_turn_threshold + 2
	if net_attack_speed > 0:
		attacker_turns = attacker_turns + abs(net_turn_count)
	elif net_attack_speed < 0: 
		defender_turns = defender_turns + abs(net_turn_count)
	if _attacker_specials.has(SpecialEffect.SPECIAL_EFFECT.CAN_ONLY_ATTACK_ONCE):
		attacker_turns = 1 
	if _defender_specials.has(SpecialEffect.SPECIAL_EFFECT.CAN_ONLY_ATTACK_ONCE):
		defender_turns = 1 
	return Vector2i(attacker_turns, defender_turns)

func check_weapon_triangle(unit_a: Unit, unit_b: Unit) -> Unit:
	# get weapons for analysis
	var _victor : Unit = null
	var unit_a_weapon: WeaponDefinition
	var unit_b_weapon: WeaponDefinition
	if unit_a.inventory.get_equipped_weapon(): 
		unit_a_weapon = unit_a.inventory.get_equipped_weapon()
	if unit_b.inventory.get_equipped_weapon(): 
		unit_b_weapon = unit_b.inventory.get_equipped_weapon()
	# logic block for weapons
	if unit_b_weapon and unit_a_weapon:
		var _winning_weapon = check_wepon_triangle_wpn(unit_a_weapon, unit_b_weapon)
		match _winning_weapon:
			unit_a_weapon:
				_victor = unit_a
			unit_b_weapon:
				_victor = unit_b
	# skill augments etc. here #TO BE ADDED 
	return _victor

func check_wepon_triangle_wpn(wpn_a: WeaponDefinition, wpn_b: WeaponDefinition) -> WeaponDefinition:
	if wpn_a and wpn_b:
		match wpn_a.physical_weapon_triangle_type:
				ItemConstants.MUNDANE_WEAPON_TRIANGLE.AXE:
					if wpn_b.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.SWORD:
						return wpn_b
					elif wpn_b.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.LANCE:
						return wpn_a
				ItemConstants.MUNDANE_WEAPON_TRIANGLE.SWORD:
					if wpn_b.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.LANCE:
						return wpn_b
					elif wpn_b.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.AXE:
						return wpn_a
				ItemConstants.MUNDANE_WEAPON_TRIANGLE.LANCE:
						if wpn_b.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.AXE:
							return wpn_b
						elif wpn_b.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.SWORD:
							return wpn_a
		match wpn_a.magic_weapon_triangle_type:
				ItemConstants.MAGICAL_WEAPON_TRIANGLE.NATURE:
					if wpn_b.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.DARK:
						return wpn_b
					elif wpn_b.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.LIGHT:
						return wpn_a
				ItemConstants.MAGICAL_WEAPON_TRIANGLE.DARK:
					if wpn_b.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.LIGHT:
						return wpn_b
					elif wpn_b.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.NATURE:
						return wpn_a
				ItemConstants.MAGICAL_WEAPON_TRIANGLE.LIGHT:
					if wpn_b.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.NATURE:
						return wpn_b
					elif wpn_b.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.DARK:
						return wpn_a
	return null
	
func use_audio_player(sound:AudioStream):
	if  audio_player_busy:
		await play_audio_finished
		emit_signal("play_audio", sound)
		audio_player_busy = true
	else : 
		emit_signal("play_audio", sound)
		audio_player_busy = true

func check_effective(attacker: Unit, target:Unit) -> bool:
	#check weapon effectiveness
	var _effectiveness = false
	_effectiveness = check_weapon_effective(attacker.inventory.get_equipped_weapon(), target, se_resource.get_all_special_effect_types(attacker.inventory.get_all_specials_from_inventory_and_equipped()))
	# TO BE IMPL SKILLS & ETC that force effectiveness
	return _effectiveness
	
func check_weapon_effective(weapon: WeaponDefinition, target: Unit, attacker_specials: Array[SpecialEffect.SPECIAL_EFFECT] = []) -> bool:
	#var _outcome = false
	var _target_unit_type = UnitTypeDatabase.get_definition(target.unit_type_key)
	var _target_specials =  se_resource.get_all_special_effect_types(target.inventory.get_all_specials_from_inventory_and_equipped())
	var attacker_trait_effectives : Array[unitConstants.TRAITS] = weapon.weapon_effectiveness_trait.duplicate()
	var _target_unit_traits : Array[unitConstants.TRAITS] = _target_unit_type.traits.duplicate()
	if _target_specials.has(SpecialEffect.SPECIAL_EFFECT.EFFECTIVE_PROOF) or attacker_specials.has(SpecialEffect.SPECIAL_EFFECT.CANNOT_DO_EFFECTIVE_DAMAGE):
		return false
	#TRAITS
	# ADD ADDITITONAL TARGET TRAITS FROM ITEMS 
	if _target_specials.has(SpecialEffect.SPECIAL_EFFECT.ADD_ARMOR_EFFECTIVE):
		if not _target_unit_traits.has(unitConstants.TRAITS.ARMORED):
			_target_unit_traits.append(unitConstants.TRAITS.ARMORED)
	if _target_specials.has(SpecialEffect.SPECIAL_EFFECT.ADD_MOUNTED_EFFECTIVE):
		if not _target_unit_traits.has(unitConstants.TRAITS.MOUNTED):
			_target_unit_traits.append(unitConstants.TRAITS.MOUNTED)
	if _target_specials.has(SpecialEffect.SPECIAL_EFFECT.ADD_FLIER_EFFECTIVE):
		if not _target_unit_traits.has(unitConstants.TRAITS.FLIER):
			_target_unit_traits.append(unitConstants.TRAITS.FLIER)
	if _target_specials.has(SpecialEffect.SPECIAL_EFFECT.ADD_TERROR_EFFECTIVE):
		if not _target_unit_traits.has(unitConstants.TRAITS.TERROR):
			_target_unit_traits.append(unitConstants.TRAITS.TERROR)
	
	# REMOVE TARGET TRAITS BC SPECIALS WITH PROTECTION
	if _target_specials.has(SpecialEffect.SPECIAL_EFFECT.REMOVE_ARMOR_EFFECTIVE):
		if _target_unit_traits.has(unitConstants.TRAITS.ARMORED):
			_target_unit_traits.erase(unitConstants.TRAITS.ARMORED)
	if _target_specials.has(SpecialEffect.SPECIAL_EFFECT.REMOVE_MOUNTED_EFFECTIVE):
		if _target_unit_traits.has(unitConstants.TRAITS.MOUNTED):
			_target_unit_traits.erase(unitConstants.TRAITS.MOUNTED)
	if _target_specials.has(SpecialEffect.SPECIAL_EFFECT.REMOVE_FLIER_EFFECTIVE):
		if _target_unit_traits.has(unitConstants.TRAITS.FLIER):
			_target_unit_traits.erase(unitConstants.TRAITS.FLIER)
	if _target_specials.has(SpecialEffect.SPECIAL_EFFECT.REMOVE_TERROR_EFFECTIVE):
		if _target_unit_traits.has(unitConstants.TRAITS.TERROR):
			_target_unit_traits.erase(unitConstants.TRAITS.TERROR)
	
	# ADD ATTACKER TRAITS FROM SPECIALS
	if attacker_specials.has(SpecialEffect.SPECIAL_EFFECT.ADD_ARMOR_EFFECTIVE_ATTACK):
		if not attacker_trait_effectives.has(unitConstants.TRAITS.ARMORED):
			attacker_trait_effectives.append(unitConstants.TRAITS.ARMORED)
	if attacker_specials.has(SpecialEffect.SPECIAL_EFFECT.ADD_MOUNTED_EFFECTIVE_ATTACK):
		if not attacker_trait_effectives.has(unitConstants.TRAITS.MOUNTED):
			attacker_trait_effectives.append(unitConstants.TRAITS.MOUNTED)
	if attacker_specials.has(SpecialEffect.SPECIAL_EFFECT.ADD_FLIER_EFFECTIVE_ATTACK):
		if not attacker_trait_effectives.has(unitConstants.TRAITS.FLIER):
			attacker_trait_effectives.append(unitConstants.TRAITS.FLIER)
	if attacker_specials.has(SpecialEffect.SPECIAL_EFFECT.ADD_TERROR_EFFECTIVE_ATTACK):
		if not attacker_trait_effectives.has(unitConstants.TRAITS.TERROR):
			attacker_trait_effectives.append(unitConstants.TRAITS.TERROR)
	
	#Create special effect and weapon trait effectiveness
	if not attacker_trait_effectives.is_empty():
		# do subtraction of traits if target has something that negates effectiveness here
		if not _target_unit_traits.is_empty():
			for effective_trait in weapon.weapon_effectiveness_trait:
				if effective_trait in _target_unit_traits:
					return true
	#WEAPON_TYPE
	if target.inventory.get_equipped_weapon() != null:
		if target.inventory.get_equipped_weapon().weapon_type in weapon.weapon_effectiveness_weapon_type:
			return true
	#NON-TRAIT SPECIALS
	if not weapon.specials.is_empty():
		if attacker_specials.has(SpecialEffect.SPECIAL_EFFECT.WEAPON_TRIANGLE_ADVANTAGE_EFFECTIVE):
			if  target.inventory.get_equipped_weapon() != null:
				if check_wepon_triangle_wpn(weapon, target.inventory.get_equipped_weapon()) == weapon:
					return true
	return false

func check_unit_can_do_effective_damage(attacker: Unit, target: Unit) -> bool:
	for weapon in attacker.get_equippable_weapons():
		if check_weapon_effective(weapon, target):
			return true
	return false

func audio_player_ready():
	emit_signal("play_audio_finished")
	audio_player_busy = false

func unit_gain_experience(sound:AudioStream):
	if  in_experience_flow:
		await unit_gain_experience_finished
		emit_signal("play_audio", sound)
		in_experience_flow = true
	else : 
		emit_signal("play_audio", sound)
		in_experience_flow = true

func unit_gain_experience_complete():
	emit_signal("unit_gain_experience_finished")
	in_experience_flow = false

#
# Used for healing TODO RE-WRITE THIS FOR BUFFS LATER
#
func enact_support_exchange(supporter: CombatUnit, target:CombatUnit, data:UnitSupportExchangeData):
	var player_unit: CombatUnit
	var enemy_unit: CombatUnit
	# Check to see if it is an an AI or a player attacking ##THIS MAY BE HAVE TO BE RE-WRITTEN FOR ALLY ALLY COMBAT
	for turn in data.exchange_data:
		for attack in turn.attack_count:
			await perform_heal(supporter, target, turn.effect_weight)
	if supporter.allegience == Constants.FACTION.PLAYERS:
		await complete_combat_exchange(supporter, target, EXCHANGE_OUTCOME.ALLY_SUPPORTED)
	else :
		pass
	supporter.turn_taken = true

#
# Called when the attacker can hit and begin combat sequence
#
func enact_combat_exchange_new(attacker: CombatUnit, defender:CombatUnit, exchange_data: UnitCombatExchangeData):
	var player_unit: CombatUnit
	var enemy_unit: CombatUnit 
	# Check to see if it is an an AI or a player attacking ##THIS MAY BE HAVE TO BE RE-WRITTEN FOR ALLY ALLY COMBAT
	if attacker.allegience == Constants.FACTION.PLAYERS:
		player_unit = attacker
		enemy_unit = defender
	else : 
		player_unit = defender
		enemy_unit = attacker
	var enemy_unit_starting_hp : int = enemy_unit.current_hp
	# Create the Display
	ce_display = combat_exchange_display.instantiate()
	await ce_display
	$"../../CanvasLayer/UI".add_child(ce_display) 
	ce_display.visible = true
	ce_display.set_all(attacker, defender, exchange_data.attacker_hit, exchange_data.defender_hit,exchange_data.attacker_net_damage, exchange_data.defender_net_damage, exchange_data.attacker_critical, exchange_data.defender_critical,
		false, false, exchange_data.weapon_triange)
	attacker.turn_taken = true
	#Do the actual calcs
	for turn in exchange_data.exchange_data:
		for attack in turn.attack_count:
			if turn.owner == attacker:
				if attacker.get_equipped() != null and not attacker.get_equipped().expended:
					await perform_hit(attacker,defender,turn.hit,turn.critical)
					if not defender.alive:
						if player_unit == defender:
							await complete_combat_exchange(player_unit, enemy_unit, EXCHANGE_OUTCOME.PLAYER_DEFEATED)
						else : 
							await complete_combat_exchange(player_unit, enemy_unit, EXCHANGE_OUTCOME.ENEMY_DEFEATED)
						return
			elif turn.owner == defender:
				if defender.get_equipped() != null and not defender.get_equipped().expended:
					await perform_hit(defender,attacker,turn.hit,turn.critical)
					if not attacker.alive: 
						if attacker == player_unit: 
							await complete_combat_exchange(player_unit, enemy_unit, EXCHANGE_OUTCOME.PLAYER_DEFEATED)
						else:
							await complete_combat_exchange(player_unit, enemy_unit, EXCHANGE_OUTCOME.ENEMY_DEFEATED)
						return
	# Both units have survived the exchange
	if enemy_unit.current_hp < enemy_unit_starting_hp:
		await complete_combat_exchange(player_unit, enemy_unit, EXCHANGE_OUTCOME.DAMAGE_DEALT)
	else :
		await complete_combat_exchange(player_unit, enemy_unit, EXCHANGE_OUTCOME.NO_DAMAGE)
		#get the allegience of the units

#
# Called when the attacker can hit and begin combat sequence
#
func enact_combat_exchange_entity(attacker: CombatUnit, defender:CombatEntity, exchange_data: UnitCombatExchangeData):
	var player_unit: CombatUnit
	var enemy_unit: CombatUnit
	# Check to see if it is an an AI or a player attacking ##THIS MAY BE HAVE TO BE RE-WRITTEN FOR ALLY ALLY COMBAT
	if attacker.allegience == Constants.FACTION.PLAYERS:
		player_unit = attacker
	attacker.turn_taken = true
	#Do the actual calcs
	for turn : UnitCombatExchangeTurnData in exchange_data.exchange_data:
		for attack in turn.attack_count:
			if turn.owner == attacker:
				if not defender.destroyed:
					await perform_hit_entity(attacker,defender, turn.attack_damage)
				else:
					break

func calculate_experience_gain_hit(player_unit:CombatUnit, enemy_unit:CombatUnit) -> int:
	var experience_gain = 0
	var player_unit_value = 0
	var enemy_unit_value = 0
	if(player_unit.unit.get_unit_type_definition().tier == 3):
		player_unit_value = 20
	if (enemy_unit.unit.get_unit_type_definition().tier == 3) :
		enemy_unit_value = 20
	
	var unit_value_difference = ((enemy_unit.unit.get_unit_type_definition().tier * (enemy_unit.unit.level + enemy_unit_value)) - ((player_unit.unit.level + player_unit_value)))
	#Experience Formula
	
	var tier_multiplier = float(enemy_unit.unit.get_unit_type_definition().tier /player_unit.unit.get_unit_type_definition().tier)
	experience_gain = clamp(tier_multiplier * ((2* unit_value_difference) +31)/ 3, 1, 25)
	return experience_gain

func calculate_experience_gain_kill(player_unit:CombatUnit, enemy_unit:CombatUnit) -> int:
	var experience_gain = 0
	var player_unit_value = 0
	var enemy_unit_value = 0
	var base_experience_gain = calculate_experience_gain_hit(player_unit, enemy_unit)
	var boss_bonus = 0
	var tier_multiplier = float(enemy_unit.unit.get_unit_type_definition().tier /player_unit.unit.get_unit_type_definition().tier)
	if(player_unit.unit.get_unit_type_definition().tier == 3):
		player_unit_value = 60
	if (enemy_unit.unit.get_unit_type_definition().tier == 3) :
		enemy_unit_value = 60
	if enemy_unit.is_boss:
		boss_bonus = 40
	#Experience Formula
	experience_gain = clampi(tier_multiplier*(base_experience_gain + ((enemy_unit.unit.get_unit_type_definition().tier * (enemy_unit.unit.level + enemy_unit_value)) - (player_unit.unit.get_unit_type_definition().tier*(player_unit.unit.level + player_unit_value))) + 20 + boss_bonus), 2, 100)
	return experience_gain

##
# Update the targetted unit's ai type if its an ai unit
##
func update_ai_type(unit: CombatUnit):
	if not unit.is_boss:
		if unit.ai_type == Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE:
			unit.ai_type = Constants.UNIT_AI_TYPE.DEFAULT

func _on_entity_destroyed_processing_completed():
	await get_tree().create_timer(.1).timeout
	entity_destroyed_processing_completed.emit()
	
func _on_give_item_complete():
	give_items_complete.emit()

func _on_item_broken_popup_completed():
#	await get_tree().create_timer(.1).timeout
	item_broken_popup_completed.emit()

func _on_item_expended_popup_completed():
	await get_tree().create_timer(.1).timeout
	item_expended_popup_completed.emit()
