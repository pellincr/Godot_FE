extends Node

class_name CombatExchange

const crit_sound = preload("res://resources/sounds/combat/Crit.wav")
const hit_sound = preload("res://resources/sounds/combat/hit.wav")
const miss_sound = preload("res://resources/sounds/combat/miss.wav")
const no_damage_sound = preload("res://resources/sounds/combat/no_damage.wav")

signal unit_defeated(unit: CombatUnit)
signal combat_exchange_finished()
signal unit_hit_ui(hit_unit: Unit)
signal update_information(text: String)
signal play_audio(sound: AudioStream)
signal play_audio_finished()
signal gain_experience(u: Unit, new_value:int)
signal unit_gain_experience_finished()
enum DAMAGE_OUTCOME 
{
	DAMAGE_DEALT,
	DEFENDER_DEFEATED,
	ATTACKER_DEFEATED,
	NO_DAMAGE,
	MISS
}

enum DOUBLE_ATTACKER 
{
	NONE,
	ATTACKER,
	DEFENDER
}
var audio_player_busy: bool = false
var in_experience_flow: bool = false
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
	## Emit the combat UI to be populated?
	await perform_hit(attacker,defender,attacker_hit_chance,attacker_critical_chance)
	## Is the defender alive?
	if defender.alive :
		if (defender_can_attack): 
			await perform_hit(defender,attacker,defender_hit_chance,defender_critical_chance)
			if attacker.alive :
				if(double_attacker == DOUBLE_ATTACKER.DEFENDER) :
					await perform_hit(defender,attacker,defender_hit_chance,defender_critical_chance)
				elif (double_attacker == DOUBLE_ATTACKER.ATTACKER) :
					if defender.alive :
						await perform_hit(attacker,defender,attacker_hit_chance,attacker_critical_chance)
					else:
						unit_defeated.emit(defender)
						emit_signal("gain_experience", attacker.unit, attacker.unit.calculate_experience_gain_kill(defender.unit))
						combat_exchange_finished.emit()
						attacker.turn_taken = true
						return
			else: 
				unit_defeated.emit(attacker)
				combat_exchange_finished.emit()
				attacker.turn_taken = true
				return
		else :
			if(double_attacker == DOUBLE_ATTACKER.ATTACKER) :
				if defender.alive :
					await perform_hit(attacker,defender,attacker_hit_chance,attacker_critical_chance)
				else:
					unit_defeated.emit(defender)
					emit_signal("gain_experience", attacker.unit, attacker.unit.calculate_experience_gain_kill(defender.unit))
					combat_exchange_finished.emit()
					attacker.turn_taken = true
					return
	else:
		unit_defeated.emit(defender)
		emit_signal("gain_experience", attacker.unit, attacker.unit.calculate_experience_gain_kill(defender.unit))
		combat_exchange_finished.emit()
		attacker.turn_taken = true
		return
	emit_signal("gain_experience", attacker.unit, attacker.unit.calculate_experience_gain_hit(defender.unit))
	attacker.turn_taken = true
	combat_exchange_finished.emit()


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
	else : ## Attack has missed
		await hit_missed(target)

func hit_missed(dodging_unt: CombatUnit):
	await use_audio_player(miss_sound)
	DamageNumbers.miss(32* dodging_unt.map_position + Vector2i(16,16))
	

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
			DamageNumbers.display_number(damage, (32* target.map_position + Vector2i(16,16)), false, true)
		else :
			await use_audio_player(hit_sound)
			DamageNumbers.display_number(damage, (32* target.map_position + Vector2i(16,16)), false)
		target.map_display.update_values()
		await target.map_display.update_complete
	##check and see if the unit has died
	if target.unit.hp <= 0:
		#outcome = DAMAGE_OUTCOME.OPPONENT_DEFEATED
		target.alive = false
		target.map_display.update_values()
		await target.map_display.update_complete
		emit_signal("unit_defeated", target)
		#broadcast unit death
	#return outcome

func calc_hit(attacker: Unit, target: Unit) -> int:
	return clamp(attacker.hit - target.avoid, 0, 100)

func calc_crit(attacker: Unit, target: Unit) -> int:
	return clamp(attacker.critical_hit - target.critical_avoid, 0, 100)

