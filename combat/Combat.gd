extends Node
class_name Combat

signal register_combat(combat_node: Node)
signal turn_advanced(combatant: Dictionary)
signal combatant_added(combatant: Dictionary)
signal combatant_died(combatant: Dictionary)
signal update_turn_queue(combatants: Array, turn_queue: Array)
signal update_information(text: String)
signal update_combatants(combatants: Array)
signal target_selected(combat_exchange_info: Dictionary)
signal combat_finished()

var combatants = []

enum Group
{
	PLAYERS,
	ENEMIES
}

enum UnitClass
{
	Melee,
	Ranged,
	Magic
}

var groups = [
	[], #players
	[]  #enemies
]

var current_combatant = 0
var turn = 0
var turn_queue = []

@export var game_ui : Control
@export var controller : CController

var skills_lists = [
	["attack_melee"], #Melee
	["attack_melee", "attack_ranged"], #Ranged
	["attack_melee", "basic_magic"] #Magic
]

func _ready():
	emit_signal("register_combat", self)
	randomize()

	#ADD PLAYERS
	add_combatant(create_combatant(CombatantDatabase.combatants["fighter"], "Dorcas"), 0, Vector2i(8,6))
	add_combatant(create_combatant(CombatantDatabase.combatants["mage"], "grizzwald"), 0, Vector2i(4,7))
	#ADD ENEMIES
	add_combatant(create_combatant(CombatantDatabase.combatants["zombie"], "Undead Townie"), 1, Vector2i(10,5))
	add_combatant(create_combatant(CombatantDatabase.combatants["zombie"], "Undead Townie2"), 1, Vector2i(10,7))
	add_combatant(create_combatant(CombatantDatabase.combatants["grizzly_bear"], "Wild Grizzly"), 1, Vector2i(10,9))
	
	emit_signal("update_turn_queue", combatants, turn_queue)
	
	controller.set_controlled_combatant(combatants[turn_queue[0]])
	game_ui.set_skill_list(combatants[turn_queue[0]].skill_list)


func create_combatant(definition: CombatantDefinition, override_name = ""):
	var comb = {
		"name" = definition.name,
		"max_hp" = definition.max_hp,
		"hp" = definition.max_hp,
		"attack" = definition.attack,
		"skill" = definition.skill,
		"speed" = definition.speed,
		"luck" = definition.luck,
		"defense" = definition.defense,
		"class" = definition.class_t,
		"alive" = true,
		"movement_class" = definition.class_m,
		"skill_list" = skills_lists[definition.class_t].duplicate(),
		"currently_equipped" = definition.currently_equipped,
		"constitution" = definition.constitution,
		##"item_list" = item_lists[definition.class_t].duplicate(),
		"icon" = definition.icon,
		"map_sprite" = definition.map_sprite,
		"death_sprite" = definition.death_sprite,
		"movement" = definition.movement,
		"initiative" = definition.initiative,
		"turn_taken" = false
		}
	if override_name != "":
		comb.name = override_name
	if definition.skills.size() > 0:
		comb["skill_list"].append_array(definition.skills)
	return comb

func sort_turn_queue(a, b):
	if combatants[b].initiative < combatants[a].initiative:
		return true
	else:
		return false

func add_combatant(combatant: Dictionary, side: int, position: Vector2i):
	combatant["position"] = position
	combatant["side"] = side
	combatants.append(combatant)
	groups[side].append(combatants.size() - 1)

	var new_combatant_sprite = Sprite2D.new()
	new_combatant_sprite.texture = combatant.map_sprite
	$"../Terrain/TileMap".add_child(new_combatant_sprite)
	new_combatant_sprite.position = Vector2(position * 32.0) + Vector2(16, 16)
	new_combatant_sprite.z_index = 1
	new_combatant_sprite.hframes = 1
	if side == 0:
		new_combatant_sprite.flip_h = true
		new_combatant_sprite.modulate = Color.SKY_BLUE
	else:
		new_combatant_sprite.modulate = Color.INDIAN_RED
		combatant["initiative"] -= 1
	combatant["sprite"] = new_combatant_sprite
	
	turn_queue.append(combatants.size() - 1)
	turn_queue.sort_custom(sort_turn_queue)
	
	emit_signal("combatant_added", combatant)


