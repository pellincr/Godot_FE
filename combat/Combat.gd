extends Node
class_name Combat

const CombatUnitDisplay = preload("res://ui/combat_unit_display.tscn")

##Signals
signal register_combat(combat_node: Node)
signal turn_advanced(combatant: CombatUnit)
signal combatant_added(combatant: CombatUnit)
signal combatant_died(combatant: CombatUnit)
signal update_turn_queue(combatants: Array, turn_queue: Array)
signal update_information(text: String)
signal update_combatants(combatants: Array)
signal target_selected(combat_exchange_info: CombatUnit)
signal combat_finished()

enum Group
{
	PLAYERS,
	ENEMIES,
	FRIENDLY,
	NOMAD
}
enum VICTORY_CONDITION
{
	DEFEAT_ALL,
	DEFEAT_BOSS,
	CAPTURE_TILE,
	DEFEND_TILE,
	SURVIVE_TURNS
}
	
var combatants = []
var groups = [
	[], #players
	[], #enemies
	[], #FRIENDLY
	[]  #NOMAD
]
var turn_state = Constants.TURN_PHASE.BEGINNING_PHASE
var current_combatant = 0
var turn = 0
var turn_queue = []
var victory_condition = VICTORY_CONDITION.DEFEAT_ALL
var combatExchange: CombatExchange

@export var game_ui : Control
@export var controller : CController

var combatant_options = [
	["attack"],
	["staff"],
	["skill"],
	["Inventory"],
	["trade"],
	["wait"]
]
var skills_lists = [
	["attack_melee"], #Melee
	["attack_melee", "attack_ranged"], #Ranged
	["attack_melee", "basic_magic"] #Magic
]

func _ready():
	emit_signal("register_combat", self)
	combatExchange = CombatExchange.new()
	randomize()
	#ADD ITEMS
	#ADD PLAYERS
	var iventory_array :Array[ItemDefinition] = [ItemDatabase.items["iron_axe"], null, null, null]
	#add_combatant(create_combatant(CombatantDatabase.combatants["war_maiden"], Item.create(ItemDatabase.items["iron_sword"]), "Celeste"), 0, Vector2i(8,6))
	#add_combatant(create_combatant(UnitTypeDatabase.unit_types["mage"], Item.create(ItemDatabase.items["fire"]), "grizzwald"), 0, Vector2i(4,7))

	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["warrior"], iventory_array, "FriendlyGuy2", 20,16, true)), 0, Vector2i(8,7))
	#ADD ENEMIES
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["fighter"], iventory_array, "EnemyGuy", 3,0)), 1, Vector2i(16,6))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_bow"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["archer"], iventory_array, "FriendlyGuy", 20,0, false)), 0, Vector2i(8,6))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["archer"], iventory_array, "EnemyGuy", 3,0)), 1, Vector2i(10,7))
	#add_combatant(create_combatant(CombatantDatabase.combatants["fighter"], Item.create(ItemDatabase.items["iron_sword"]), "Undead Townie"), 1, Vector2i(16,6))
	#add_combatant(create_combatant(CombatantDatabase.combatants["archer"], Item.create(ItemDatabase.items["iron_bow"]), "Undead Townie2"), 1, Vector2i(10,7))
	#add_combatant(create_combatant(CombatantDatabase.combatants["archer"], Item.create(ItemDatabase.items["iron_bow"]), "Wild Grizzly"), 1, Vector2i(10,9))
	
	emit_signal("update_turn_queue", combatants, turn_queue)
	
	#controller.set_controlled_combatant(combatants[turn_queue[0]])
	#game_ui.set_skill_list(combatants[turn_queue[0]].skill_list)



func create_combatant_unit(unit:Unit, override_name = ""):
	var comb = CombatUnit.create(unit)
	return comb

func sort_turn_queue(a, b):
	if combatants[b].unit.initiative < combatants[a].unit.initiative:
		return true
	else:
		return false

func add_combatant(combat_unit: CombatUnit, allegience: int, position: Vector2i):
	combat_unit.map_position = position
	combat_unit.allegience = allegience
	combatants.append(combat_unit)
	groups[allegience].append(combatants.size() - 1)

	var new_combatant_sprite = CombatUnitDisplay.instantiate()
	new_combatant_sprite.set_reference_unit(combat_unit)
	##new_combatant_sprite.texture = combatant.unit.map_sprite
	$"../Terrain/TileMap".add_child(new_combatant_sprite)
	new_combatant_sprite.position = Vector2(position * 32.0) + Vector2(16, 16)
	new_combatant_sprite.z_index = 1
	if allegience == 0:
		pass
		##new_combatant_sprite.modulate = Color.SKY_BLUE
	else:
		##new_combatant_sprite.modulate = Color.INDIAN_RED
		combat_unit.unit.initiative -= 1
	new_combatant_sprite.set_outline_color()
	combat_unit.map_display = new_combatant_sprite
	##combat_unit = new_combatant_sprite
	
	turn_queue.append(combatants.size() - 1)
	turn_queue.sort_custom(sort_turn_queue)
	
	emit_signal("combatant_added", combat_unit)

