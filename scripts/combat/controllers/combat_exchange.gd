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
#calculates key combat values to show the user potential combat outcomes
#Called when the attacker can hit and begin combat sequence
func enact_combat_exchange(attacker: CombatUnit, defender:CombatUnit, distance:int):
	#Compre attacks speeds to see if anyone is double attacking
	var combat_exchange_calc = calc_combat_exchange_preview(attacker, defender, distance)
	var double_attacker = combat_exchange_calc.double_attacker
	var attacker_hit_chance = combat_exchange_calc.attacker_hit_chance
	var attacker_critical_chance = combat_exchange_calc.attacker_critical_chance
	var defender_can_attack = combat_exchange_calc.defender_can_attack
	var defender_hit_chance = combat_exchange_calc.defender_hit_chance
	var defender_critical_chance = combat_exchange_calc.defender_critical_chance
	var player_unit: CombatUnit
	var enemy_unit: CombatUnit
	
	ce_display = combat_exchange_display.instantiate()
	await ce_display
	$"../../CanvasLayer/UI".add_child(ce_display) 
	ce_display.visible = false
	await ce_display.set_all(attacker.unit, defender.unit, attacker_hit_chance, defender_hit_chance,combat_exchange_calc.attacker_damage, combat_exchange_calc.defender_damage, attacker_critical_chance, defender_critical_chance,
	combat_exchange_calc.attacker_effective, combat_exchange_calc.defender_effective, check_weapon_triangle(attacker.unit,defender.unit))
	ce_display.visible = true
	#get the allegience of the units
	if attacker.allegience == Constants.FACTION.PLAYERS:
		player_unit = attacker
		enemy_unit = defender
	else : 
		player_unit = defender
		enemy_unit = attacker
	attacker.turn_taken = true
	# Perform the first hit
	await perform_hit(attacker,defender,attacker_hit_chance,attacker_critical_chance)
	# Did the defender survive?
	if defender.alive :
		if (defender_can_attack): #Can the defender respond?
			await perform_hit(defender,attacker,defender_hit_chance,defender_critical_chance)
			if attacker.alive :
				if(double_attacker == DOUBLE_ATTACKER.DEFENDER) :
					await perform_hit(defender,attacker,defender_hit_chance,defender_critical_chance)
					if attacker.alive :
						await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.DAMAGE_DEALT)
					else:
						unit_defeated.emit(attacker)
						if player_unit == attacker:
							await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.PLAYER_DEFEATED)
						else : 
							await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.ENEMY_DEFEATED)
				elif (double_attacker == DOUBLE_ATTACKER.ATTACKER) :
					await perform_hit(attacker,defender,attacker_hit_chance,attacker_critical_chance)
					if defender.alive :
						await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.DAMAGE_DEALT)
					else:
						unit_defeated.emit(defender)
						if player_unit == defender:
							await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.PLAYER_DEFEATED)
						else : 
							await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.ENEMY_DEFEATED)
				else:
					await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.DAMAGE_DEALT)
				return
			else: 
				if attacker == player_unit: 
					await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.PLAYER_DEFEATED)
				else:
					await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.ENEMY_DEFEATED)
				return
		else :
			if(double_attacker == DOUBLE_ATTACKER.ATTACKER) : # does the attacker attack twice?
				await perform_hit(attacker,defender,attacker_hit_chance,attacker_critical_chance)
				if defender.alive :
					await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.DAMAGE_DEALT)
				else:
					unit_defeated.emit(defender)
					if player_unit == defender:
						await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.PLAYER_DEFEATED)
					else : 
						await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.ENEMY_DEFEATED)
				return
			else : 
				await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.DAMAGE_DEALT)
				return
	else:
		unit_defeated.emit(defender)
		if player_unit == defender:
			await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.PLAYER_DEFEATED)
		else : 
			await complete_combat_exchange(player_unit.unit, enemy_unit.unit, EXCHANGE_OUTCOME.ENEMY_DEFEATED)
		return

func perform_hit(attacker: CombatUnit, target: CombatUnit, hit_chance:int, critical_chance:int):
	var damage_dealt
	if check_hit(hit_chance):
		attacker.unit.inventory.equipped.use()
		if check_critical(critical_chance) :
			#emit critical
			damage_dealt = 3 * calc_damage(attacker.unit, target.unit)
			await do_damage(target,damage_dealt, true)
		else : 
			#emit generic damage
			damage_dealt = calc_damage(attacker.unit, target.unit)
			await do_damage(target,damage_dealt)
		if attacker.unit.inventory.equipped is WeaponDefinition:
			if attacker.unit.inventory.equipped.is_vampyric:
				await heal_unit(attacker, damage_dealt)
	else : ## Attack has missed
		await hit_missed(target)