func get_current_combatant():
	return combatants[current_combatant]

func get_distance(attacker: Dictionary, target: Dictionary):
	var point1 = attacker.position
	var point2 = target.position
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)


func attack(attacker: Dictionary, target: Dictionary, attack: String):
	var distance = get_distance(attacker, target)
	#check if attacker has melee or ranged weapon
	#i.e. check the class
	var skill = SkillDatabase.skills[attack]
	var valid = distance <= skill.max_range and distance >= skill.min_range
	if valid:
#		var prob = calc_prob(attacker.class, distance)
		var prob = calc_skill_prob(skill, distance)
		#continue if distance is correct
		#check if we hit
		var random_number = randi() % 100
		if random_number < prob:
			do_damage(attacker, target, skill)
		else:
			update_information.emit("{0} missed.\n".format([attacker.name]))
		if groups[Group.ENEMIES].size() < 1:
			combat_finish()
		advance_turn()
	else:
		update_information.emit("Target too far to attack.\n")
		#advance turn if its currently the enemy turn
		if attacker.side == 1:
			advance_turn()

#calculates key combat values to show the user potential combat outcomes
func calculate_combat_exchange(attacker: Dictionary, defender:Dictionary):
	var combat_exchange = {
		"attacker_name" = attacker.name,
		"attacker_hp" = attacker.hp,
		"attacker_damage" = (attacker.attack + get_itemDefinition(attacker.currently_equipped).damage) - defender.defense,
		"attacker_hit_chance" = calc_hit(attacker, defender),
		"defender_hp" = defender.hp,
		"defender_damage" = (defender.attack + get_itemDefinition(defender.currently_equipped).damage) - attacker.defense,
		"defender_hit_chance" = calc_hit(defender, attacker)
	}
	emit_signal("target_selected", combat_exchange)

#Called when the attacker can hit and begin combat sequence
func enact_combat_exchange(attacker: Dictionary, defender:Dictionary):
	#Compre attacks speeds to see if anyone is double attacking
	var distance = get_distance(attacker, defender)
	var attacker_as = calc_attack_speed(attacker)
	var defender_as = calc_attack_speed(defender)
	var double_attack
	if(attacker_as - defender_as >= 4) :
		double_attack = "attacker" 
	elif (attacker_as - defender_as <= - 4) :
		double_attack = "defender"
	else :
		double_attack = null
	var attacker_hit_chance = calc_hit(attacker, defender)
	var defender_can_attack = get_itemDefinition(defender.currently_equipped).hit_ranges.has(distance)
	var defender_hit_chance = calc_hit(defender, attacker)
	#the aggressor attacks
	var attack_hit = check_hit(attacker_hit_chance)
	if(attack_hit):
		do_damage_item(attacker, defender)
	else :
		update_information.emit(attacker.name +" missed!\n")
	#the defender counters if able
	if (defender_can_attack): 
		update_information.emit(defender.name + " tries to counter!\n")
		attack_hit = check_hit(defender_hit_chance)
		if(attack_hit):
			do_damage_item(defender, attacker)
		else :
			update_information.emit(defender.name + " missed!\n")
		#the double attacker attacks if applicable
		if(double_attack == "defender") :
			update_information.emit(defender.name + " follows up their strike with another!\n")
			attack_hit = check_hit(defender_hit_chance)
			if(attack_hit):
				do_damage_item(defender, attacker)
			else :
				update_information.emit(defender.name + " missed!\n")
		elif (double_attack == "attacker") :
			update_information.emit(attacker.name + " responds with an attack!\n")
			attack_hit = check_hit(attacker_hit_chance)
			if(attack_hit):
				do_damage_item(attacker, defender)
			else :
				update_information.emit(defender.name + " missed!\n")

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
	
func attack_item(attacker: Dictionary, target: Dictionary):
	var distance = get_distance(attacker, target)
	#check if attacker has melee or ranged weapon
	#i.e. check the class
	var item = get_itemDefinition(attacker.currently_equipped)
	var valid = item.hit_ranges.has(distance)
	if valid:
		var prob = calc_hit(attacker, target)
		#does the unit double?
		#can the enemy counter attack?
		enact_combat_exchange(attacker, target)
		if groups[Group.ENEMIES].size() < 1:
			combat_finish()
		advance_turn()
	else:
		update_information.emit("Target too far to attack.\n")
		#advance turn if its currently the enemy turn
		if attacker.side == 1:
			advance_turn()

