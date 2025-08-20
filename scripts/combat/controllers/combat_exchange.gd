extends Node

class_name CombatExchange

const crit_sound = preload("res://resources/sounds/combat/Crit.wav")
const hit_sound = preload("res://resources/sounds/combat/hit.wav")
const heal_sound = preload("res://resources/sounds/combat/heal.wav")
const miss_sound = preload("res://resources/sounds/combat/miss.wav")
const no_damage_sound = preload("res://resources/sounds/combat/no_damage.wav")
const combat_exchange_display = preload("res://ui/combat/combat_exchange/combat_exchange_display/CombatExchangeDisplay.tscn")

signal unit_defeated(unit: CombatUnit)
signal combat_exchange_finished(friendly_unit_alive: bool)
signal unit_hit_ui(hit_unit: Unit)
signal update_information(text: String)
signal play_audio(sound: AudioStream)
signal play_audio_finished()
signal gain_experience(u: Unit, new_value:int)
signal unit_gain_experience_finished()
enum EXCHANGE_OUTCOME 
{
	DAMAGE_DEALT,
	ENEMY_DEFEATED,
	PLAYER_DEFEATED,
	NO_DAMAGE,
	MISS,
	ALLY_SUPPORTED
}

enum DOUBLE_ATTACKER 
{
	NONE,
	ATTACKER,
	DEFENDER
}
var audio_player_busy: bool = false
var in_experience_flow: bool = false
var ce_display : CombatExchangeDisplay

func perform_hit(attacker: CombatUnit, target: CombatUnit, hit_chance:int, critical_chance:int):
	var damage_dealt
	if check_hit(hit_chance):
		attacker.unit.inventory.get_equipped_weapon().use()
		if check_critical(critical_chance) :
			#emit critical
			damage_dealt = floori(attacker.unit.inventory.get_equipped_weapon().critical_multiplier * calc_damage(attacker, target))
			await do_damage(target,damage_dealt, true)
		else : 
			#emit generic damage
			damage_dealt = calc_damage(attacker, target)
			await do_damage(target,damage_dealt)
		if attacker.unit.inventory.get_equipped_weapon():
			if attacker.unit.inventory.get_equipped_weapon().is_vampyric:
				await heal_unit(attacker, damage_dealt)
	else : ## Attack has missed
		await hit_missed(target)

func perform_heal(attacker: CombatUnit, target: CombatUnit, scaling_type: int):
	if attacker.unit.inventory.get_equipped_weapon() is WeaponDefinition:
		var heal_amount = attacker.unit.inventory.get_equipped_weapon().damage + get_stat_scaling_bonus(attacker.unit, scaling_type)
		attacker.unit.inventory.get_equipped_weapon().use()
		await use_audio_player(heal_sound)
		target.unit.hp = clampi(heal_amount + target.unit.hp, target.unit.hp, target.unit.stats.hp )
		DamageNumbers.heal((32* target.map_position + Vector2i(16,16)), heal_amount)
		target.map_display.update_values()
		await target.map_display.update_complete

func heal_unit(unit: CombatUnit, amount: int):
	await use_audio_player(heal_sound)
	unit.unit.hp = clampi(amount + unit.unit.hp, unit.unit.hp, unit.unit.stats.hp )
	DamageNumbers.heal((32* unit.map_position + Vector2i(16,16)), amount)
	unit.map_display.update_values()
	if ce_display != null:
		await ce_display.update_unit_hp(unit.unit, unit.unit.hp)
	#await unit.map_display.update_complete

func hit_missed(dodging_unt: CombatUnit):
	await use_audio_player(miss_sound)
	DamageNumbers.miss(32* dodging_unt.map_position + Vector2i(16,16))