func get_current_combatant():
	return combatants[current_combatant]

func set_current_combatant(cu:CombatUnit):
	current_combatant = combatants.find(cu)

func get_distance(attacker: CombatUnit, target: CombatUnit):
	var point1 = attacker.move_position
	var point2 = target.map_position
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)


#Called when the attacker can hit and begin combat sequence
func enact_combat_exchange(attacker: CombatUnit, defender:CombatUnit):
	#Compre attacks speeds to see if anyone is double attacking
	var distance = get_distance(attacker, defender)
	var attacker_as = attacker.unit.attack_speed
	var defender_as = defender.unit.attack_speed
	var double_attacker
	if(attacker_as - defender_as >= 4) :
		double_attacker = "attacker" 
	elif (attacker_as - defender_as <= - 4) :
		double_attacker = "defender"
	else :
		double_attacker = null
	var attacker_hit_chance = calc_hit(attacker, defender)
	var defender_can_attack = defender.unit.inventory.equipped.attack_range.has(distance)
	var defender_hit_chance = calc_hit(defender, attacker)
	#the aggressor attacks
	##var attack_hit = check_hit(attacker_hit_chance)
	print("<" + attacker.unit.unit_name +"> attacked with " + attacker.unit.inventory.equipped.name + " with [" + str(attacker_hit_chance) + "] hit!\n")
	#combat logic begins here
	if check_hit(attacker_hit_chance):
		do_damage(attacker, defender)
	else :
		update_information.emit(attacker.unit.unit_name +" missed!\n")
		DamageNumbers.display_number(-1, (32* defender.map_position + Vector2i(16,16)), true)
		print("<" + attacker.unit.unit_name +"> missed!\n")
	#the defender counters if able
	if (not defender.alive) :
		return
	if (defender_can_attack ): 
		update_information.emit(defender.unit.unit_name + " tries to counter!\n")
		print("<" + defender.unit.unit_name + "> tries to counter!\n")
		if check_hit(defender_hit_chance):
			do_damage(defender, attacker)
		else :
			update_information.emit(defender.unit.unit_name + " missed!\n")
			DamageNumbers.display_number(-1, (32* attacker.map_position + Vector2i(16,16)), true)
			print("<" + defender.unit.unit_name + "> missed!\n")
		#the defender attacks again if applicable
		if(double_attacker == "defender") :
			update_information.emit(defender.unit.unit_name + " follows up their strike with another!\n")
			print("<" + defender.unit.unit_name + "> follows up their strike with another!\n")
			if check_hit(defender_hit_chance):
				do_damage(defender, attacker)
			else :
				update_information.emit(defender.unit.unit_name + " missed!\n")
				DamageNumbers.display_number(-1, (32* attacker.map_position + Vector2i(16,16)), true)
				print("<" + defender.unit.unit_name +">" + " missed!\n")
		elif (double_attacker == "attacker") :
			update_information.emit(attacker.unit.unit_name + " responds with an attack!\n")
			print("<" + attacker.unit.unit_name + ">" + " responds with an attack!\n")
			if check_hit(attacker_hit_chance):
				do_damage(attacker, defender)
			else :
				update_information.emit(attacker.unit.unit_name + " missed!\n")
				DamageNumbers.display_number(-1, (32* defender.map_position + Vector2i(16,16)), true)
				print("<" + attacker.unit.unit_name + ">"+ " missed!\n")
	else :
		if(double_attacker == "attacker") :
			update_information.emit(attacker.unit.unit_name + " follows up their strike with another!\n")
			print("<" + attacker.unit.unit_name + "> follows up their strike with another!\n")
			if check_hit(attacker_hit_chance):
				do_damage(attacker, defender)
			else :
				update_information.emit(attacker.unit.unit_name + " missed!\n")
				DamageNumbers.display_number(-1, (32* defender.map_position + Vector2i(16,16)), true)
				print("<" + attacker.unit.unit_name +">" + " missed!\n")
			

#checks if the current RNG is successful
func check_hit(hitChance: int) -> bool:
		var random_number = randi() % 100
		var random_number2 = randi() % 100
		var trueHit = (random_number + random_number2)/2
		if trueHit < hitChance:
			return true
		else :
			return false

func get_itemDefinition(itemName: String) -> ItemDefinition:
	return ItemDatabase.items[itemName]
	