func perform_heal(attacker: CombatUnit, target: CombatUnit, scaling_type: int):
	var heal_amount = calc_damage(attacker.unit, target.unit)
	attacker.unit.inventory.equipped.use()
	await use_audio_player(heal_sound)
	target.unit.hp = clampi(heal_amount + target.unit.hp, target.unit.hp, target.unit.stats.hp )
	DamageNumbers.heal((32* target.map_tile.position + Vector2i(16,16)), heal_amount)
	target.map_display.update_values()
	await target.map_display.update_complete

func heal_unit(unit: CombatUnit, amount: int):
	await use_audio_player(heal_sound)
	unit.unit.hp = clampi(amount + unit.unit.hp, unit.unit.hp, unit.unit.stats.hp )
	DamageNumbers.heal((32* unit.map_tile.position + Vector2i(16,16)), amount)
	unit.map_display.update_values()
	if ce_display != null:
		await ce_display.update_unit_hp(unit.unit, unit.unit.hp)
	#await unit.map_display.update_complete
	
func hit_missed(dodging_unt: CombatUnit):
	await use_audio_player(miss_sound)
	DamageNumbers.miss(32* dodging_unt.map_tile.position + Vector2i(16,16))

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
		DamageNumbers.no_damage(32* target.map_tile.position + Vector2i(16,16))
		#play no damage noise
	if (damage > 0):
		target.unit.hp -= damage
		#outcome = DAMAGE_OUTCOME.DAMAGE_DEALT
		if is_critical:
			await use_audio_player(crit_sound)
			DamageNumbers.display_number(damage, (32* target.map_tile.position + Vector2i(16,16)), true)
		else :
			await use_audio_player(hit_sound)
			DamageNumbers.display_number(damage, (32* target.map_tile.position + Vector2i(16,16)), false)	
		target.map_display.update_values()
		await ce_display.update_unit_hp(target.unit, target.unit.hp)
		#await target.map_display.update_complete
	##check and see if the unit has died
	if target.unit.hp <= 0:
		#outcome = DAMAGE_OUTCOME.OPPONENT_DEFEATED
		target.alive = false
		target.map_display.update_values()
		await target.map_display.update_complete
		emit_signal("unit_defeated", target)
		#broadcast unit death
	#return outcome

func calc_hit_staff(attacker: Unit, target: CombatUnit, staff: WeaponDefinition) :
	return clamp((staff.hit + attacker.skill + attacker.magic) - target.calc_map_avoid_staff(), 0, 100)

func calc_hit(attacker: Unit, target: CombatUnit) -> int:
	const wpn_triangle_hit_bonus = 20
	var wpn_triangle_hit_active_bonus = 0
	if (check_weapon_triangle(attacker, target.unit) == attacker): 
		wpn_triangle_hit_active_bonus = wpn_triangle_hit_bonus
	elif (check_weapon_triangle(attacker, target.unit) == target.unit): 
		wpn_triangle_hit_active_bonus = - wpn_triangle_hit_bonus
	return clamp(attacker.hit + wpn_triangle_hit_active_bonus - target.calc_map_avoid(), 0, 100)

func calc_crit(attacker: Unit, target: Unit) -> int:
	return clamp(attacker.critical_hit - target.critical_avoid, 0, 100)

