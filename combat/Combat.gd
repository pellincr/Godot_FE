extends Node
class_name Combat

#Imports
const CombatUnitDisplay = preload("res://ui/combat_unit_display.tscn")

##
#Combat Node
#This node controlls the combat actions on the map

##Signals
signal register_combat(combat_node: Node)
signal turn_advanced()
signal combatant_added(combatant: CombatUnit)
signal combatant_died(combatant: CombatUnit)
signal update_turn_queue(combatants: Array, turn_queue: Array)
signal update_information(text: String)
signal update_combatants(combatants: Array)
signal target_selected(combat_exchange_info: CombatUnit)
signal major_action_completed()
	
var combatants : Array[CombatUnit] = []
var units: Array[CombatUnit]
var groups = [
	[], #players
	[], #enemies
	[], #FRIENDLY
	[]  #NOMAD
]
var unit_groups = [
	[], #players
	[] #enemies
]
var current_combatant = 0
var victory_condition : Constants.VICTORY_CONDITION = Constants.VICTORY_CONDITION.DEFEAT_ALL ##overwrite on _ready

var combatExchange: CombatExchange

@export var game_ui : Control
@export var controller : CController
@export var combat_audio : AudioStreamPlayer

func _ready():
	emit_signal("register_combat", self)
	combatExchange = $CombatExchange
	combat_audio = $CombatAudio
	combatExchange.connect("combat_exchange_finished", major_action_complete)
	combatExchange.connect("play_audio", play_audio)
	combatExchange.connect("gain_experience", unit_gain_experience)
	randomize()
	#Dummy Inventory for temp unit gen
	var iventory_array :Array[ItemDefinition] 
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_lance"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["armor_lance"], iventory_array, "Bastard Jr.", 20,20),1), Vector2i(10,7))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["armor_lance"], iventory_array, "oswin Jr.", 20,20),0), Vector2i(9,6))
	iventory_array = [ItemDatabase.items["iron_axe"], ItemDatabase.items["hand_axe"], null, null]
	#ADD combatants
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["warrior"], iventory_array, "Harry Kane", 20,0, false), 1), Vector2i(30,6))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["warrior"], iventory_array, "POWERMAN", 20,20, false), 1), Vector2i(11,7))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_bow"])
	iventory_array.insert(1, ItemDatabase.items["short_bow"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["archer"], iventory_array, "Will Still", 5,35, false),0), Vector2i(8,6))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_sword"])
	iventory_array.insert(1, ItemDatabase.items["silver_sword"])
	iventory_array.insert(2, ItemDatabase.items["warhammer"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["man_at_arms"], iventory_array, "Gamer man", 1,45, false), 1), Vector2i(10,6))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["man_at_arms"], iventory_array, "Joe Gelhart", 1,45, true), 0), Vector2i(8,7))
	##emit_signal("update_turn_queue", combatants, turn_queue)


func create_combatant_unit(unit:Unit, team:int, override_name = ""):
	var comb = CombatUnit.create(unit, team)
	return comb

func sort_turn_queue(a, b):
	if combatants[b].unit.initiative < combatants[a].unit.initiative:
		return true
	else:
		return false

func add_combatant(combat_unit: CombatUnit, position: Vector2i):
	combat_unit.map_position = position
	combat_unit.map_terrain = controller.get_terrain_at_position(position)
	combatants.append(combat_unit)
	groups[combat_unit.allegience].append(combatants.size() - 1)

	var new_combatant_sprite = CombatUnitDisplay.instantiate()
	new_combatant_sprite.set_reference_unit(combat_unit)
	$"../Terrain/TileMap".add_child(new_combatant_sprite)
	new_combatant_sprite.position = Vector2(position * 32.0) + Vector2(16, 16)
	new_combatant_sprite.z_index = 1
	if combat_unit.allegience != 0:
		combat_unit.unit.initiative -= 1
	combat_unit.map_display = new_combatant_sprite
	emit_signal("combatant_added", combat_unit)