func complete_combat_exchange(player_unit:Unit, enemy_unit:Unit, combat_exchange_outcome: EXCHANGE_OUTCOME):
	if ce_display != null:
		ce_display.queue_free()
	if combat_exchange_outcome == EXCHANGE_OUTCOME.PLAYER_DEFEATED:
		combat_exchange_finished.emit(false)
		return
	elif combat_exchange_outcome == EXCHANGE_OUTCOME.MISS or combat_exchange_outcome == EXCHANGE_OUTCOME.NO_DAMAGE:
		emit_signal("gain_experience", player_unit, 1)
	elif combat_exchange_outcome == EXCHANGE_OUTCOME.DAMAGE_DEALT:
		emit_signal("gain_experience", player_unit, player_unit.calculate_experience_gain_hit(enemy_unit))
	elif combat_exchange_outcome == EXCHANGE_OUTCOME.ENEMY_DEFEATED:
		emit_signal("gain_experience", player_unit, player_unit.calculate_experience_gain_kill(enemy_unit))
	elif combat_exchange_outcome == EXCHANGE_OUTCOME.ALLY_SUPPORTED:
		emit_signal("gain_experience", player_unit, 10)
	await unit_gain_experience_finished
	combat_exchange_finished.emit(true)

func do_damage(target: CombatUnit, damage:int, is_critical: bool = false):
	#check and see if it actually does any damage
	#var outcome : int
	if(damage == 0):
		#outcome = DAMAGE_OUTCOME.NO_DAMAGE
		await use_audio_player(no_damage_sound)
		DamageNumbers.no_damage(32* target.map_position + Vector2i(16,16))
		#play no damage noise
	if (damage > 0):
		target.unit.hp -= damage
		#outcome = DAMAGE_OUTCOME.DAMAGE_DEALT
		if is_critical:
			await use_audio_player(crit_sound)
			DamageNumbers.display_number(damage, (32* target.map_position + Vector2i(16,16)), true)
		else :
			await use_audio_player(hit_sound)
			DamageNumbers.display_number(damage, (32* target.map_position + Vector2i(16,16)), false)	
		target.map_display.update_values()
		await ce_display.update_unit_hp(target.unit, target.unit.hp)
		#await target.map_display.update_complete
	##check and see if the unit has died
	if target.unit.hp <= 0:
		#outcome = DAMAGE_OUTCOME.OPPONENT_DEFEATED
		target.map_display.update_values()
		await target.map_display.update_complete
		target.alive = false
		emit_signal("unit_defeated", target)
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
	return clamp(attacker.stats.hit.evaluate() + wpn_triangle_hit_active_bonus - target.calc_map_avoid(), 0, 100)

func calc_crit(attacker: Unit, target: Unit) -> int:
	return clamp(attacker.critical_hit - target.critical_avoid, 0, 100)

func calc_damage(attacker: CombatUnit, target: CombatUnit) -> int:
	var max_damage
	var damage
	const wpn_triangle_damage_bonus = 2
	const effective_damage_multiplier = 3 #this is 3x but we account for non crit wpn damage in calc now so it is -1'd in formula
	var effective = false
	var wpn_triangle_active_bonus = 0
	var defense_mult = 1
	#is the weapon effective?
	effective = check_effective(attacker.unit, target.unit)
	#does the attacker have weapon triangle advantage? 
	if (check_weapon_triangle(attacker.unit, target.unit) == attacker.unit): 
		wpn_triangle_active_bonus = wpn_triangle_damage_bonus
	elif (check_weapon_triangle(attacker.unit, target.unit) == target.unit):
		wpn_triangle_active_bonus = - wpn_triangle_damage_bonus
	
	#calculate the maximum damage output before factoring in defenses
	if(effective): 
		max_damage = attacker.stats.damage.evaluate() + wpn_triangle_active_bonus + (effective_damage_multiplier-1 * attacker.get_equipped().damage)
	else :
		max_damage = attacker.stats.damage.evaluate() + wpn_triangle_active_bonus
	# check the damage type of the source
	if attacker.get_equipped().negates_defense:
		defense_mult = 0
	if attacker.get_equipped().item_damage_type == Constants.DAMAGE_TYPE.PHYSICAL : 
		damage = clampi(max_damage - (target.stats.defense.evaluate() * defense_mult),0, 999)
	elif attacker.get_equipped().item_damage_type == Constants.DAMAGE_TYPE.MAGIC :
		damage = clampi(max_damage - (target.stats.resistance.evaluate() * defense_mult),0, 999)
	elif attacker.inventory.item_damage_type == Constants.DAMAGE_TYPE.TRUE:
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
			return true
	return false

