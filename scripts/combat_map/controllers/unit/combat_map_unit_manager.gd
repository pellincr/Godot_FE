extends Node
class_name CombatMapUnitManager
##
# This works with the CController to perform combat actions
# It stores unit data and information
##
#Imports
const COMBAT_UNIT_DISPLAY = preload("res://ui/combat/combat_unit_display/combat_unit_display.tscn")

##Signals
signal register_combat(combat_node: Node)
signal turn_advanced()

signal combat_unit_added(combatUnit: CombatUnit)
signal combatant_died(combatant: CombatUnit)
signal update_information(text: String)
signal update_combatants(combatants: Array)
signal target_selected(combat_exchange_info: CombatUnit)
signal perform_shove(unit: CombatUnit, push_vector : Vector2i)
signal major_action_completed()
signal minor_action_completed()
signal trading_completed()
signal shove_completed()

#map entity data
#@export var ai_combat_map_unit_data
#@export var player_combat_unit_data
@export var combat_map_unit_reinforcement_data : MapReinforcementData

@export var combat_map_unit_item_manager : CombatMapUnitItemManager

#unit variables
var groups = [ ##THIS IS OUTDATED AND SHOULD BE REPLACED WITH DICTIONARY
	[], #players
	[], #enemies
	[], #FRIENDLY
	[], #NOMAD
	[] #Terrain
]

# unit_groups<FACTION, Array[combat_units_index]>
var unit_groups = [
	[], #players
	[] #enemies
]
var dead_combat_units : Array[CombatUnit] = []
var combat_units : Array[CombatUnit] = []

#Index of in the combat_unit array of the current selected combat Unit
var current_combat_unit_index = 0

var combatExchange: CombatExchange

var _player_unit_alive : bool = true

@export var game_ui : Control
@export var controller : CController
@export var combat_audio : AudioStreamPlayer
@export var grid : CombatMapGrid
#@export var unit_experience_manager : UnitExperienceManager 

func _ready():
	emit_signal("register_combat", self)
	combatExchange = $CombatExchange
	combat_audio = $CombatAudio
	#unit_experience_manager = $UnitExperienceManager
	combatExchange.connect("combat_exchange_finished", combatExchangeComplete)
	combatExchange.connect("play_audio", play_audio)
	combatExchange.connect("gain_experience", unit_gain_experience)
	combatExchange.connect("unit_defeated",combatant_die)
	randomize() ##TO BE REMOVED WHEN RANDOMIZER GETS ADDED TO CONTROLLER

#creates unit groups based on factions present in combat map
func populate_unit_group(factions : Array[CombatMapConstants.FACTION]):
	#
	pass

func load_combat_units():
	#Read player units
	#update the unit array & the faction map
	#Read other units
	#update the unit array & the faction map
	pass

func spawn_combat_unit_reinforcements(turn_number : int, turn_phase, turn_owner):
	if combat_map_unit_reinforcement_data:
		for group in combat_map_unit_reinforcement_data.reinforcements: 
			if(turn_number in group.turn):
				for unit in group.units:
					var reinforcement_unit = create_combat_unit(Unit.create_generic(unit.unitDefinition, unit.inventory, unit.name, unit.level, unit.level_bonus, unit.hard_mode_leveling), 1, unit.ai_type)
					add_combat_unit(reinforcement_unit, unit.map_position)

func create_combat_unit(unit:Unit, team:int, ai_type: int = 0, has_droppable_item:bool = false, is_boss: bool = false):
	var comb = CombatUnit.create(unit, team, ai_type,is_boss)
	return comb

func add_combat_unit(combat_unit: CombatUnit, position: Vector2i):
	combat_unit.map_position = position
	combat_units.append(combat_unit)
	groups[combat_unit.allegience].append(combat_units.size() - 1)
	var new_combatant_sprite = COMBAT_UNIT_DISPLAY.instantiate()
	new_combatant_sprite.set_reference_unit(combat_unit)
	$"../Terrain/TileMap".add_child(new_combatant_sprite)
	new_combatant_sprite.position = Vector2(position * 32.0) + Vector2(16, 16)
	new_combatant_sprite.z_index = 1
	if combat_unit.allegience != 0:
		combat_unit.unit.initiative -= 1
	combat_unit.map_display = new_combatant_sprite
	emit_signal("combatant_added", combat_unit)
	

func get_current_combatant() -> CombatUnit:
	return combat_units[current_combat_unit_index]

func set_current_combatant(cu:CombatUnit): ##set_current_combat_unit_index
	current_combat_unit_index = combat_units.find(cu)

func get_distance(attacker: CombatUnit, target: CombatUnit):
	var point1 = attacker.map_position
	var point2 = target.map_position
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)