func attack_melee(attacker: Dictionary, target: Dictionary):
	##attack(attacker, target, "attack_melee")
	calculate_combat_exchange(attacker, target)
	attack_item(attacker, target)

func attack_ranged(attacker: Dictionary, target: Dictionary):
	attack(attacker, target, "attack_ranged")

func basic_magic(attacker: Dictionary, target: Dictionary):
	var skill = SkillDatabase.skills["basic_magic"]
	do_damage(attacker, target, skill)
	advance_turn()

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
	if comb.side == 1:
		await get_tree().create_timer(0.6).timeout
		ai_process(comb)

func combat_finish():
	emit_signal("combat_finished")
	pass

func do_damage(attacker: Dictionary, target: Dictionary, skill: SkillDefinition):
	var damage = randi_range(skill.min_damage, skill.max_damage)
	target.hp -= damage
	update_combatants.emit(combatants)
	update_information.emit("[color=yellow]{0}[/color] did [color=gray]{1} damage[/color] to [color=red]{2}[/color]\n".format([
		attacker.name,
		damage,
		target.name
		]))
	if target.hp <= 0:
		combatant_die(target)

func do_damage_item(attacker: Dictionary, target: Dictionary):
	var item = ItemDatabase.items[attacker.currently_equipped]
	var damage = (attacker.attack + item.damage) - target.defense ##TO BE IMPLEMENTED ITEM EFFECTIVENESS & DAMAGE TYPE
	if (damage > 0):
		target.hp -= damage
	update_combatants.emit(combatants)
	update_information.emit("[color=yellow]{0}[/color] did [color=gray]{1} damage[/color] to [color=red]{2}[/color]\n".format([
		attacker.name,
		damage,
		target.name
		]))
	if target.hp <= 0:
		combatant_die(target)

func combatant_die(combatant: Dictionary):
	var	comb_id = combatants.find(combatant)
	if comb_id != -1:
		combatant.alive = false
		groups[combatant.side].erase(comb_id)
		update_information.emit("[color=red]{0}[/color] died.\n".format([
			combatant.name
		]
	))
	combatant.texture = combatant.death_sprite
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

func calc_hit(attacker: Dictionary, target: Dictionary) -> int:
	var item = get_itemDefinition(attacker.currently_equipped)
	var attacker_hit = item.hit + (2 * attacker.skill) + (attacker.luck/2)
	var target_avoid = 2 * calc_attack_speed(target) + target.luck
	var hit = attacker_hit - target_avoid
	print(attacker.name + " attacked with a " + item.name + " and hit chance of : " + str(hit) )
	return hit

func calc_attack_speed(combatant: Dictionary) -> int:
	var item = ItemDatabase.items[combatant.currently_equipped]
	return combatant.speed - (item.weight - combatant.constitution)

func calc_prob(attack: String, distance: int):
	if attack == "melee" or attack == "magic":
		return 90 - 10 * (distance - 1)
	if attack == "ranged":
		return 25 if distance == 1 or distance == 5 else 90

##AI

func sort_weight_array(a, b):
	if a[0] > b[0]:
		return true
	else:
		return false


func ai_process(comb : Dictionary):
	var nearest_target: Dictionary
	if comb.class == UnitClass.Melee:
		var l = INF
		for target_comb_index in groups[Group.PLAYERS]:
			var target = combatants[target_comb_index]
			var distance = get_distance(comb, target)
			if distance < l:
				l = distance
				nearest_target = target
				print(nearest_target.name)
		if get_distance(comb, nearest_target) == 1:
			attack_item(comb, nearest_target)
			return
	await controller.ai_process(nearest_target.position)
	attack_item(comb, nearest_target)


func ai_pick_target(weights):
	var rand_num = randf()
	var full_weight = 1.0
	for w in weights:
		var weight = w[0]
		full_weight -= weight
		if rand_num > full_weight - 0.001: #full_weight - 0.001 due to float inaccuracy
			return w[1]
