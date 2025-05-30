extends Node
class_name Combat
##
# Combate Node
# This works with the CController to perform combat actions
# It stores unit data and information
##
#Imports
const COMBAT_UNIT_DISPLAY = preload("res://ui/combat/combat_unit_display/combat_unit_display.tscn")
const COMBAT_MAP_ENTITY_DISPLAY = preload("res://ui/combat/combat_map_entity_display/combat_map_entity_display.tscn")

##Signals
signal register_combat(combat_node: Node)
signal turn_advanced()
signal combatant_added(combatant: CombatUnit)
signal entity_added(cme:CombatMapEntity)
signal combatant_died(combatant: CombatUnit)
signal update_information(text: String)
signal update_combatants(combatants: Array)
signal target_selected(combat_exchange_info: CombatUnit)
signal perform_shove(unit: CombatUnit, push_vector : Vector2i)
signal major_action_completed()
signal minor_action_completed()
signal trading_completed()
signal shove_completed()
	
var dead_units : Array[CombatUnit] = []
var combatants : Array[CombatUnit] = []
var units: Array[CombatUnit]
var entities: Array[CombatMapEntity]
var disabled_entities : Array[CombatMapEntity]
var groups = [
	[], #players
	[], #enemies
	[], #FRIENDLY
	[],  #NOMAD
	[] #Terrain
]
var unit_groups = [
	[], #players
	[] #enemies
]
var current_combatant = 0
var victory_condition : Constants.VICTORY_CONDITION = Constants.VICTORY_CONDITION.DEFEAT_ALL ##overwrite on _ready

var combatExchange: CombatExchange

var _player_unit_alive : bool = true
@export var game_ui : Control
@export var controller : CController
@export var combat_audio : AudioStreamPlayer
@export var unit_experience_manager : UnitExperienceManager 
@export var combat_unit_item_manager : CombatUnitItemManager
@export var mapReinforcementData : MapReinforcementData
@export var mapEntityData: MapEntityGroupData

