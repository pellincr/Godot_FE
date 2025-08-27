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
#signal entity_added(cme:CombatEntity)
signal combatant_died(combatant: CombatUnit)
signal update_information(text: String)
signal update_combatants(combatants: Array) #THIS IS OLD?
signal target_selected(combat_exchange_info: CombatUnit)
signal perform_shove(unit: CombatUnit, push_vector : Vector2i)
signal major_action_completed()
signal minor_action_completed()
signal trading_completed()
signal shove_completed()
signal pause_fsm()
signal resume_fsm()
signal entity_interact_completed()
	
var dead_units : Array[CombatUnit] = []
var combatants : Array[CombatUnit] = []
var units: Array[CombatUnit]

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
@export var victory_condition : Constants.VICTORY_CONDITION = Constants.VICTORY_CONDITION.DEFEAT_ALL ##overwrite on _ready
@export var turns_to_survive:=0
var combatExchange: CombatExchange


var _player_unit_alive : bool = true

@export var game_ui : Control
@export var controller : CController
@export var combat_audio : AudioStreamPlayer
@export var unit_experience_manager : UnitExperienceManager 
@export var combat_unit_item_manager : CombatUnitItemManager
@export var mapReinforcementData : MapReinforcementData
@export var entity_manager : CombatMapEntityManager

@export var ally_spawn_top_left : Vector2
@export var ally_spawn_bottom_right: Vector2
@export var enemy_start_group : EnemyGroup
@export var max_allowed_ally_units : int
@export var base_win_gold_reward : int = 0
@export var turn_reward_modifier : int = 0
#@export var draft_amount_on_win : int
#@export var battle_prep_on_win : bool = true
@export var heal_on_win : bool = true

@onready var current_turn = 0

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)


func _ready():
	emit_signal("register_combat", self)
	combatExchange = $CombatExchange
	combat_audio = $CombatAudio
	unit_experience_manager = $UnitExperienceManager
	entity_manager = $CombatMapEntityManager
	combatExchange.connect("combat_exchange_finished", combatExchangeComplete)
	combatExchange.connect("play_audio", play_audio)
	combatExchange.connect("gain_experience", unit_gain_experience)
	combatExchange.connect("unit_defeated",combatant_die)
	combatExchange.connect("entity_destroyed",entity_destroyed_combat)
	combat_unit_item_manager.connect("heal_unit", heal_unit)
	combat_unit_item_manager.connect("create_discard_container", create_unit_item_discard_container)
	combat_unit_item_manager.connect("create_give_item_pop_up", create_item_obtained_pop_up)
	entity_manager.connect("entity_added", entity_added)
	entity_manager.connect("give_items", give_curent_unit_items)
	randomize()

func populate():
	var current_party_index = 0 
	for i in range(ally_spawn_top_left.x,ally_spawn_bottom_right.x):
		for j in range(ally_spawn_top_left.y,ally_spawn_bottom_right.y):
			if !(current_party_index >= playerOverworldData.selected_party.size()):
				add_combatant(create_combatant_unit(playerOverworldData.selected_party[current_party_index],0),Vector2i(i,j))
				current_party_index+= 1
	spawn_initial_units()
	entity_manager.load_entities()
		

func spawn_reinforcements(turn_number : int):
	if mapReinforcementData:
		for group in mapReinforcementData.reinforcements: 
			if(turn_number in group.turn):
				for unit in group.units:
					var reinforcement_unit = create_combatant_unit(Unit.create_generic_unit(unit.unit_type_key, unit.inventory, unit.name, unit.level, unit.level_bonus, unit.hard_mode_leveling), 1, unit.ai_type)
					add_combatant(reinforcement_unit, unit.map_position)

func spawn_initial_units():
	for unit in enemy_start_group.group:
		var reinforcement_unit = create_combatant_unit(Unit.create_generic_unit(unit.unit_type_key, unit.inventory, unit.name, unit.level, unit.level_bonus, unit.hard_mode_leveling), 1, unit.ai_type)
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
	combat_unit.map_position = position
	combat_unit.map_terrain = controller.grid.get_terrain(position)
	combatants.append(combat_unit)
	groups[combat_unit.allegience].append(combatants.size() - 1)

	var new_combatant_sprite = COMBAT_UNIT_DISPLAY.instantiate()
	combat_unit.stats.populate_unit_stats(combat_unit.unit)
	combat_unit.stats.populate_weapon_stats(combat_unit, combat_unit.get_equipped())
	new_combatant_sprite.set_reference_unit(combat_unit)
	$"../Terrain/UnitLayer".add_child(new_combatant_sprite)
	new_combatant_sprite.position = Vector2(position * 32.0) + Vector2(16, 16)
	new_combatant_sprite.z_index = 1
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