func perform_attack(attacker: CombatUnit, target: CombatUnit):
	print("Entered Perform_attack in combat.gd")
	_player_unit_alive = true
	#check the distance between the target and attacker
	var distance = get_distance(attacker, target)
	# check if that item can hit the target
	var valid = combatExchange.check_can_attack(attacker, target, distance)
	if valid:
		await combatExchange.enact_combat_exchange(attacker, target, distance)
		if attacker.allegience == Constants.FACTION.PLAYERS:
			major_action_complete()
		if attacker.allegience == Constants.FACTION.ENEMIES:
			major_action_complete()
			complete_unit_turn()
	else:
		update_information.emit("Target too far to attack.\n")
		if attacker.allegience == Constants.FACTION.ENEMIES:
			complete_unit_turn()
			major_action_complete()

func perform_staff(user: CombatUnit, target: CombatUnit):
	print("Entered Perform_attack in combat.gd")
	_player_unit_alive = true
	#check the distance between the target and attacker
	var distance = get_distance(user, target)
	#get the item info from the attacker
	var item = user.unit.inventory.equipped
	# check if that item can hit the target
	var valid = (item and item.attack_range.has(distance))
	if valid:
		await combatExchange.enact_staff_exchange(user, target, distance)
		if user.allegience == Constants.FACTION.PLAYERS:
			major_action_complete()
		if user.allegience == Constants.FACTION.ENEMIES:
			major_action_complete()
			complete_unit_turn()
	else:
		update_information.emit("Target too far to attack.\n")
		if user.allegience == Constants.FACTION.ENEMIES:
			complete_unit_turn()
			major_action_complete()

##ACTIONS
#Attack Action
func Attack(attacker: CombatUnit, target: CombatUnit):
	print("Entered Attack in Combat.gd")
	await perform_attack(attacker, target)

func Trade(unit: CombatUnit, target: CombatUnit):
	print("Entered Trade in Combat.gd")
	combat_unit_item_manager.trade(unit, target)
	await trading_completed
	combat_unit_item_manager.free_current_node()
	minor_action_complete(unit)
	print("Exited Trade in Combat.gd")

func Chest(unit: CombatUnit, key: ItemDefinition, chest:CombatMapChestEntity):
	print("Entered Chest in Combat.gd")
	key.use()
	for item in chest.contents:
		await combat_unit_item_manager.give_combat_unit_item(unit, item)
	entity_disable(chest)
	major_action_complete()
	
func Door(unit: CombatUnit, key: ItemDefinition, door:CombatMapDoorEntity):
	print("Entered Door in Combat.gd")
	key.use()
	for posn in door.entity_position_group:
		entity_disable(controller.get_entity_at_position(posn))
	controller.update_points_weight()
	major_action_complete()

#Staff Action
func Support(user: CombatUnit, target: CombatUnit):
	print("Entered Staff in Combat.gd")
	await perform_staff(user, target)
	major_action_complete()

#Wait Action
func Wait(unit: CombatUnit):
	major_action_complete()

#inventory
func Items(unit: CombatUnit): ##should never be called
	pass

#Use item
func Use(unit: CombatUnit, item: ConsumableItemDefinition):
	get_current_combatant().unit.use_consumable_item(item)
	get_current_combatant().map_display.update_values() ##display for healing
	await get_current_combatant().map_display.update_complete
	complete_unit_turn()
	major_action_complete()

#Shove
func Shove(unit:CombatUnit, target:CombatUnit):
	#check if action is available
	if get_distance(unit, target) == 1:
		var push_vector : Vector2i = target.map_position - unit.map_position
		perform_shove.emit(target, push_vector)
		await shove_completed
		set_current_combatant(unit)
	else : 
		print("Invalid Shove Target")
	complete_unit_turn()
	major_action_complete()

func complete_unit_turn():
	get_current_combatant().turn_taken = true

func advance_turn(faction: int):
	## Reset Players to active
	if faction < groups.size():
		for entry in groups[faction]:
			if combat_units[entry]:
				combat_units[entry].refresh_unit()
				combat_units[entry].map_display.update_values()

func major_action_complete():
	emit_signal("major_action_completed")

func combatExchangeComplete(friendly_unit_alive:bool):
	_player_unit_alive = friendly_unit_alive
	major_action_complete()

func combatant_die(cu: CombatUnit):
	var	comb_id = combat_units.find(cu)
	if comb_id != -1:
		cu.alive = false
		groups[cu.allegience].erase(comb_id)
		dead_combat_units.append(cu)
		update_information.emit("[color=red]{0}[/color] died.\n".format([
			cu.unit.unit_name
		]
	))
	combatant_died.emit(cu)

