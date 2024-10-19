extends Node
class_name Combat

##Signals
signal register_combat(combat_node: Node)
signal turn_advanced(combatant: Dictionary)
signal combatant_added(combatant: Dictionary)
signal combatant_died(combatant: Dictionary)
signal update_turn_queue(combatants: Array, turn_queue: Array)
signal update_information(text: String)
signal update_combatants(combatants: Array)
signal target_selected(combat_exchange_info: Dictionary)
signal combat_finished()

#Constants 
enum Turn_Phase
{
	BEGINNING,
	MAIN,
	COMBAT,
	ENDING
}
enum Player_State
{
	IDLE,
	SELECTION,
	MOVEMENT,
	TARGETING,
	COMBAT,
	PAUSE,
}
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
var turn_state = Turn_Phase.BEGINNING
var current_combatant = 0
var turn = 0
var turn_queue = []
var victory_condition = VICTORY_CONDITION.DEFEAT_ALL
@export var game_ui : Control
@export var controller : CController

var combatant_options = [
	["attack"],
	["staff"],
	["skill"],
	["Inventory"],
	["trade"],
	["end"]
]
var skills_lists = [
	["attack_melee"], #Melee
	["attack_melee", "attack_ranged"], #Ranged
	["attack_melee", "basic_magic"] #Magic
]

func _ready():
	emit_signal("register_combat", self)
	randomize()
	#ADD ITEMS

	#ADD PLAYERS
	add_combatant(create_combatant(CombatantDatabase.combatants["war_maiden"], Item.create(ItemDatabase.items["iron_sword"]), "Celeste"), 0, Vector2i(8,6))
	add_combatant(create_combatant(CombatantDatabase.combatants["mage"], Item.create(ItemDatabase.items["fire"]), "grizzwald"), 0, Vector2i(4,7))
	#ADD ENEMIES
	add_combatant(create_combatant(CombatantDatabase.combatants["fighter"], Item.create(ItemDatabase.items["iron_sword"]), "Undead Townie"), 1, Vector2i(16,6))
	add_combatant(create_combatant(CombatantDatabase.combatants["archer"], Item.create(ItemDatabase.items["iron_bow"]), "Undead Townie2"), 1, Vector2i(10,7))
	add_combatant(create_combatant(CombatantDatabase.combatants["archer"], Item.create(ItemDatabase.items["iron_bow"]), "Wild Grizzly"), 1, Vector2i(10,9))
	
	emit_signal("update_turn_queue", combatants, turn_queue)
	
	controller.set_controlled_combatant(combatants[turn_queue[0]])
	game_ui.set_skill_list(combatants[turn_queue[0]].skill_list)


func create_combatant(definition: CombatantDefinition, item:Item, override_name = "", ):
	var comb = {
		"name" = definition.unit_type_name,
		"max_hp" = definition.hp,
		"hp" = definition.hp,
		"strength" = definition.strength,
		"magic" = definition.magic,
		"skill" = definition.skill,
		"speed" = definition.speed,
		"luck" = definition.luck,
		"defense" = definition.defense,
		"magic_defense" = definition.magic_defense,
		"class" = definition.class_t,
		"alive" = true,
		"movement_class" = definition.movement_class,
		"skill_list" = skills_lists[definition.class_t].duplicate(),
		"constitution" = definition.constitution,
		##"item_list" = item_lists[definition.class_t].duplicate(),
		"icon" = definition.icon,
		"map_sprite" = definition.map_sprite,
		"movement" = definition.movement,
		"initiative" = definition.initiative,
		"turn_taken" = false,
		"currently_equipped" = item
		}
	if override_name != "":
		comb.name = override_name
	if definition.skills.size() > 0:
		comb["skill_list"].append_array(definition.skills)
	return comb

func create_combatant_unit(unit:Unit, item:Item, override_name = "", ):
	var comb = {
		"unit" = unit,
		"alive" = true,
		"turn_taken" = false,
		"currently_equipped" = item,
		"skill_list" = skills_lists[unit.unit_type].duplicate()
		}
	if override_name != "":
		comb.unit.unit_name = override_name
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
	##new_combatant_sprite.set_reference_unit(unit)
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
	
#calculates key combat values to show the user potential combat outcomes
func calculate_combat_exchange(attacker: Dictionary, defender:Dictionary):
	var combat_exchange = {
		"attacker_name" = attacker.name,
		"attacker_hp" = attacker.hp,
		"attacker_damage" = (attacker.attack + attacker.currently_equipped.damage) - defender.defense,
		"attacker_hit_chance" = calc_hit(attacker, defender),
		"defender_hp" = defender.hp,
		"defender_damage" = (defender.attack + attacker.currently_equipped.damage) - attacker.defense,
		"defender_hit_chance" = calc_hit(defender, attacker)
	}
	emit_signal("target_selected", combat_exchange)