func _ready():
	emit_signal("register_combat", self)
	combatExchange = $CombatExchange
	combat_audio = $CombatAudio
	unit_experience_manager = $UnitExperienceManager
	combatExchange.connect("combat_exchange_finished", combatExchangeComplete)
	combatExchange.connect("play_audio", play_audio)
	combatExchange.connect("gain_experience", unit_gain_experience)
	combatExchange.connect("unit_defeated",combatant_die)
	randomize()
	##Create units and dummy inventories
	#Dummy Inventory for temp unit gen
	var iventory_array :Array[ItemDefinition] 
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["heal_staff"])
	iventory_array.insert(1, ItemDatabase.items["iron_sword"])
	#iventory_array.insert(2, ItemDatabase.items["bolting"])
	iventory_array.insert(3, ItemDatabase.items["key"])
	#iventory_array.insert(0, ItemDatabase.items["harm"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["cleric"], iventory_array, "Flavius", 1,9),0), Vector2i(7,14))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["smite"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["monk"], iventory_array, "Jacob", 6,12),0), Vector2i(9,14))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_bow"])
	iventory_array.insert(1, ItemDatabase.items["enchanted_bow"])
	iventory_array.insert(2, ItemDatabase.items["potion"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["archer"], iventory_array, "Boko", 5,10, false),0), Vector2i(7,15))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_sword"])
	iventory_array.insert(1, ItemDatabase.items["sabre"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["fencer"], iventory_array, "Christian", 6,12, false), 0), Vector2i(7,16))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["enchanted_shotel"])
	iventory_array.insert(1, ItemDatabase.items["iron_dagger"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["thief"], iventory_array, "Craig", 3,9, false), 0), Vector2i(8,16))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_axe"])
	iventory_array.insert(1, ItemDatabase.items["silver_axe"])
	iventory_array.insert(1, ItemDatabase.items["hand_axe"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["cavalier_axe"], iventory_array, "Devin", 4,11, false), 0), Vector2i(8,14))
	iventory_array.clear()
	iventory_array.append(ItemDatabase.items["iron_lance"])
	iventory_array.append(ItemDatabase.items["javelin"])
	iventory_array.append(ItemDatabase.items["killer_lance"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["legionary_lance"], iventory_array, "Justin", 8,15),0), Vector2i(8,15))
	iventory_array.clear()
	iventory_array.append(ItemDatabase.items["wind_blade"])
	iventory_array.append(ItemDatabase.items["fire_spell"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["cavalier_magic"], iventory_array, "Lynn", 4,11),0), Vector2i(9,15))
	iventory_array.clear()
	iventory_array.append(ItemDatabase.items["brass_knuckles"])
	iventory_array.append(ItemDatabase.items["devil_knuckles"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["martial_artist"], iventory_array, "Avon", 4,11),0), Vector2i(9,16))
	var playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)
	add_combatant(create_combatant_unit(playerOverworldData.total_party[0],0),Vector2i(10,16))
	

	#ENEMY
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["javelin"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["gargoyle"], iventory_array, "Fiend", 6,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(9,2))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_lance"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["gargoyle"], iventory_array, "Fiend", 6,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(17,11))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_bow"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["bonewalker_archer"], iventory_array, "Fiend", 6,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(6,2))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["dark_pulse"])
	iventory_array.insert(0, ItemDatabase.items["sharp_claws"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["drake"], iventory_array, "Braumulus", 12,2, false), 1, Constants.UNIT_AI_TYPE.DEFEND_POINT, false, true), Vector2i(12,2))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["halberd"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["bonewalker_lance"], iventory_array, "Fiend", 6,12, false), 1, Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE), Vector2i(2,4))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["steel_lance"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["bonewalker_lance"], iventory_array, "Fiend", 6,8, false), 1, Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE), Vector2i(3,3))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["javelin"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["bonewalker_lance"], iventory_array, "Fiend", 6,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(15,8))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["fire_spell"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["imp"], iventory_array, "Fiend", 9,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(3,14))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["dark_pulse"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["imp"], iventory_array, "Fiend", 7,12, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(13,3))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["fiend_fire"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["imp"], iventory_array, "Fiend", 9,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(7,7))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["steel_sword"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["bonewalker_sword"], iventory_array, "Fiend", 6,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(14,8))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["silver_sword"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["bonewalker_sword"], iventory_array, "Fiend", 8,13, false), 1, Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE), Vector2i(6,9))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["dark_sword"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["bonewalker_sword"], iventory_array, "Fiend", 9,9, false), 1, Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE), Vector2i(7,9))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["steel_sword"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["bonewalker_sword"], iventory_array, "Fiend", 8,13, false), 1, Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE), Vector2i(15,3))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["killer_sword"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["bonewalker_sword"], iventory_array, "Fiend", 8,13, false), 1, Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE), Vector2i(16,4))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["steel_sword"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["mercenary"], iventory_array, "Gemni's Guard", 6,10, false), 1, Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE), Vector2i(10,23))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_axe"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["cavalier_axe"], iventory_array, "Bandit", 6,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(8,23))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_lance"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["cavalier_lance"], iventory_array, "Bandit", 6,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(15,21))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["steel_lance"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["cavalier_lance"], iventory_array, "Bandit", 6,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(0,20))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["fire_spell"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["cavalier_magic"], iventory_array, "Bandit", 6,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(14,21))
	iventory_array.clear()
	iventory_array.insert(2, ItemDatabase.items["bolting"])
	iventory_array.insert(0, ItemDatabase.items["fiend_fire"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["cavalier_magic"], iventory_array, "Gemni", 12,15, true), 1, Constants.UNIT_AI_TYPE.DEFEND_POINT, false, true), Vector2i(10,24))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["hand_axe"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["kobold_axe"], iventory_array, "Fiend", 5,11, true), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(16,7))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["iron_axe"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["kobold_axe"], iventory_array, "Fiend", 5,11, true), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(1,11))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["sharp_claws"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["zombie"], iventory_array, "Fiend", 8,13, false), 1, Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE), Vector2i(2,3))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["zombie"], iventory_array, "Fiend", 8,13, false), 1, Constants.UNIT_AI_TYPE.ATTACK_IN_RANGE), Vector2i(16,3))
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["zombie"], iventory_array, "Fiend", 8,13, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(15,11))
	iventory_array.clear()
	iventory_array.insert(0, ItemDatabase.items["hand_axe"])
	add_combatant(create_combatant_unit(Unit.create_generic(UnitTypeDatabase.unit_types["warrior"], iventory_array, "Gemni's Guard", 6,8, false), 1, Constants.UNIT_AI_TYPE.DEFAULT), Vector2i(10,26))
	load_entities()