func attack(attacker: CombatUnit, target: CombatUnit):
	#check the distance between the target and attacker
	var distance = get_distance(attacker, target)
	#get the item info from the attacker
	var item = attacker.unit.inventory.equipped
	# check if that item can hit the target
	var valid = item.attack_range.has(distance)
	if valid:
		combatExchange.enact_combat_exchange(attacker, target, distance)
		if groups[Group.ENEMIES].size() < 1:
			combat_finish()
		advance_turn()
	else:
		update_information.emit("Target too far to attack.\n")
		#advance turn if its currently the enemy turn
		if attacker.allegience == 1:
			advance_turn()

func attack_action(attacker: CombatUnit):
	# show the user a list of attack options
	pass

func attack_melee(attacker: CombatUnit, target: CombatUnit):
	#show the inventory menu
	attack(attacker, target)

func set_next_combatant():
	turn += 1
	if turn >= turn_queue.size():
		for comb in combatants:
			comb.turn_taken = false
		turn = 0
	current_combatant = turn_queue[turn]

func advance_turn():
	combatants[current_combatant].turn_taken = true
	set_next_combatant()
	while !combatants[current_combatant].alive:
		set_next_combatant()
	var comb = combatants[current_combatant]
	emit_signal("turn_advanced", comb)
	emit_signal("update_combatants", combatants)
	if comb.allegience == 1:
		await get_tree().create_timer(0.6).timeout
		ai_process(comb)

func combat_finish():
	emit_signal("combat_finished")
	pass

func do_damage(attacker: CombatUnit, target: CombatUnit):
	var item = attacker.unit.inventory.equipped
	var damage
	if item.item_damage_type == 0 : ##Physical Dmg
		damage = (attacker.unit.strength + item.damage) - target.unit.defense ##TO BE IMPLEMENTED ITEM EFFECTIVENESS & DAMAGE TYPE
	else :
		damage = (attacker.unit.magic + item.damage) - target.unit.magic_defense
	##print("<" + attacker.name + "> HIT " + target.name + " for [" + str(damage) + "] damage! <" +target.name + "> has " + str(target.hp) + " HP")
	if (damage > 0):
		target.unit.hp -= damage
		DamageNumbers.display_number(damage, (32* target.map_position + Vector2i(16,16)), false)
		update_combatants.emit(combatants)
		update_information.emit("[color=yellow]{0}[/color] did [color=gray]{1} damage[/color] to [color=red]{2}[/color]\n".format([
		attacker.unit.unit_name,
		damage,
		target.unit.unit_name
		]))
		print("<" + attacker.unit.unit_name + "> HIT " + target.unit.unit_name + " for [" + str(damage) + "] damage! <" +target.unit.unit_name + "> has " + str(target.unit.hp) + " HP")
		target.map_display.update_values()
	if target.unit.hp <= 0:
		combatant_die(target)

func combatant_die(combatant: CombatUnit):
	print("Entered Combatant_die in combat.gd")
	var	comb_id = combatants.find(combatant)
	if comb_id != -1:
		combatant.alive = false
		groups[combatant.allegience].erase(comb_id)
		print("<" + combatant.unit.unit_name + "> died!")
		update_information.emit("[color=red]{0}[/color] died.\n".format([
			combatant.unit.unit_name
		]
	))
	##combatant.texture = combatant.death_texture
	combatant_died.emit(combatant)

func calc_skill_prob(skill: SkillDefinition, distance: int) -> int:
	var min_range = skill.min_range
	var max_range = skill.max_range
	if distance > max_range:
		return skill.max_prob
	if distance < min_range:
		return skill.min_prob
	if distance <= max_range and distance >= min_range:
		return 90 - 10 * (distance - 1)
	return 0
	
func calc_hit(attacker: CombatUnit, target: CombatUnit) -> int:
	return attacker.unit.hit - target.unit.avoid

func calc_crit(attacker: CombatUnit, target: CombatUnit) -> int:
	return attacker.unit.critical_hit - target.unit.critical_avoid
##AI

func sort_weight_array(a, b):
	if a[0] > b[0]:
		return true
	else:
		return false

func ai_process(comb : CombatUnit):
	var nearest_target: CombatUnit
	var l = INF
	for target_comb_index in groups[Group.PLAYERS]:
		var target = combatants[target_comb_index]
		var distance = get_distance(comb, target)
		if distance < l:
			l = distance
			nearest_target = target
			print(nearest_target.unit.unit_name)
	if get_distance(comb, nearest_target) == 1:
		attack(comb, nearest_target)
		return
	await controller.ai_process(nearest_target.map_position)
	attack(comb, nearest_target)
	

func ai_pick_target(weights):
	var rand_num = randf()
	var full_weight = 1.0
	for w in weights:
		var weight = w[0]
		full_weight -= weight
		if rand_num > full_weight - 0.001: #full_weight - 0.001 due to float inaccuracy
			return w[1]


func _on_combat_exchange_unit_defeated(unit: CombatUnit) -> void:
	print("entered combat.gd")
	combatant_die(unit)