func generate_combat_exchange_data(attacker: CombatUnit, defender:CombatUnit, distance:int) -> UnitCombatExchangeData:
	#How many hits are performed?
	var return_object : UnitCombatExchangeData = UnitCombatExchangeData.new()
	return_object.attacker = attacker
	return_object.defender = defender
	
	var turn_order :Array[String] = []
	
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
	attacker_critical_chance = calc_crit(attacker.unit, defender.unit)
	attacker_effective = check_effective(attacker.unit, defender.unit)
	
	calc_unit_turn_count(attacker, defender, attacker_turns, defender_turns)
	
	defender_can_attack = check_can_attack(defender, attacker, distance)
	if defender_can_attack:
		defender_hit_chance = calc_hit(defender, attacker)
		defender_damage = calc_damage(defender, attacker)
		defender_critical_chance = calc_crit(defender.unit,attacker.unit)
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
	return_object.defender_critical= defender_critical_chance
	return_object.defender_hit = defender_hit_chance
	return_object.populate()
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

func calc_unit_turn_count(attacker: CombatUnit, defender:CombatUnit, attacker_turns: int, defender_turns: int):
	if(attacker.stats.attack_speed.evaluate() - defender.stats.attack_speed.evaluate()  >= 4) :
		attacker_turns = 2
	elif (attacker.stats.attack_speed.evaluate()  - attacker.stats.attack_speed.evaluate()  <= - 4) :
		defender_turns = 2

func check_weapon_triangle(unit_a: Unit, unit_b: Unit) -> Unit:
	var unit_a_weapon: WeaponDefinition
	var unit_b_weapon: WeaponDefinition
	if unit_a.inventory.get_equipped_weapon(): 
		unit_a_weapon = unit_a.inventory.get_equipped_weapon()
	if unit_b.inventory.get_equipped_weapon(): 
		unit_b_weapon = unit_b.inventory.get_equipped_weapon()
	if unit_b_weapon and unit_a_weapon:
		match unit_a_weapon.alignment:
			itemConstants.ALIGNMENT.MUNDANE:
				if unit_b_weapon.alignment == itemConstants.ALIGNMENT.NIMBLE:
					return unit_a
				if unit_b_weapon.alignment == itemConstants.ALIGNMENT.DEFENSIVE:
					return unit_b
				match unit_a_weapon.physical_weapon_triangle_type:
					itemConstants.MUNDANE_WEAPON_TRIANGLE.AXE:
						if unit_b_weapon.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.SWORD:
							return unit_b
						elif unit_b_weapon.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.LANCE:
							return unit_a
					itemConstants.MUNDANE_WEAPON_TRIANGLE.SWORD:
						if unit_b_weapon.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.LANCE:
							return unit_b
						elif unit_b_weapon.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.AXE:
							return unit_a
					itemConstants.MUNDANE_WEAPON_TRIANGLE.LANCE:
						if unit_b_weapon.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.AXE:
							return unit_b
						elif unit_b_weapon.physical_weapon_triangle_type == ItemConstants.MUNDANE_WEAPON_TRIANGLE.SWORD:
							return unit_a
			itemConstants.ALIGNMENT.NIMBLE:
				if unit_b_weapon.alignment == itemConstants.ALIGNMENT.MAGIC:
					return unit_a
				if unit_b_weapon.alignment == itemConstants.ALIGNMENT.MUNDANE:
					return unit_b
			itemConstants.ALIGNMENT.MAGIC:
				if unit_b_weapon.alignment == itemConstants.ALIGNMENT.NIMBLE:
					return unit_b
				if unit_b_weapon.alignment == itemConstants.ALIGNMENT.DEFENSIVE:
					return unit_a
				match unit_a_weapon.magic_weapon_triangle_type:
					itemConstants.MAGICAL_WEAPON_TRIANGLE.NATURE:
						if unit_b_weapon.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.DARK:
							return unit_b
						elif unit_b_weapon.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.LIGHT:
							return unit_a
					itemConstants.MAGICAL_WEAPON_TRIANGLE.DARK:
						if unit_b_weapon.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.LIGHT:
							return unit_b
						elif unit_b_weapon.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.NATURE:
							return unit_a
					itemConstants.MAGICAL_WEAPON_TRIANGLE.LIGHT:
						if unit_b_weapon.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.NATURE:
							return unit_b
						elif unit_b_weapon.magic_weapon_triangle_type == ItemConstants.MAGICAL_WEAPON_TRIANGLE.DARK:
							return unit_a
			itemConstants.ALIGNMENT.DEFENSIVE:
				if unit_b_weapon.alignment == itemConstants.ALIGNMENT.MUNDANE:
					return unit_a
				if unit_b_weapon.alignment == itemConstants.ALIGNMENT.MAGIC:
					return unit_b
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
	var _is_effective = false
	if not attacker.inventory.get_equipped_weapon().weapon_effectiveness.is_empty() :
		for effective_type in attacker.inventory.get_equipped_weapon().weapon_effectiveness: 
			var unit_type = UnitTypeDatabase.get_definition(target.unit_type_key)
			if effective_type in unit_type.traits :
				_is_effective = true
	if (check_weapon_triangle(attacker, target) == attacker): 
		if(attacker.inventory.get_equipped_weapon().is_wpn_triangle_effective):
			_is_effective = true
	return _is_effective

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
# Used for healing
#
func enact_support_exchange(attacker: CombatUnit, target:CombatUnit, distance:int):
	var staff : WeaponDefinition
	var give_xp = false
	if attacker.allegience == Constants.FACTION.PLAYERS:
		give_xp = true
	if attacker.unit.inventory.equipped: 
		staff = attacker.unit.inventory.get_equipped_weapon()
		await perform_heal(attacker, target, staff.item_scaling_type)
		if attacker.allegience == Constants.FACTION.PLAYERS:
			await complete_combat_exchange(attacker.unit, target.unit, EXCHANGE_OUTCOME.ALLY_SUPPORTED)
		else :
			pass
	attacker.turn_taken = true