func perform_attack(attacker: CombatUnit, target: CombatUnit, data: UnitCombatExchangeData):
	print("Entered Perform_attack in combat.gd")
	_player_unit_alive = true
	await combatExchange.enact_combat_exchange_new(attacker, target, data)
	major_action_complete()
	if attacker.allegience == Constants.FACTION.ENEMIES:
		complete_unit_turn()

func perform_attack_entity(attacker: CombatUnit, target: CombatEntity, data: UnitCombatExchangeData):
	print("Entered Perform_attack in combat.gd")
	_player_unit_alive = true
	await combatExchange.enact_combat_exchange_entity(attacker, target, data)
	major_action_complete()
	if attacker.allegience == Constants.FACTION.ENEMIES:
		complete_unit_turn()

func perform_support(supporter: CombatUnit, target: CombatUnit, data: UnitSupportExchangeData):
	print("Entered Perform_attack in combat.gd")
	_player_unit_alive = true
	await combatExchange.enact_support_exchange(supporter, target, data)
	major_action_complete()
	if supporter.allegience == Constants.FACTION.ENEMIES:
		complete_unit_turn()


func perform_staff(user: CombatUnit, target: CombatUnit):
	print("Entered Perform_attack in combat.gd")
	_player_unit_alive = true
	#check the distance between the target and attacker
	var distance = get_distance(user, target)
	#get the item info from the attacker
	var item = user.unit.inventory.get_equipped_item()
	# check if that item can hit the target
	var valid = (item and item.attack_range.has(distance))
	if valid:
		await combatExchange.enact_support_exchange(user, target, distance)
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

#trade
func Trade(unit: CombatUnit, target: CombatUnit):
	print("Entered Trade in Combat.gd")
	combat_unit_item_manager.trade(unit, target)
	await trading_completed
	combat_unit_item_manager.free_current_node()
	minor_action_complete(unit)
	print("Exited Trade in Combat.gd")

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
	#decrement the turn reward modifier
	turn_reward_modifier -= .5
	#advace the current turn count
	current_turn += .5
	print("TURN#:" + str(current_turn))
	if victory_condition == Constants.VICTORY_CONDITION.SURVIVE_TURNS:
		check_win()

func major_action_complete():
	get_current_combatant().minor_action_taken = true
	get_current_combatant().turn_taken = true
	get_current_combatant().minor_action_taken = true
	get_current_combatant().update_display()
	emit_signal("major_action_completed")

func combatExchangeComplete(friendly_unit_alive:bool):
	_player_unit_alive = friendly_unit_alive
	major_action_complete()
	#WIN/LOSE CONDITION LOGIC
	if(check_win()):
		if heal_on_win:
			heal_ally_units()
		refresh_commander_signature_weapon()
		#playerOverworldData.next_level = win_go_to_scene
		#playerOverworldData.current_level += 1
		playerOverworldData.began_level = false
		playerOverworldData.gold += calculate_reward_gold()
		SelectedSaveFile.save(playerOverworldData)
		if playerOverworldData.last_room.type == CampaignRoom.TYPE.BATTLE:
			#if not at the final level, go back to the campaign map
			#if draft_amount_on_win > 0:
				#if allowed to draft after level
				#playerOverworldData.current_archetype_count = 0
				#playerOverworldData.max_archetype = draft_amount_on_win
				#SelectedSaveFile.save(playerOverworldData)
				#get_tree().change_scene_to_packed(preload("res://unit drafting/Unit_Commander Draft/army_drafting.tscn"))
			#else:
				#if battle_prep_on_win:
					#if allowed to go to battle prep on win
				#	get_tree().change_scene_to_packed(preload("res://ui/battle_preparation/battle_preparation.tscn"))
				#else:
			playerOverworldData.began_level = false
			playerOverworldData.current_level = null
			SelectedSaveFile.save(playerOverworldData)
			get_tree().change_scene_to_packed(preload("res://campaign_map/campaign_map.tscn"))
		else:
			#reset the game back to the start screen after final level so that it can be played again
			var win_number = playerOverworldData.hall_of_heroes_manager.latest_win_number + 1
			playerOverworldData.hall_of_heroes_manager.alive_winning_units[win_number] = playerOverworldData.total_party
			playerOverworldData.hall_of_heroes_manager.dead_winning_units[win_number] = playerOverworldData.dead_party_members
			playerOverworldData.hall_of_heroes_manager.winning_campaigns[win_number] = playerOverworldData.current_campaign
			playerOverworldData.hall_of_heroes_manager.latest_win_number += 1
			unlock_new_unit_types()
			reset_game_state()
			SelectedSaveFile.save(playerOverworldData)
			get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")
	if(check_lose()):
		reset_game_state()
		get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")

