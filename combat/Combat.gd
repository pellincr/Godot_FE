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

func _ready():
	emit_signal("register_combat", self)
	combatExchange = $CombatExchange
	combatExchange.connect("combat_exchange_finished", major_action_complete)
	randomize()
	#Dummy Inventory for temp unit gen
	var iventory_array :Array[ItemDefinition] = [ItemDatabase.items["iron_axe"], ItemDatabase.items["steel_axe"], null, null]
	#ADD combatants
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["man_at_arms"], iventory_array, "FriendlyGuy2", 20,16, true), 0), Vector2i(8,7))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["fighter"], iventory_array, "EnemyGuy", 3,0), 1), Vector2i(16,6))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["warrior"], iventory_array, "FriendlyGuy2", 20,16, false), 1), Vector2i(11,6))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["man_at_arms"], iventory_array, "EnemyGuy3", 20,8, false), 1), Vector2i(10,6))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_bow"])
	iventory_array.insert(1, ItemDatabase.items["short_bow"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["archer"], iventory_array, "FriendlyGuy", 20,0, false),0), Vector2i(8,6))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["archer"], iventory_array, "FriendlyGuy", 20,0, false),0), Vector2i(8,5))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["archer"], iventory_array, "EnemyGuy", 3,0),1), Vector2i(10,7))
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
	#check the distance between the target and attacker
	var distance = get_distance(attacker, target)
	#get the item info from the attacker
	var item = attacker.unit.inventory.equipped
	# check if that item can hit the target
	var valid = item.attack_range.has(distance)
	if valid:
		await combatExchange.enact_combat_exchange(attacker, target, distance)
		if groups[Constants.FACTION.ENEMIES].size() < 1:
			major_action_complete()
		if attacker.allegience == Constants.FACTION.ENEMIES:
			complete_unit_turn()
	else:
		update_information.emit("Target too far to attack.\n")
		##UPDATE THIS TO RETURN UNIT TO TARGETTING?
		major_action_complete()
		complete_unit_turn()
		#advance turn if its currently the enemy turn
		if attacker.allegience == Constants.FACTION.ENEMIES:
			complete_unit_turn()

#Attack Action
func Attack(attacker: CombatUnit, target: CombatUnit):
	##make the combat_unit_inventory appear
	ai_calc_expected_damage(attacker, target)
	perform_attack(attacker, target)

#Wait Action
func Wait(unit: CombatUnit):
	major_action_complete()

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

func advance_turn():
	## Reset Players to active
	for entry in groups[Constants.FACTION.PLAYERS]:
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
	var nearest_target: CombatUnit
	var l = INF
	for target_comb_index in groups[Constants.FACTION.PLAYERS]:
		var target = combatants[target_comb_index]
		var distance = get_distance(comb, target)
		if distance < l:
			l = distance
			nearest_target = target
	if get_distance(comb, nearest_target) == 1:
		perform_attack(comb, nearest_target)
		return
	await controller.ai_process(nearest_target.map_position)
	perform_attack(comb, nearest_target)	

#AI logic to pick a target in range
func ai_pick_target(weights):
	var rand_num = randf()
	var full_weight = 1.0
	for w in weights:
		var weight = w[0]
		full_weight -= weight
		if rand_num > full_weight - 0.001: #full_weight - 0.001 due to float inaccuracy
			return w[1]


func ai_calc_expected_damage(attacker:CombatUnit, target:CombatUnit) -> Dictionary:
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
	for key in exchange_info:
		var value = exchange_info[key]
		print(str(key) + " : " + str(value))
	print("Expected Damage : " + str(expected_damage))
	print("max_damage : " + str(max_damage))
	
	var expected_combat_outcome = {
		"can_lethal"  = can_lethal,
		"expected_damage" = expected_damage
	}
	return expected_combat_outcome