func calc_damage(attacker: Unit, target: Unit) -> int:
	var damage
	#is it a critical?
	var effective_damage_multiplier = 3
	var effective = false
	#is the weapon effective?
	if not attacker.inventory.equipped.weapon_effectiveness.is_empty() :
		if attacker.inventory.equipped.weapon_effectiveness == UnitTypeDatabase.unit_types[target.unit_class_key].class_type :
			effective = true
	#get the item damage_type
	if attacker.inventory.equipped.item_damage_type == Constants.DAMAGE_TYPE.PHYSICAL : 
		if(effective): 
			damage = (attacker.strength + effective_damage_multiplier * attacker.inventory.equipped.damage) - target.defense
		else :
			damage = (attacker.strength + attacker.inventory.equipped.damage) - target.defense
	elif attacker.inventory.equipped.item_damage_type == Constants.DAMAGE_TYPE.MAGIC :
		if(effective): 
			damage = (attacker.magic + effective_damage_multiplier * attacker.inventory.equipped.damage) - target.magic_defense
		else :
			damage = (attacker.magic + attacker.inventory.equipped.damage) - target.magic_defense
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

func calc_combat_exchange_preview(attacker: CombatUnit, defender:CombatUnit, distance:int) -> Dictionary:
	var defender_can_attack: bool = false
	var defender_hit_chance : int = 0
	var defender_damage : int = 0
	var defender_critical_chance : int = 0
	var defender_effective : bool = false
	var attacker_effective : bool = false
	if attacker.unit.inventory.equipped.weapon_effectiveness == UnitTypeDatabase.unit_types[defender.unit.unit_class_key].class_type: 
		attacker_effective = true
	if defender.unit.inventory.equipped:
		defender_can_attack = defender.unit.inventory.equipped.attack_range.has(distance)
		defender_hit_chance = calc_hit(defender.unit, attacker.unit)
		defender_damage = calc_damage(defender.unit, attacker.unit)
		defender_critical_chance = calc_crit(defender.unit,attacker.unit)
		if	defender.unit.inventory.equipped.weapon_effectiveness == UnitTypeDatabase.unit_types[attacker.unit.unit_class_key].class_type:
			defender_effective = true
	var combat_exchange_preview = {
		"double_attacker" = check_double(attacker.unit, defender.unit),
		"defender_can_attack" = defender_can_attack,
		"attacker_hit_chance" = calc_hit(attacker.unit, defender.unit),
		"attacker_damage" = calc_damage(attacker.unit, defender.unit),
		"attacker_critical_chance" = calc_crit(attacker.unit, defender.unit),
		"attacker_effective" =  attacker_effective,
		"defender_hit_chance" = defender_hit_chance,
		"defender_damage" = defender_damage,
		"defender_critical_chance" = defender_critical_chance,
		"defender_effective" =  defender_effective,
	}
	return combat_exchange_preview


#func do_damage_old(attacker: CombatUnit, target: CombatUnit):
	#var item = attacker.unit.inventory.equipped
	#var damage
	#if item.item_damage_type == 0 : ##Physical Dmg
		#damage = (attacker.unit.strength + item.damage) - target.unit.defense ##TO BE IMPLEMENTED ITEM EFFECTIVENESS & DAMAGE TYPE
	#else :
		#damage = (attacker.unit.magic + item.damage) - target.unit.magic_defense
	#if (damage > 0):
		#target.unit.hp -= damage
		#DamageNumbers.display_number(damage, (32* target.map_position + Vector2i(16,16)), false)
		#update_combatants.emit(combatants)
		#update_information.emit("[color=yellow]{0}[/color] did [color=gray]{1} damage[/color] to [color=red]{2}[/color]\n".format([
		#attacker.unit.unit_name,
		#damage,
		#target.unit.unit_name
		#]))
		#target.map_display.set_values()
	#if target.unit.hp <= 0:
		#combatant_die(target)

func use_audio_player(sound:AudioStream):
	if  audio_player_busy:
		await play_audio_finished
		emit_signal("play_audio", sound)
		audio_player_busy = true
	else : 
		emit_signal("play_audio", sound)
		audio_player_busy = true


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