func calc_damage(attacker: Unit, target: Unit) -> int:
	var damage
	const wpn_triangle_damage_bonus = 2
	const effective_damage_multiplier = 3
	var effective = false
	var wpn_triangle_active_bonus = 0
	var defense_mult = 1
	#is the weapon effective?
	effective = check_effective(attacker, target)
	#does the attacker have weapon triangle advantage? 
	if attacker.inventory.equipped.negates_defense:
		defense_mult = 0
	if (check_weapon_triangle(attacker, target) == attacker): 
		wpn_triangle_active_bonus = wpn_triangle_damage_bonus
	elif (check_weapon_triangle(attacker, target) == target):
		wpn_triangle_active_bonus = - wpn_triangle_damage_bonus
	#get the item damage_type
	if attacker.inventory.equipped.item_damage_type == Constants.DAMAGE_TYPE.PHYSICAL : 
		if(effective): 
			damage = (attacker.stats.strength + wpn_triangle_active_bonus + (effective_damage_multiplier * attacker.inventory.equipped.damage)) - (target.stats.defense * defense_mult)
		else :
			damage = (attacker.stats.strength + wpn_triangle_active_bonus + attacker.inventory.equipped.damage) - (target.stats.defense * defense_mult)
	elif attacker.inventory.equipped.item_damage_type == Constants.DAMAGE_TYPE.MAGIC :
		if(effective): 
			damage = (attacker.stats.magic + wpn_triangle_active_bonus + (effective_damage_multiplier * attacker.inventory.equipped.damage)) - (target.stats.resistance * defense_mult)
		else :
			damage = (attacker.stats.magic + wpn_triangle_active_bonus + attacker.inventory.equipped.damage) - (target.stats.resistance * defense_mult)
	return clamp(damage, 0, INF)

func check_hit(hit_chance: int) -> bool:
	return CustomUtilityLibrary.random_rolls_bool(hit_chance, 2)

func check_critical(critical_chance: int) -> bool:
	return CustomUtilityLibrary.random_rolls_bool(critical_chance, 1)

func check_double(unit_attacker: Unit, unit_defender:Unit) -> int:
	if(unit_attacker.attack_speed - unit_defender.attack_speed >= 4) :
		return DOUBLE_ATTACKER.ATTACKER
	elif (unit_attacker.attack_speed - unit_defender.attack_speed <= - 4) :
		return DOUBLE_ATTACKER.DEFENDER
	else :
		return DOUBLE_ATTACKER.NONE

func check_can_attack(attacker: CombatUnit, defender:CombatUnit, distance:int) -> bool:
	if attacker.unit.inventory.equipped: 
		if attacker.unit.inventory.equipped is WeaponDefinition:
			if not attacker.unit.inventory.equipped.weapon_type == ItemConstants.WEAPON_TYPE.STAFF:
				if attacker.unit.inventory.equipped.item_target_faction == WeaponDefinition.AVAILABLE_TARGETS.ENEMY:
					if attacker.unit.inventory.equipped.attack_range.has(distance):
						return true
	return false

func calc_combat_exchange_preview(attacker: CombatUnit, defender:CombatUnit, distance:int) -> Dictionary:
	var defender_can_attack: bool = false
	var defender_hit_chance : int = 0
	var defender_damage : int = 0
	var defender_critical_chance : int = 0
	var defender_effective : bool = false
	var attacker_effective : bool = false
	attacker_effective = check_effective(attacker.unit, defender.unit)
	if defender.unit.inventory.equipped:
		defender_can_attack = check_can_attack(defender, attacker, distance)
		defender_hit_chance = calc_hit(defender.unit, attacker)
		defender_damage = calc_damage(defender.unit, attacker.unit)
		defender_critical_chance = calc_crit(defender.unit,attacker.unit)
		defender_effective = check_effective(defender.unit, attacker.unit)
	var combat_exchange_preview = {
		"double_attacker" = check_double(attacker.unit, defender.unit),
		"defender_can_attack" = defender_can_attack,
		"attacker_hit_chance" = calc_hit(attacker.unit, defender),
		"attacker_damage" = calc_damage(attacker.unit, defender.unit),
		"attacker_critical_chance" = calc_crit(attacker.unit, defender.unit),
		"attacker_effective" =  attacker_effective,
		"defender_hit_chance" = defender_hit_chance,
		"defender_damage" = defender_damage,
		"defender_critical_chance" = defender_critical_chance,
		"defender_effective" =  defender_effective,
	}
	return combat_exchange_preview