#
# Gets the scaling bonus based on the item scaling type for calc damage
###MOVED CAN THIS BE REMOVED?
func get_stat_scaling_bonus(owner: Unit, item_scaling_type: ItemConstants.SCALING_TYPE) -> int:
	match item_scaling_type:
		ItemConstants.SCALING_TYPE.STRENGTH:
			return owner.stats.strength
		ItemConstants.SCALING_TYPE.SKILL:
			return owner.stats.skill
		ItemConstants.SCALING_TYPE.MAGIC:
			return owner.stats.magic
		ItemConstants.SCALING_TYPE.CONSTITUTION:
			return 0 #THIS NEEDS TO BE IDIATED FURTHER
		ItemConstants.SCALING_TYPE.NONE:
			return 0
	return 0

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
	# Create the Display
	ce_display = combat_exchange_display.instantiate()
	await ce_display
	$"../../CanvasLayer/UI".add_child(ce_display) 
	ce_display.visible = true
	ce_display.set_all(attacker.unit, defender.unit, exchange_data.attacker_hit, exchange_data.defender_hit,exchange_data.attacker_net_damage, exchange_data.defender_net_damage, exchange_data.attacker_critical, exchange_data.defender_critical,
		false, false, check_weapon_triangle(attacker.unit,defender.unit))
	attacker.turn_taken = true
	#Do the actual calcs
	for turn in exchange_data.exchange_data:
		for attack in turn.attack_count:
			if turn.owner == attacker:
				await perform_hit(attacker,defender,turn.hit,turn.critical)
				if not defender.alive:
					unit_defeated.emit(defender)
					if player_unit == defender:
						await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.PLAYER_DEFEATED)
					else : 
						await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.ENEMY_DEFEATED)
					return
			elif turn.owner == defender:
				await perform_hit(defender,attacker,turn.hit,turn.critical)
				if not attacker.alive: 
					if attacker == player_unit: 
						await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.PLAYER_DEFEATED)
					else:
						await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.ENEMY_DEFEATED)
					return
	# Both units have survived the exchange
	await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.DAMAGE_DEALT)
		#get the allegience of the units