func get_current_combatant():
	return combatants[current_combatant]

func set_current_combatant(cu:CombatUnit):
	current_combatant = combatants.find(cu)

func get_distance(attacker: CombatUnit, target: CombatUnit):
	var point1 = attacker.map_position
	var point2 = target.map_position
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)

func perform_attack(attacker: CombatUnit, target: CombatUnit):
	print("Entered Perform_attack in combat.gd")
	#check the distance between the target and attacker
	var distance = get_distance(attacker, target)
	#get the item info from the attacker
	var item = attacker.unit.inventory.equipped
	# check if that item can hit the target
	var valid = (item and item.attack_range.has(distance))
	if valid:
		await combatExchange.enact_combat_exchange(attacker, target, distance)
		if attacker.allegience == Constants.FACTION.PLAYERS:	
			await game_ui.unit_experience_ended
		if groups[Constants.FACTION.ENEMIES].size() < 1:
			major_action_complete()
		if attacker.allegience == Constants.FACTION.ENEMIES:
			major_action_complete()
			complete_unit_turn()
	else:
		update_information.emit("Target too far to attack.\n")
		if attacker.allegience == Constants.FACTION.ENEMIES:
			complete_unit_turn()
			major_action_complete()

#Attack Action
func Attack(attacker: CombatUnit, target: CombatUnit):
	##make the combat_unit_inventory appear
	##ai_calc_expected_damage(attacker, target)
	await perform_attack(attacker, target)

#Wait Action
func Wait(unit: CombatUnit):
	major_action_complete()

func Inv(unit: CombatUnit):
	pass

#func set_next_combatant():
	#turn += 1
	#if turn >= turn_queue.size():
		#for comb in combatants:
			#comb.turn_taken = false
		#turn = 0
	#current_combatant = turn_queue[turn]

func complete_unit_turn():
	##units[current_unit].turn_taken = true
	pass

func advance_turn(faction: int):
	## Reset Players to active
	if faction < groups.size():
		for entry in groups[faction]:
			if combatants[entry]:
				combatants[entry].turn_taken = false
				combatants[entry].map_display.update_values()
	emit_signal("turn_advanced")
	#combatants[current_combatant].turn_taken = true
	#set_next_combatant()
	#while !combatants[current_combatant].alive:
		#set_next_combatant()
	#var comb = combatants[current_combatant]
	#emit_signal("turn_advanced", comb)
	#emit_signal("update_combatants", combatants)
	#if comb.allegience == 1:
		#await get_tree().create_timer(0.6).timeout
		#ai_process(comb)
		#

func major_action_complete():
	emit_signal("major_action_completed")

func combatant_die(combatant: CombatUnit):
	var	comb_id = combatants.find(combatant)
	if comb_id != -1:
		combatant.alive = false
		groups[combatant.allegience].erase(comb_id)
		update_information.emit("[color=red]{0}[/color] died.\n".format([
			combatant.unit.unit_name
		]
	))
	combatant_died.emit(combatant)

func sort_weight_array(a, b):
	if a[0] > b[0]:
		return true
	else:
		return false

##AI MEHTODS
#Process does the legwork for targetting for AI
func ai_process(comb : CombatUnit):
	print("In ai_process combat.gd")
	var comb_attack_range : Array[int]
	var nearest_target: CombatUnit
	var l = INF
	comb_attack_range = comb.unit.inventory.get_available_attack_ranges()
	for target_comb_index in groups[Constants.FACTION.PLAYERS]:
		var target = combatants[target_comb_index]
		var distance = get_distance(comb, target)
		if distance < l:
			l = distance
			nearest_target = target
	## can they reach?
	if comb_attack_range.has(get_distance(comb, nearest_target)):
		ai_equip_best_weapon(comb, nearest_target)
		await Attack(comb, nearest_target)
		return
	#
	controller.ai_process(comb, nearest_target.map_position)
	await controller.finished_move
	print("finished waiting for controller")
	if comb_attack_range.has(get_distance(comb, nearest_target)):
		ai_equip_best_weapon(comb, nearest_target)
		await Attack(comb, nearest_target)
		return
	if comb:
		if is_instance_valid(comb.map_display) :
			comb.map_display.update_values()
	return	 