func check_weapon_triangle(unit_a: Unit, unit_b: Unit) -> Unit:
	var unit_a_weapon: WeaponDefinition
	var unit_b_weapon: WeaponDefinition
	if unit_a.inventory.equipped: 
		unit_a_weapon = unit_a.inventory.equipped
	if unit_b.inventory.equipped: 
		unit_b_weapon = unit_b.inventory.equipped
	if unit_b_weapon and unit_a_weapon:
		#"none", "Axe", "Sword", "Lance" PHYSICAL
		if not (CustomUtilityLibrary.equals_ignore_case(unit_a_weapon.physical_weapon_triangle_type, "none") or CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.physical_weapon_triangle_type, "none")): 
			if not (CustomUtilityLibrary.equals_ignore_case(unit_a_weapon.physical_weapon_triangle_type, unit_b_weapon.physical_weapon_triangle_type)):
				if CustomUtilityLibrary.equals_ignore_case(unit_a_weapon.physical_weapon_triangle_type, "Axe"):
					if CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.physical_weapon_triangle_type, "Lance"):
						return unit_a
					elif CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.physical_weapon_triangle_type, "Sword"):
						return unit_b
				elif CustomUtilityLibrary.equals_ignore_case(unit_a_weapon.physical_weapon_triangle_type, "Sword"):
					if CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.physical_weapon_triangle_type, "Axe"):
						return unit_a
					elif CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.physical_weapon_triangle_type, "Lance"):
						return unit_b
				elif CustomUtilityLibrary.equals_ignore_case(unit_a_weapon.physical_weapon_triangle_type, "Lance"):
					if CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.physical_weapon_triangle_type, "Sword"):
						return unit_a
					elif CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.physical_weapon_triangle_type, "Axe"):
						return unit_b
		#("none","Dark", "Light", "Nature") Magic
		elif not (CustomUtilityLibrary.equals_ignore_case(unit_a_weapon.magic_weapon_triangle_type, "none") or CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.magic_weapon_triangle_type, "none")): 
			if not (CustomUtilityLibrary.equals_ignore_case(unit_a_weapon.magic_weapon_triangle_type, unit_b_weapon.magic_weapon_triangle_type)):
				if CustomUtilityLibrary.equals_ignore_case(unit_a_weapon.magic_weapon_triangle_type, "Dark"):
					if CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.magic_weapon_triangle_type, "Nature"):
						return unit_a
					elif CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.magic_weapon_triangle_type, "Light"):
						return unit_b
				elif CustomUtilityLibrary.equals_ignore_case(unit_a_weapon.magic_weapon_triangle_type, "Light"):
					if CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.magic_weapon_triangle_type, "Dark"):
						return unit_a
					elif CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.magic_weapon_triangle_type, "Nature"):
						return unit_b
				elif CustomUtilityLibrary.equals_ignore_case(unit_a_weapon.magic_weapon_triangle_type, "Nature"):
					if CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.magic_weapon_triangle_type, "Light"):
						return unit_a
					elif CustomUtilityLibrary.equals_ignore_case(unit_b_weapon.magic_weapon_triangle_type, "Dark"):
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
	if not attacker.inventory.equipped.weapon_effectiveness.is_empty() :
		for effective_type in attacker.inventory.equipped.weapon_effectiveness: 
			var unit_type
			if UnitTypeDatabase.unit_types.keys().has(target.unit_type_key):
				unit_type = UnitTypeDatabase.unit_types[target.unit_type_key]
			else:
				unit_type = CommanderDatabase.commander_types[target.unit_type_key]
			if effective_type in unit_type.traits :
				_is_effective = true
	if (check_weapon_triangle(attacker, target) == attacker): 
		if(attacker.inventory.equipped.is_wpn_triangle_effective):
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

func enact_staff_exchange(attacker: CombatUnit, defender:CombatUnit, distance:int):
	#Compre attacks speeds to see if anyone is double attacking
	var staff : WeaponDefinition
	var give_xp = false
	#get the allegience of the units
	if attacker.allegience == Constants.FACTION.PLAYERS:
		give_xp = true
	attacker.turn_taken = true
	if attacker.unit.inventory.equipped is WeaponDefinition and attacker.unit.inventory.equipped.item_type == 1:
		staff = attacker.unit.inventory.equipped
		if staff.item_damage_type == WeaponDefinition.DAMAGE_TYPE.MAGICAL:
			if staff.weapon_hit_effect == WeaponDefinition.HIT_EFFECT.HEAL: 
				await perform_heal(attacker, defender, staff.item_damage_type)
				if attacker.allegience == Constants.FACTION.PLAYERS:
					await complete_combat_exchange(attacker.unit, defender.unit, EXCHANGE_OUTCOME.ALLY_SUPPORTED)
			elif staff.weapon_hit_effect ==  WeaponDefinition.HIT_EFFECT.PHYSICAL_DAMAGE or staff.item_hit_effect == WeaponDefinition.HIT_EFFECT.MAGICAL_DAMAGE : 
				## NEEDS TO BE FLUSHED OUT
				var attacker_hit_chance = calc_hit_staff(attacker.unit,defender,staff)
				await perform_hit(attacker,defender,attacker_hit_chance, 0)
				return
			else :
				pass