func reset_game_state():
	playerOverworldData.began_level = false
	playerOverworldData.completed_drafting = false
	playerOverworldData.current_level = null
	playerOverworldData.current_campaign = null
	playerOverworldData.total_party = []
	playerOverworldData.dead_party_members = []
	playerOverworldData.current_archetype_count = 0
	playerOverworldData.archetype_allotments = []
	playerOverworldData.campaign_map_data = []
	playerOverworldData.floors_climbed = 0

func heal_ally_units():
	for unit:Unit in playerOverworldData.total_party:
		unit.hp = unit.stats.hp

func refresh_commander_signature_weapon():
	for unit : Unit in playerOverworldData.total_party:
		if UnitTypeDatabase.get_commander_definition(unit.unit_type_key):
			var signature_weapon = UnitTypeDatabase.get_commander_definition(unit.unit_type_key).signature_weapon.db_key
			var items = unit.inventory.get_items()
			for item in items:
				if item and item.db_key == signature_weapon:
					item.refresh_uses()

func unlock_new_unit_types():
	var unlocked_units = playerOverworldData.current_campaign.unit_unlock_rewards
	for unlocked_unit in unlocked_units:
		if UnitTypeDatabase.unit_types.has(unlocked_unit) and !playerOverworldData.unlock_manager.unit_types_unlocked[unlocked_unit]:
			#If the unit database has the unlocked unit and it hasn't been unlocked yet
			playerOverworldData.unlock_manager.unit_types_unlocked[unlocked_unit] = true
			var unlock_panel : UnlockPanel= preload("res://ui/unlock_panel/unlock_panel.tscn").instantiate()
			unlock_panel.unlocked_entity = UnitTypeDatabase.unit_types[unlocked_unit]
			game_ui.add_child(unlock_panel)
			await get_tree().create_timer(8).timeout
			unlock_panel.queue_free()
		elif UnitTypeDatabase.commander_types.has(unlocked_unit) and !playerOverworldData.unlock_manager.commander_types_unlocked[unlocked_unit]:
			#If the commander database has the unlocked commander and it hasn't been unlocked yet
			playerOverworldData.unlock_manager.commander_types_unlocked[unlocked_unit] = true
			var unlock_panel : UnlockPanel= preload("res://ui/unlock_panel/unlock_panel.tscn").instantiate()
			unlock_panel.unlocked_entity = UnitTypeDatabase.commander_types[unlocked_unit]
			game_ui.add_child(unlock_panel)
			await get_tree().create_timer(8).timeout
			unlock_panel.queue_free()