func load_entities():
	if mapEntityData != null:
		for entity in mapEntityData.entities:
			add_entity(entity)
		

func spawn_reinforcements(turn_number : int):
	if mapReinforcementData:
		for group in mapReinforcementData.reinforcements: 
			if(turn_number in group.turn):
				for unit in group.units:
					var reinforcement_unit = create_combatant_unit(Unit.create_generic(unit.unitDefinition, unit.inventory, unit.name, unit.level, unit.level_bonus, unit.hard_mode_leveling), 1, unit.ai_type)
					add_combatant(reinforcement_unit, unit.map_position)

func create_combatant_unit(unit:Unit, team:int, ai_type: int = 0, has_droppable_item:bool = false, is_boss: bool = false):
	var comb = CombatUnit.create(unit, team, ai_type,is_boss)
	return comb

func sort_turn_queue(a, b):
	if combatants[b].unit.initiative < combatants[a].unit.initiative:
		return true
	else:
		return false

func add_combatant(combat_unit: CombatUnit, position: Vector2i):
	combat_unit.map_tile.position = position
	combat_unit.map_tile.terrain = controller.get_terrain_at_position(position)
	combatants.append(combat_unit)
	groups[combat_unit.allegience].append(combatants.size() - 1)

	var new_combatant_sprite = COMBAT_UNIT_DISPLAY.instantiate()
	new_combatant_sprite.set_reference_unit(combat_unit)
	$"../Terrain/TileMap".add_child(new_combatant_sprite)
	new_combatant_sprite.position = Vector2(position * 32.0) + Vector2(16, 16)
	new_combatant_sprite.z_index = 1
	if combat_unit.allegience != 0:
		combat_unit.unit.initiative -= 1
	combat_unit.map_display = new_combatant_sprite
	emit_signal("combatant_added", combat_unit)
	
func add_entity(cme:CombatMapEntity):
	entities.append(cme)
	var new_entity_sprite : CombatMapEntityDisplay = COMBAT_MAP_ENTITY_DISPLAY.instantiate()
	new_entity_sprite.set_reference_entity(cme)
	$"../Terrain/TileMap".add_child(new_entity_sprite)
	new_entity_sprite.position = Vector2((cme.position.x * 32.0) + 16,(cme.position.y * 32.0) + 16)
	new_entity_sprite.z_index = 0
	cme.display = new_entity_sprite
	emit_signal("entity_added", cme)

func get_current_combatant():
	return combatants[current_combatant]

func set_current_combatant(cu:CombatUnit):
	current_combatant = combatants.find(cu)

func get_distance(attacker: CombatUnit, target: CombatUnit):
	var point1 = attacker.map_tile.position
	var point2 = target.map_tile.position
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

#trade
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
		var push_vector : Vector2i = target.map_tile.position - unit.map_tile.position
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
			if combatants[entry]:
				combatants[entry].refresh_unit()
				combatants[entry].map_display.update_values()
func major_action_complete():
	
	emit_signal("major_action_completed")

func combatExchangeComplete(friendly_unit_alive:bool):
	_player_unit_alive = friendly_unit_alive
	major_action_complete()

func combatant_die(combatant: CombatUnit):
	var	comb_id = combatants.find(combatant)
	if comb_id != -1:
		combatant.alive = false
		groups[combatant.allegience].erase(comb_id)
		dead_units.append(combatant)
		update_information.emit("[color=red]{0}[/color] died.\n".format([
			combatant.unit.unit_name
		]
	))
	combatant_died.emit(combatant)

func entity_disable(e: CombatMapEntity):
	e.active = false
	disabled_entities.append(e)
	e.display.queue_free()

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
		var target = combatants[target_comb_index] #DO A CHECK TO MAKE SURE THERE ARE AVAILABLE TARGETS
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
		await controller.ai_process(comb, nearest_target.map_tile.position)
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
