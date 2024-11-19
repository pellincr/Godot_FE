extends Node

class_name CombatExchange

signal unit_defeated(unit: CombatUnit)
signal combat_exchange_finished()
signal unit_hit_ui(hit_unit: Unit)
signal update_information(text: String)

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
var combat_exchange_display : UnitStatusCombatExchange



#calculates key combat values to show the user potential combat outcomes
#Called when the attacker can hit and begin combat sequence
func enact_combat_exchange(attacker: CombatUnit, defender:CombatUnit, distance:int):
	#Compre attacks speeds to see if anyone is double attacking
	var double_attacker = check_double(attacker.unit, defender.unit)
	var attacker_hit_chance = calc_hit(attacker.unit, defender.unit)
	var attacker_critical_chance = calc_crit(attacker.unit, defender.unit)
	var defender_can_attack = defender.unit.inventory.equipped.attack_range.has(distance)
	var defender_hit_chance = calc_hit(defender.unit, attacker.unit)
	var defender_critical_chance = calc_crit(defender.unit,attacker.unit)
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
					attacker.unit.experience += attacker.unit.calculate_experience_gain_kill(defender.unit)
					print("EXP FROM COMBAT : " + str(attacker.unit.experience))
					combat_exchange_finished.emit()
					attacker.turn_taken = true
					return
	else:
		unit_defeated.emit(defender)
		attacker.unit.experience += attacker.unit.calculate_experience_gain_kill(defender.unit)
		print("EXP FROM COMBAT : " + str(attacker.unit.experience))
	attacker.unit.experience += attacker.unit.calculate_experience_gain_hit(defender.unit)
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
		hit_missed(target)

func hit_missed(dodging_unt: CombatUnit):
	#play miss sound
	pass
	#display miss text
	#await for the text to end
	

func do_damage(target: CombatUnit, damage:int, is_critical: bool = false):
	#check and see if it actually does any damage
	#var outcome : int
	if(damage == 0):
		#outcome = DAMAGE_OUTCOME.NO_DAMAGE
		pass
		#play no damage noise
	if (damage > 0):
		target.unit.hp -= damage
		#outcome = DAMAGE_OUTCOME.DAMAGE_DEALT
		if is_critical:
			DamageNumbers.display_number(damage, (32* target.map_position + Vector2i(16,16)), false, true)
		else :
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
	return attacker.hit - target.avoid

func calc_crit(attacker: Unit, target: Unit) -> int:
	return attacker.critical_hit - target.critical_avoid

func calc_damage(attacker: Unit, target: Unit) -> int:
	var damage
	#is it a critical?
	var effective_damage_multiplier = 3
	var effective = false
	#is the weapon effective?
	if not attacker.inventory.equipped.weapon_effectiveness.is_empty() :
		if attacker.inventory.equipped.weapon_effectiveness == UnitTypeDatabase.unit_types.get(target.unit_class_key).class_type :
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
	return damage

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
	var combat_exchange_preview = {
		"double_attacker" = check_double(attacker.unit, defender.unit),
		"defender_can_attack" = defender.unit.inventory.equipped.attack_range.has(distance),
		"attacker_hit_chance" = calc_hit(attacker.unit, defender.unit),
		"attacker_damage" = calc_damage(attacker.unit, defender.unit),
		"attacker_critical_chance" = calc_crit(attacker.unit, defender.unit),
		"defender_hit_chance" = calc_hit(defender.unit, attacker.unit),
		"defender_damage" = calc_damage(defender.unit, attacker.unit),
		"defender_critical_chance" = calc_crit(defender.unit,attacker.unit),
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