func get_ai_units() -> Array[CombatUnit]:
	var enemy_unit_array : Array[CombatUnit]
	for enemy_unit in groups[Constants.FACTION.ENEMIES]:
		if combatants[enemy_unit]:
			enemy_unit_array.append(combatants[enemy_unit])
	return enemy_unit_array

#AI logic to pick a target in range
func ai_pick_target(weights):
	var rand_num = randf()
	var full_weight = 1.0
	for w in weights:
		var weight = w[0]
		full_weight -= weight
		if rand_num > full_weight - 0.001: #full_weight - 0.001 due to float inaccuracy
			return w[1]


func calc_expected_combat_exchange(attacker:CombatUnit, target:CombatUnit) -> Dictionary:
	#Get the values to run calcs on
	var max_damage : int = 0 # What is our max potential damage?
	var can_lethal : bool = false
	var attack_mult :int = 1
	var expected_damage : float = 0
	var exchange_info = combatExchange.calc_combat_exchange_preview(attacker, target, attacker.unit.inventory.get_available_attack_ranges().front())
 
	if exchange_info.double_attacker == 1:
		attack_mult = 2
	if exchange_info.attacker_hit_chance > 0:
		if exchange_info.attacker_critical_chance > 0:
			max_damage = attack_mult * exchange_info.attacker_damage * 3
			expected_damage = attack_mult * ((exchange_info.attacker_damage * float(exchange_info.attacker_hit_chance /float(100))) 
			+ (2 * (exchange_info.attacker_damage * float(exchange_info.attacker_hit_chance /float(100))) * float(exchange_info.attacker_critical_chance) /float(100)))
		else : 
			max_damage = attack_mult * exchange_info.attacker_damage
			expected_damage = attack_mult * (exchange_info.attacker_damage * exchange_info.attacker_hit_chance /float(100))
	# is it lethal?
	if (max_damage > target.unit.hp ):
		can_lethal = true
	# analyze damage and compare to other options
	#for key in exchange_info:
		#var value = exchange_info[key]
		#print(str(key) + " : " + str(value))
	#print("Expected Damage : " + str(expected_damage))
	#print("max_damage : " + str(max_damage))
	
	var expected_combat_outcome = {
		"can_lethal"  = can_lethal,
		"expected_damage" = expected_damage
	}
	return expected_combat_outcome

func ai_equip_best_weapon(comb: CombatUnit, target:CombatUnit):
	## get weapon options
	var usable_weapons : Array[WeaponDefinition] =  comb.unit.get_usable_weapons_at_range(get_distance(comb, target))
	if not usable_weapons.is_empty():
		var expected_damage : Array[Vector2]
		for i in range(usable_weapons.size()):
			comb.unit.set_equipped(usable_weapons[i])
			expected_damage.append(Vector2(i, calc_expected_combat_exchange(comb, target).expected_damage))
		expected_damage.sort_custom(sort_by_y_value)
		print("@ EXPECTED DAMAGE CALC : " + str(expected_damage))
		comb.unit.set_equipped(usable_weapons[expected_damage.front().x])

func sort_by_y_value(a: Vector2, b : Vector2):
	return a.y > b.y

func unit_gain_experience(u: Unit, value: int):
	game_ui.display_unit_experience_bar(u)
	game_ui.unit_experience_bar_gain(value)
	await game_ui.unit_experience_ended
	combatExchange.unit_gain_experience_complete()

func play_audio(sound : AudioStream):
	combat_audio.stream = sound
	combat_audio.play()
	await combat_audio.finished
	combatExchange.audio_player_ready()