#Called when the attacker can hit and begin combat sequence
func enact_combat_exchange(attacker: Dictionary, defender:Dictionary):
	#Compre attacks speeds to see if anyone is double attacking
	var distance = get_distance(attacker, defender)
	var attacker_as = calc_attack_speed(attacker)
	var defender_as = calc_attack_speed(defender)
	var double_attacker
	if(attacker_as - defender_as >= 4) :
		double_attacker = "attacker" 
	elif (attacker_as - defender_as <= - 4) :
		double_attacker = "defender"
	else :
		double_attacker = null
	var attacker_hit_chance = calc_hit(attacker, defender)
	var defender_can_attack = defender.currently_equipped.attack_range.has(distance)
	var defender_hit_chance = calc_hit(defender, attacker)
	#the aggressor attacks
	##var attack_hit = check_hit(attacker_hit_chance)
	print("<" + attacker.name +"> attacked with " + attacker.currently_equipped.item_name + " with [" + str(attacker_hit_chance) + "] hit!\n")
	#combat logic begins here
	if check_hit(attacker_hit_chance):
		do_damage(attacker, defender)
	else :
		update_information.emit(attacker.name +" missed!\n")
		DamageNumbers.display_number(-1, (32* defender.position + Vector2i(16,16)), true)
		print("<" + attacker.name +"> missed!\n")
	#the defender counters if able
	if (defender_can_attack): 
		update_information.emit(defender.name + " tries to counter!\n")
		print("<" + defender.name + "> tries to counter!\n")
		if check_hit(defender_hit_chance):
			do_damage(defender, attacker)
		else :
			update_information.emit(defender.name + " missed!\n")
			DamageNumbers.display_number(-1, (32* attacker.position + Vector2i(16,16)), true)
			print("<" + defender.name + "> missed!\n")
		#the defender attacks again if applicable
		if(double_attacker == "defender") :
			update_information.emit(defender.name + " follows up their strike with another!\n")
			print("<" + defender.name + "> follows up their strike with another!\n")
			if check_hit(defender_hit_chance):
				do_damage(defender, attacker)
			else :
				update_information.emit(defender.name + " missed!\n")
				DamageNumbers.display_number(-1, (32* attacker.position + Vector2i(16,16)), true)
				print("<" + defender.name +">" + " missed!\n")
		elif (double_attacker == "attacker") :
			update_information.emit(attacker.name + " responds with an attack!\n")
			print("<" + attacker.name + ">" + " responds with an attack!\n")
			if check_hit(attacker_hit_chance):
				do_damage(attacker, defender)
			else :
				update_information.emit(attacker.name + " missed!\n")
				DamageNumbers.display_number(-1, (32* defender.position + Vector2i(16,16)), true)
				print("<" + attacker.name + ">"+ " missed!\n")
	else :
		if(double_attacker == "attacker") :
			update_information.emit(attacker.name + " follows up their strike with another!\n")
			print("<" + attacker.name + "> follows up their strike with another!\n")
			if check_hit(attacker_hit_chance):
				do_damage(attacker, defender)
			else :
				update_information.emit(attacker.name + " missed!\n")
				DamageNumbers.display_number(-1, (32* defender.position + Vector2i(16,16)), true)
				print("<" + attacker.name +">" + " missed!\n")
			

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
	
func attack(attacker: Dictionary, target: Dictionary):
	#check the distance between the target and attacker
	var distance = get_distance(attacker, target)
	#get the item info from the attacker
	var item = attacker.currently_equipped
	# check if that item can hit the target
	var valid = item.attack_range.has(distance)
	if valid:
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
	if comb.side == 1:
		await get_tree().create_timer(0.6).timeout
		ai_process(comb)

func combat_finish():
	emit_signal("combat_finished")
	pass

func do_damage(attacker: Dictionary, target: Dictionary):
	var item = attacker.currently_equipped
	var damage
	if item.item_damage_type == 0 : ##Physical Dmg
		damage = (attacker.strength + item.damage) - target.defense ##TO BE IMPLEMENTED ITEM EFFECTIVENESS & DAMAGE TYPE
	else :
		damage = (attacker.magic + item.damage) - target.magic_defense
	##print("<" + attacker.name + "> HIT " + target.name + " for [" + str(damage) + "] damage! <" +target.name + "> has " + str(target.hp) + " HP")
	if (damage > 0):
		target.hp -= damage
		DamageNumbers.display_number(damage, (32* target.position + Vector2i(16,16)), false)
		update_combatants.emit(combatants)
		update_information.emit("[color=yellow]{0}[/color] did [color=gray]{1} damage[/color] to [color=red]{2}[/color]\n".format([
		attacker.name,
		damage,
		target.name
		]))
		print("<" + attacker.name + "> HIT " + target.name + " for [" + str(damage) + "] damage! <" +target.name + "> has " + str(target.hp) + " HP")
	if target.hp <= 0:
		combatant_die(target)

func combatant_die(combatant: Dictionary):
	var	comb_id = combatants.find(combatant)
	if comb_id != -1:
		combatant.alive = false
		groups[combatant.side].erase(comb_id)
		print("<" + combatant.name + "> died!")
		update_information.emit("[color=red]{0}[/color] died.\n".format([
			combatant.name
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

func calc_hit(attacker: Dictionary, target: Dictionary) -> int:
	var item = attacker.currently_equipped
	var attacker_hit = item.hit + (2 * attacker.skill) + (attacker.luck/2)
	var target_avoid = 2 * calc_attack_speed(target) + target.luck
	var hit = attacker_hit - target_avoid
	##print(attacker.name + " hit calc with " + item.item_name + " is : " + str(hit))
	return hit

func calc_attack_speed(combatant: Dictionary) -> int:
	var item = combatant.currently_equipped
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
	var l = INF
	for target_comb_index in groups[Group.PLAYERS]:
		var target = combatants[target_comb_index]
		var distance = get_distance(comb, target)
		if distance < l:
			l = distance
			nearest_target = target
			print(nearest_target.name)
	if get_distance(comb, nearest_target) == 1:
		attack(comb, nearest_target)
		return
	await controller.ai_process(nearest_target.position)
	attack(comb, nearest_target)
	

func ai_pick_target(weights):
	var rand_num = randf()
	var full_weight = 1.0
	for w in weights:
		var weight = w[0]
		full_weight -= weight
		if rand_num > full_weight - 0.001: #full_weight - 0.001 due to float inaccuracy
			return w[1]