func combatant_die(combatant: CombatUnit):
	var	comb_id = combatants.find(combatant)
	if comb_id != -1:
		combatant.alive = false
		groups[combatant.allegience].erase(comb_id)
		if playerOverworldData.total_party.has(combatant.unit):
			playerOverworldData.dead_party_members.append(combatant.unit)
			playerOverworldData.total_party.erase(combatant.unit)
		else:
			if !playerOverworldData.game_stats_manager.enemy_types_killed.get(combatant.unit.unit_type_key):
				playerOverworldData.game_stats_manager.enemy_types_killed[combatant.unit.unit_type_key] = 1
			else:
				playerOverworldData.game_stats_manager.enemy_types_killed[combatant.unit.unit_type_key] += 1
		dead_units.append(combatant)
		update_information.emit("[color=red]{0}[/color] died.\n".format([
			combatant.unit.name
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
	var attack_data: UnitCombatExchangeData
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
			attack_data = ai_equip_best_weapon(comb, nearest_target,l)
			await perform_attack(comb, nearest_target, attack_data)
			return
	#if the current unit AI types lets them move on map
	if(comb.ai_type != Constants.UNIT_AI_TYPE.DEFEND_POINT):
		await controller.ai_process(comb, nearest_target.map_tile.position)
		#await controller.finished_move
		print("finished waiting for controller")
		if comb_attack_range.has(get_distance(comb, nearest_target)):
			attack_data = ai_equip_best_weapon(comb, nearest_target,l)
			await perform_attack(comb, nearest_target, attack_data)
			return
	if comb:
		if is_instance_valid(comb.map_display) :
			comb.update_display()
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
			await perform_attack(comb, action.target, action.combat_action_data)
			print("@ FINISHED WAITING FOR ATTACK")
	if comb:
		if is_instance_valid(comb.map_display) :
			comb.update_display()
	return	 

func get_ai_units() -> Array[CombatUnit]:
	var enemy_unit_array : Array[CombatUnit]
	for enemy_unit in groups[Constants.FACTION.ENEMIES]:
		if combatants[enemy_unit]:
			enemy_unit_array.append(combatants[enemy_unit])
	return enemy_unit_array

func calc_expected_combat_exchange(attacker:CombatUnit, defender:CombatUnit, data: UnitCombatExchangeData) -> UnitCombatActionExpectedOutcome:
	#Get the values to run calcs on
	var combat_exchange_outcome : UnitCombatActionExpectedOutcome = UnitCombatActionExpectedOutcome.new()
	var max_damage : int = 0 # What is our max potential damage?
	var can_lethal : bool = false
	var attack_mult :int = 1
	var expected_damage : float = 0
	var exchange_info
	for turn in data.exchange_data:
		if turn.owner == attacker:
			var turn_damage = ((turn.attack_damage * turn.attack_count) * float(1 + turn.critical/float(100) * attacker.get_equipped().critical_multiplier))
			combat_exchange_outcome.expected_damage = combat_exchange_outcome.expected_damage + turn_damage
			combat_exchange_outcome.maximum_damage = combat_exchange_outcome.maximum_damage + ((turn.attack_damage * turn.attack_count) * attacker.get_equipped().critical_multiplier)
			if combat_exchange_outcome.expected_damage_taken < attacker.unit.hp:
				combat_exchange_outcome.expected_damage_before_defeat = combat_exchange_outcome.expected_damage_before_defeat + turn_damage
		elif turn.owner == defender:
			var turn_damage = ((turn.attack_damage * turn.attack_count) * float(1 + turn.critical/float(100) * defender.get_equipped().critical_multiplier))
			combat_exchange_outcome.expected_damage_taken = combat_exchange_outcome.expected_damage_taken + turn_damage
	# is it lethal?
	if (combat_exchange_outcome.maximum_damage > defender.unit.hp ):
		combat_exchange_outcome.can_lethal = true
	return combat_exchange_outcome

#
# Calculates the best attack action for a particular combat action
#
func ai_get_best_attack_action(ai_unit: CombatUnit, distance: int, target:CombatUnit, terrain: Terrain) -> aiAction:
	var best_action : aiAction = aiAction.new()
	var usable_weapons : Array[WeaponDefinition] =  ai_unit.unit.get_usable_weapons_at_range(distance)
	if not usable_weapons.is_empty():
		for i in range(usable_weapons.size()):
			ai_unit.unit.set_equipped(usable_weapons[i])
			var action: aiAction = aiAction.new()
			var data: UnitCombatExchangeData = combatExchange.generate_combat_exchange_data(ai_unit, target, distance)
			var combat_exchange_outcome : UnitCombatActionExpectedOutcome = calc_expected_combat_exchange(ai_unit, target, data)
			action.generate_attack_action_rating(terrain.avoid/100,combat_exchange_outcome.attacker_hit_chance, combat_exchange_outcome.expected_damage, target.unit.stats.hp, combat_exchange_outcome.can_lethal)
			action.item_index = i
			action.target = target
			action.action_type = "ATTACK"
			action.combat_action_data = data
			if best_action == null or action.rating > best_action.rating: 
				best_action = action
		print("@ BEST ATTACK RATING CALC : " + str(best_action.rating))
	return best_action

#
# calculates the best weapon the ai should use in an action
#
func ai_equip_best_weapon(comb: CombatUnit, target:CombatUnit, distance:int) -> UnitCombatExchangeData:
	## get weapon options
	var data: UnitCombatExchangeData
	var usable_weapons : Array[WeaponDefinition] =  comb.unit.get_usable_weapons_at_range(get_distance(comb, target))
	if not usable_weapons.is_empty():
		var expected_damage : Array[Vector2]
		for i in range(usable_weapons.size()):
			comb.unit.set_equipped(usable_weapons[i])
			data = combatExchange.generate_combat_exchange_data(comb, target, distance)
			expected_damage.append(Vector2(i, calc_expected_combat_exchange(comb, target, data).expected_damage))
		expected_damage.sort_custom(sort_by_y_value)
		print("@ EXPECTED DAMAGE CALC : " + str(expected_damage))
		comb.unit.set_equipped(usable_weapons[expected_damage.front().x])
	return data

func sort_by_y_value(a: Vector2, b : Vector2):
	return a.y > b.y

func complete_trade():
	trading_completed.emit()

func complete_shove():
	shove_completed.emit()
	
func minor_action_complete(unit: CombatUnit):
	unit.minor_action_taken = true
	set_current_combatant(unit)
	unit.update_display()
	emit_signal("minor_action_completed")

func unit_gain_experience(u: Unit, value: int):
	await unit_experience_manager.process_experience_gain(u, value)
	combatExchange.unit_gain_experience_complete()

func play_audio(sound : AudioStream):
	combat_audio.stream = sound
	combat_audio.play()
	await combat_audio.finished
	combatExchange.audio_player_ready()

func entity_added(cme:CombatEntity):
	controller.grid.set_entity(cme, cme.map_position)

func check_win():
	match victory_condition:
		Constants.VICTORY_CONDITION.DEFEAT_ALL:
			return check_group_clear(groups[1])
		Constants.VICTORY_CONDITION.DEFEAT_BOSS:
			return check_all_bosses_killed()
		Constants.VICTORY_CONDITION.CAPTURE_TILE:
			pass
		Constants.VICTORY_CONDITION.DEFEND_TILE:
			pass
		Constants.VICTORY_CONDITION.SURVIVE_TURNS:
			return check_turns_survived()

func check_group_clear(group):
	if group.is_empty():
		print("WIN!")
		return true

func check_all_bosses_killed():
	var enemy_units = groups[1]
	for enemy in enemy_units:
		if combatants[enemy].is_boss:
			return false
	return true

func check_turns_survived():
	return turns_to_survive > current_turn

func check_lose():
	return check_group_clear(groups[0])

func calculate_reward_gold():
	return base_win_gold_reward * clamp(turn_reward_modifier,1,999)

func heal_unit(cu:CombatUnit, amount:int):
	await combatExchange.heal_unit(cu, amount)

func entity_destroyed_combat(ce : CombatEntity):
	await entity_manager.entity_destroyed(ce)
	combatExchange._on_entity_destroyed_in_combat_effect_complete()

func give_curent_unit_items(items: Array[ItemDefinition], source: String):
	for item in items:
		await combat_unit_item_manager.give_combat_unit_item(get_current_combatant(), item)
	if source == CombatMapConstants.COMBAT_ENTITY:
		entity_manager._on_give_item_complete()

func create_unit_item_discard_container(cu: CombatUnit, new_item: ItemDefinition):
	# Create inventory slot data
	var inventory_data : Array[UnitInventorySlotData] = combat_unit_item_manager.generate_combat_unit_inventory_data(cu)
	# Create new item slot data
	var new_item_data : UnitInventorySlotData = combat_unit_item_manager.generate_combat_unit_inventory_data_for_item(cu, new_item)
	# Create UI Component
	pause_fsm.emit()
	game_ui.create_combat_unit_discard_inventory(cu, inventory_data, new_item_data)

func discard_item_selected(discard_item: ItemDefinition, cu: CombatUnit):
	game_ui.destory_active_ui_node()
	await combat_unit_item_manager.give_item_discard_result_complete(cu, discard_item)
	resume_fsm.emit()

func create_item_obtained_pop_up(item:ItemDefinition):
	pause_fsm.emit()
	await game_ui.create_item_obtained_pop_up(item)
	resume_fsm.emit()

func entity_interact_use_item(unit: CombatUnit, use_item:ItemDefinition, entity:CombatEntity):
	unit.unit.inventory.use_item(use_item)
	await entity_manager.entity_interacted(entity)

func entity_interact(unit: CombatUnit, entity:CombatEntity):
	entity_manager.entity_interacted(entity)