##AI MEHTODS
#Process does the legwork for targetting for AI
func ai_process(comb : CombatUnit):
	print("In ai_process combat.gd")
	var comb_attack_range : Array[int]
	var nearest_target: CombatUnit
	var l = INF
	comb_attack_range = comb.unit.inventory.get_available_attack_ranges()
	for target_comb_index in groups[Constants.FACTION.PLAYERS]:
		var target = combat_units[target_comb_index] #DO A CHECK TO MAKE SURE THERE ARE AVAILABLE TARGETS
		var distance = get_distance(comb, target)
		if distance < l:
			l = distance
			nearest_target = target
	## can they reach?
	if nearest_target:
		if comb_attack_range.has(get_distance(comb, nearest_target)):
			ai_equip_best_weapon(comb, nearest_target)
			await Attack(comb, nearest_target)
			return
	#if the current unit AI types lets them move on map
	if(comb.ai_type != Constants.UNIT_AI_TYPE.DEFEND_POINT):
		await controller.ai_process(comb, nearest_target.map_position)
		#await controller.finished_move
		print("finished waiting for controller")
		if comb_attack_range.has(get_distance(comb, nearest_target)):
			ai_equip_best_weapon(comb, nearest_target)
			await Attack(comb, nearest_target)
			return
	if comb:
		if is_instance_valid(comb.map_display) :
			comb.map_display.update_values()
	return	 
	
	#Process does the legwork for targetting for AI

func ai_process_new(comb : CombatUnit):
	print("In ai_process_new combat.gd")
	var action : aiAction = await controller.ai_process_new(comb)
	print("finished waiting for controller")
	if action != null:
		if action.action_type == "ATTACK":
			print("@ EQUIPPING BEST WEAPON")
			comb.unit.set_equipped(comb.unit.get_equippable_weapons()[action.item_index])
			print("@ CALLED ATTACK")
			await Attack(comb, action.target)
			print("@ FINISHED WAITING FOR ATTACK")
	if comb:
		if is_instance_valid(comb.map_display) :
			comb.map_display.update_values()
	return	 

#Returns list of combatUnits available for ai faction
func get_ai_units() -> Array[CombatUnit]:
	var enemy_unit_array : Array[CombatUnit]
	for enemy_unit in groups[Constants.FACTION.ENEMIES]:
		if combat_units[enemy_unit]:
			enemy_unit_array.append(combat_units[enemy_unit])
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

func calc_expected_combat_exchange(attacker:CombatUnit, target:CombatUnit, distance:int = -1) -> Dictionary:
	#Get the values to run calcs on
	var max_damage : int = 0 # What is our max potential damage?
	var can_lethal : bool = false
	var attack_mult :int = 1
	var expected_damage : float = 0
	var exchange_info
	if distance == -1:
		exchange_info = combatExchange.calc_combat_exchange_preview(attacker, target, attacker.unit.inventory.get_available_attack_ranges().front())
	else :
		exchange_info = combatExchange.calc_combat_exchange_preview(attacker, target, distance)
 
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
	var expected_combat_outcome = {
		"can_lethal"  = can_lethal,
		"expected_damage" = expected_damage,
		"attacker_hit_chance" = exchange_info.attacker_hit_chance
	}
	return expected_combat_outcome

func ai_get_best_attack_action(ai_unit: CombatUnit, distance: int, target:CombatUnit, terrain: Terrain) -> aiAction:
	var best_action : aiAction = aiAction.new()
	var usable_weapons : Array[WeaponDefinition] =  ai_unit.unit.get_usable_weapons_at_range(distance)
	if not usable_weapons.is_empty():
		var expected_damage : Array[Vector2]
		for i in range(usable_weapons.size()):
			ai_unit.unit.set_equipped(usable_weapons[i])
			var action: aiAction = aiAction.new()
			var expected_combat_return_outcome = calc_expected_combat_exchange(ai_unit, target, distance)
			action.generate_attack_action_rating(terrain.avoid/100,expected_combat_return_outcome.attacker_hit_chance, expected_combat_return_outcome.expected_damage, target.unit.max_hp, expected_combat_return_outcome.can_lethal)
			action.item_index = i
			action.target = target
			action.action_type = "ATTACK"
			if best_action == null or action.rating > best_action.rating: 
				best_action = action
		print("@ BEST ATTACK RATING CALC : " + str(best_action.rating))
	return best_action

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

func complete_trade():
	trading_completed.emit()

func complete_shove():
	shove_completed.emit()
	
func minor_action_complete(unit: CombatUnit):
	unit.minor_action_taken = true
	set_current_combatant(unit)
	emit_signal("minor_action_completed")

func unit_gain_experience(u: Unit, value: int):
	await unit_experience_manager.process_experience_gain(u, value)
	combatExchange.unit_gain_experience_complete()

func play_audio(sound : AudioStream):
	combat_audio.stream = sound
	combat_audio.play()
	await combat_audio.finished
	combatExchange.audio_player_ready()
