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
signal combat_entity_added(cme:CombatEntity)
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
signal entity_processing_completed()
signal entity_processing()

signal spawn_reinforcement(reinforcement: CombatUnit)
signal reinforcement_check_completed()

var dead_units : Array[CombatUnit] = []
var combatants : Array[CombatUnit] = []
var inactive_units : Array[CombatUnit] = []
var units: Array[CombatUnit]

@export_storage var groups = [ #TO BE UPDATED TO DICTIONARY
	[], #players
	[], #enemies
	[], #FRIENDLY
	[],  #NOMAD
	[] #Terrain
]
	
var current_combatant = 0
@export var victory_condition : Constants.VICTORY_CONDITION = Constants.VICTORY_CONDITION.DEFEAT_ALL ##overwrite on _ready
@export var turns_to_survive:= 0
var combatExchange: CombatExchange


var _player_unit_alive : bool = true

@export var game_ui : Control
@export var controller : CController
@export var combat_audio : AudioStreamPlayer

## MANAGERS
# UNIT MANAGERS
@export var unit_experience_manager : UnitExperienceManager 
@export var combat_unit_item_manager : CombatUnitItemManager

# ENTITY MANAGER
@export var entity_manager : CombatMapEntityManager

# REINFORCEMENTS
@export var mapReinforcementData : MapReinforcementData
@export var reinforcement_manager : CombatMapReinforcementManager

# GAME GRID
@export var game_grid : CombatMapGrid

@export var ally_spawn_tiles : Array[Vector2i] = []

@export var unit_data : CombatMapUnitData = CombatMapUnitData.new()
#@export var enemy_start_group_options : Array[EnemyGroup]
#@onready var enemy_start_group : EnemyGroup = enemy_start_group_options.pick_random()


@export var level_reward : CombatReward

@export var is_key_campaign_level : bool = false
@export var is_tutorial := false
@export var tutorial_level : TutorialPanel.TUTORIAL
#@export var tutorial_level : TutorialPanel.TUTORIAL
#@export var draft_amount_on_win : int
#@export var battle_prep_on_win : bool = true
@export var heal_on_win : bool = true

@onready var current_turn = 1

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate()


func _ready():
	#max_allowed_ally_units = ally_spawn_tiles.size()
	#game_ui.set_po_data(playerOverworldData)
	emit_signal("register_combat", self)
	reinforcement_manager = CombatMapReinforcementManager.new()
	await reinforcement_manager
	combatExchange = $CombatExchange
	combat_audio = $CombatAudio
	unit_experience_manager = $UnitExperienceManager
	entity_manager = $CombatMapEntityManager
	#Connections CombatExchange 
	combatExchange.connect("combat_exchange_finished", combatExchangeComplete)
	combatExchange.connect("play_audio", play_audio)
	combatExchange.connect("gain_experience", unit_gain_experience)
	combatExchange.connect("unit_defeated",combatant_die)
	combatExchange.connect("entity_destroyed",entity_destroyed_combat)
	combatExchange.connect("give_items", give_curent_unit_items)
	combatExchange.connect("item_broken_popup_create", create_item_broken_pop_up)
	combatExchange.connect("item_expended_popup_create", create_item_expended_pop_up)
	#Connections Combat Unit Item Manager 
	combat_unit_item_manager.connect("heal_unit", heal_unit)
	combat_unit_item_manager.connect("create_discard_container", create_unit_item_discard_container)
	combat_unit_item_manager.connect("create_give_item_pop_up", create_item_obtained_pop_up)
	combat_unit_item_manager.connect("convoy_item", convoy_item)
	#Connections Entity Manager
	entity_manager.connect("entity_added", on_combat_entity_added)
	entity_manager.connect("give_items", give_curent_unit_items)
	entity_manager.connect("entity_process_complete",_on_entity_processing_completed)
	#Connections Reinforcement Manager
	reinforcement_manager.game_grid = game_grid
	reinforcement_manager.populate(mapReinforcementData)
	reinforcement_manager.connect("spawn_reinforcement", _on_reinforcement_manager_spawn_reinforcement)
	#randomize()
	unit_data.populate_map()

func set_game_grid(game_grid : CombatMapGrid):
	self.game_grid = game_grid
	reinforcement_manager.game_grid = game_grid

func populate():
	if is_tutorial:
			set_player_tutorial_party()
		
	if !playerOverworldData.battle_prep_complete:
		#if the level has not yet bgeun, spawn the units at their initial spawn points
		spawn_initial_units()
		for tile_index in ally_spawn_tiles.size():
			if !(tile_index >= playerOverworldData.selected_party.size()):
				add_combatant(create_combatant_unit(playerOverworldData.selected_party[tile_index],0),ally_spawn_tiles[tile_index])
		entity_manager.load_entities()
	else:
		#if it has begun, spawn the units according to where they were saved
		#var campaign_level = playerOverworldData.current_level.instantiate() #playerOverworldData.current_campaign.levels[playerOverworldData.current_level].instantiate()
		#var combat := campaign_level.get_child(2)
		#Spawn Ally Units
		#var ally_unit_indexes = combat.groups[0]
		for unit: Unit in playerOverworldData.unit_positions.keys():
			var saved_position = playerOverworldData.unit_positions[unit]
			var combat_unit = create_combatant_unit(unit,0)
			add_combatant(combat_unit, saved_position)
		#for ally_unit_index in ally_unit_indexes:
		#	var ally_unit :CombatUnit = combatants[ally_unit_index]
		#	var saved_position = ally_unit.map_position
		#	add_combatant(ally_unit, saved_position)
		#Spawn Enemy Units
		#var enemy_unit_indexes = combat.groups[1]
		#for enemy_unit_index in enemy_unit_indexes:
		#	var enemy_unit :CombatUnit = combatants[enemy_unit_index]
		#	var saved_position = enemy_unit.map_position
		#	add_combatant(enemy_unit, saved_position)


func set_player_tutorial_party():
	match tutorial_level:
		TutorialPanel.TUTORIAL.HOW_TO_PLAY:
			var commander = Unit.create_generic_unit("iron_viper",[ItemDatabase.commander_weapons["vipers_bite"]],"Commander",2)
			playerOverworldData.selected_party.append(commander)
		TutorialPanel.TUTORIAL.MUNDANE_WEAPONS:
			var sword_unit = Unit.create_generic_unit("sellsword",[ItemDatabase.items["iron_sword"]], "Sword", 2)
			playerOverworldData.selected_party.append(sword_unit)
			var axe_unit = Unit.create_generic_unit("fighter",[ItemDatabase.items["iron_axe"]], "Axe", 2)
			playerOverworldData.selected_party.append(axe_unit)
			var lance_unit = Unit.create_generic_unit("pikeman",[ItemDatabase.items["iron_lance"]], "Lance", 2)
			playerOverworldData.selected_party.append(lance_unit)
		TutorialPanel.TUTORIAL.MAGIC_WEAPONS:
			var dark_unit = Unit.create_generic_unit("shaman",[ItemDatabase.items["evil_eye"]], "Dark", 2)
			playerOverworldData.selected_party.append(dark_unit)
			var nature_unit = Unit.create_generic_unit("mage",[ItemDatabase.items["fire_spell"]], "Nature", 2)
			playerOverworldData.selected_party.append(nature_unit)
			var light_unit = Unit.create_generic_unit("bishop",[ItemDatabase.items["smite"]], "Light", 2)
			playerOverworldData.selected_party.append(light_unit)
		TutorialPanel.TUTORIAL.WEAPON_CYCLE:
			var mundane_unit = Unit.create_generic_unit("sellsword",[ItemDatabase.items["iron_sword"]], "Mundane", 2)
			playerOverworldData.selected_party.append(mundane_unit)
			var magic_unit = Unit.create_generic_unit("bishop",[ItemDatabase.items["smite"]], "Magic", 2)
			playerOverworldData.selected_party.append(magic_unit)
			var nimble_unit = Unit.create_generic_unit("thief",[ItemDatabase.items["iron_dagger"]], "Nimble", 2)
			playerOverworldData.selected_party.append(nimble_unit)
			var defensive_unit = Unit.create_generic_unit("ward",[ItemDatabase.items["iron_shield"]], "Defensive", 2)
			playerOverworldData.selected_party.append(defensive_unit)
		TutorialPanel.TUTORIAL.WEAPON_EFFECTIVENESS:
			var bow_unit = Unit.create_generic_unit("archer",[ItemDatabase.items["iron_bow"]],"Bow User",2)
			playerOverworldData.selected_party.append(bow_unit)
			var rapier_unit = Unit.create_generic_unit("sellsword",[ItemDatabase.items["rapier"]], "Rapier User", 2)
			playerOverworldData.selected_party.append(rapier_unit)
		TutorialPanel.TUTORIAL.SUPPORT_ACTIONS:
			pass
		TutorialPanel.TUTORIAL.STAFFS:
			var healer = Unit.create_generic_unit("healer",[ItemDatabase.items["minor_heal"]], "Staff", 2)
			playerOverworldData.selected_party.append(healer)
			var commander = Unit.create_generic_unit("iron_viper",[ItemDatabase.commander_weapons["vipers_bite"]],"Commander",2)
			playerOverworldData.selected_party.append(commander)
		TutorialPanel.TUTORIAL.BANNERS:
			pass
		TutorialPanel.TUTORIAL.TERRAIN:
			var heavy = Unit.create_generic_unit("axe_armor",[ItemDatabase.items["iron_axe"]],"Heavy",2)
			playerOverworldData.selected_party.append(heavy)
			var nimble_unit = Unit.create_generic_unit("thief",[ItemDatabase.items["iron_dagger"],ItemDatabase.items["skeleton_key"]], "Nimble", 2)
			playerOverworldData.selected_party.append(nimble_unit)
			var flying = Unit.create_generic_unit("freewing",[ItemDatabase.items["iron_sword"]],"Flying",2)
			playerOverworldData.selected_party.append(flying)
		TutorialPanel.TUTORIAL.MAP_ENTITY:
			var commander = Unit.create_generic_unit("iron_viper",[ItemDatabase.items["iron_sword"]],"Commander",2)
			playerOverworldData.selected_party.append(commander)
		TutorialPanel.TUTORIAL.DEFEAT_ALL_ENEMIES:
			var commander = Unit.create_generic_unit("iron_viper",[ItemDatabase.commander_weapons["vipers_bite"]],"Commander",4)
			playerOverworldData.selected_party.append(commander)
		TutorialPanel.TUTORIAL.SIEZE_LANDMARK:
			var commander = Unit.create_generic_unit("iron_viper",[ItemDatabase.commander_weapons["vipers_bite"]],"Commander",2)
			playerOverworldData.selected_party.append(commander)
		TutorialPanel.TUTORIAL.DEFEAT_BOSSES:
			var commander = Unit.create_generic_unit("iron_viper",[ItemDatabase.commander_weapons["vipers_bite"]],"Commander",2)
			playerOverworldData.selected_party.append(commander)
		TutorialPanel.TUTORIAL.SURVIVE_TURNS:
			var commander = Unit.create_generic_unit("iron_viper",[ItemDatabase.commander_weapons["vipers_bite"]],"Commander",2)
			playerOverworldData.selected_party.append(commander)

func get_first_available_unit_spawn_tile():
	for tile in ally_spawn_tiles:
		if !controller.grid.is_position_occupied(tile):
			return tile


func get_all_unit_positions_of_faction(faction : int) -> Array[Vector2i]:
	var _arr : Array[Vector2i] = []
	for unit_index in groups[faction]:
		var unit_position : Vector2i = combatants[unit_index].map_position
		_arr.append(unit_position)
	return _arr

func get_next_unit(cu: CombatUnit = null, forwards: bool = true) -> CombatUnit:
	if cu != null: 
		var current_unit_index = combatants.find(cu)
		# get the unit positon in the 2D faction array
		var faction_index = groups[cu.allegience].find(current_unit_index)
		var next_unit_index = 0 
		if forwards:
			next_unit_index = CustomUtilityLibrary.array_next_index_with_loop(groups[cu.allegience], faction_index)
			return combatants[groups[cu.allegience][next_unit_index]]
		else : 
			next_unit_index = CustomUtilityLibrary.array_previous_index_with_loop(groups[cu.allegience], faction_index) 
			return combatants[groups[cu.allegience][next_unit_index]]
	else: 
		if groups[0].is_empty():
			return combatants.front()
		else:
			return combatants[groups[0].front()]
	
func get_first_available_unit(faction_index :int = 0) -> CombatUnit:
	var _arr : Array[CombatUnit] = get_available_units(faction_index)
	if _arr.is_empty():
		return combatants[groups[faction_index].front()]
	else:
		return _arr.front()

func get_available_units(faction_index :int = 0) -> Array[CombatUnit]:
	var _arr : Array[CombatUnit] = []
	for index in groups[faction_index]:
		if combatants[index].turn_taken == false:
			_arr.append(combatants[index])
	return _arr

func check_reinforcement_spawn(turn_number : int):
	# get all the unit positions for friendly units
	if mapReinforcementData != null:
		var _unit_positon_array :Array[Vector2i] =  get_all_unit_positions_of_faction(Constants.FACTION.PLAYERS)
		# call the manager to see if there are reinforcements to be spawned, and await its completion
		await reinforcement_manager.check_reinforcement_spawn(turn_number, _unit_positon_array)
	await get_tree().create_timer(0.5).timeout
	reinforcement_check_completed.emit()

func spawn_initial_units(): ##ENEMY
	# do the units who have classes
	# get added levels from hardmode
	var _bonus_levels : int = 0
	var hard_mode_leveling : bool = false
	var goliath_mode : bool = playerOverworldData.campaign_modifiers.has(CampaignModifier.MODIFIER.GOLIATH_MODE)
	var hyper_growth : bool = playerOverworldData.campaign_modifiers.has(CampaignModifier.MODIFIER.HYPER_GROWTH)
	if playerOverworldData.campaign_difficulty == CampaignModifier.DIFFICULTY.HARD or playerOverworldData.campaign_modifiers.has(CampaignModifier.MODIFIER.HARD_LEVELING):
		_bonus_levels = 2 + int(playerOverworldData.combat_maps_completed*1.4)
		hard_mode_leveling = true
	for unit : CombatUnitData in unit_data.starting_enemy_group.group: #for unit :CombatUnitData in enemy_start_group.group:
		if unit is RandomCombatUnitData:
			generate_random_unit(unit)
		var enemy_unit : CombatUnit
		var new_unit = Unit.create_generic_unit(unit.unit_type_key, unit.inventory, unit.name, unit.level, unit.level_bonus + _bonus_levels, hard_mode_leveling, goliath_mode, hyper_growth)
		enemy_unit = create_combatant_unit(new_unit, 1, unit.ai_type, unit.drops_item, unit.is_boss,)
		add_combatant(enemy_unit, unit.map_position)


func generate_random_unit(target:RandomCombatUnitData):
	# Get the target Unit Type
	if unit_data.map_unit_data_table.has(target.unit_group):
		var _drop_item : bool = false
		#Get the unit data from the table
		var unit_type : UnitTypeDefinition = UnitTypeDatabase.unit_types.get(unit_data.map_unit_data_table.get(target.unit_group).get_loot())
		#Get the inventory from the unitType
		var _inventory :Array[ItemDefinition] = []
		#TODO allow user to override this item find if a table exists in the 
		#Weapon
		var weapon = unit_type.default_item_resource.weapon_default.get_loot()
		_inventory.append(weapon)
		#Treasure
		var treasure = unit_type.default_item_resource.treasure_default.get_loot()
		if treasure != null:
			_drop_item = true
			_inventory.append(treasure)
		# Randomize Level, with deviation around current depth
		# ensure bottom clamp is correct
		var _minimum_level : int = clampi(playerOverworldData.combat_maps_completed -2, 1, playerOverworldData.combat_maps_completed)
		var _level : int = clampi(randfn(playerOverworldData.combat_maps_completed, 2), _minimum_level, playerOverworldData.combat_maps_completed + 4)
		var _bonus_levels : int = target.level_bonus
		if target.is_boss:
			_bonus_levels = 3 + int(_level/2)
			_level = _level + 2
		#Get available positions
		var map_position : Vector2i = target.map_position
		var selectable_tiles : Array[Vector2i] = []
		if target.position_variance:
			selectable_tiles = game_grid.get_range_DFS(target.position_variance_weight, target.map_position)
			#Is the unit blocked in the tile, if so remove it from contention
			for tile in selectable_tiles:
				if game_grid.get_terrain(tile).blocks.has(unit_type.movement_type):
					selectable_tiles.erase(tile)
			#for index in range(selectable_tiles.size()-1):
			#	if game_grid.get_terrain(selectable_tiles[index]).blocks.has(unit_type.movement_type):
				#	selectable_tiles.remove_at(index)
				# ANY OTHER CHECKS FOR TILE VALIDITY GO HERE
			map_position = selectable_tiles.pick_random()
		target.unit_type_key = unit_type.db_key
		target.inventory = _inventory.duplicate() #IS THIS DUPLICATE REDUNDANT?
		target.level = _level
		target.drops_item = _drop_item
		target.level_bonus = _bonus_levels
		target.map_position = map_position

func create_combatant_unit(unit:Unit, team:int, ai_type: int = 0, has_droppable_item:bool = false, is_boss: bool = false):
	var comb = CombatUnit.create(unit, team, ai_type,is_boss, has_droppable_item)
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

func save_level_unit_positions():
	for group in groups:
		for unit_index in group:
			var ally_combat_unit = combatants[unit_index]
			playerOverworldData.unit_positions[ally_combat_unit] = ally_combat_unit.map_position
		
func advance_turn(faction: int):
	#save_level_unit_positions()
	#SelectedSaveFile.save(playerOverworldData)
	## Reset Players to active
	if faction < groups.size():
		for entry in groups[faction]:
			if combatants[entry]:
				combatants[entry].refresh_unit()
				combatants[entry].map_display.update_values()
	#decrement the turn reward modifier
	#turn_reward_modifier -= .5
	#advace the current turn count
	#current_turn += .5
	if is_equal_approx(current_turn, roundf(current_turn)):
		game_ui.set_turn_count_label(current_turn)
	if victory_condition == Constants.VICTORY_CONDITION.SURVIVE_TURNS:
		if check_win():
			combat_win()

func major_action_complete():
	get_current_combatant().minor_action_taken = true
	get_current_combatant().turn_taken = true
	get_current_combatant().minor_action_taken = true
	get_current_combatant().update_display()
	emit_signal("major_action_completed")

func combatExchangeComplete(friendly_unit_alive:bool):
	_player_unit_alive = friendly_unit_alive
	major_action_complete()
	if check_win():
		combat_win()
	if(check_lose()):
		reset_game_state()
		get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")

func reset_game_state():
	playerOverworldData.gold = 1000
	playerOverworldData.bonus_experience = 0
	playerOverworldData.level_entered = false
	playerOverworldData.battle_prep_complete = false
	playerOverworldData.completed_drafting = false
	playerOverworldData.current_level = null
	playerOverworldData.current_campaign = null
	playerOverworldData.total_party = []
	playerOverworldData.selected_party = []
	playerOverworldData.dead_party_members = []
	playerOverworldData.current_archetype_count = 0
	playerOverworldData.archetype_allotments = []
	playerOverworldData.campaign_map_data = []
	playerOverworldData.floors_climbed = 0 
	playerOverworldData.combat_maps_completed = 0

func heal_ally_units():
	for unit:Unit in playerOverworldData.total_party:
		unit.hp = unit.stats.hp

func refresh_expended_weapons():
	for unit : Unit in playerOverworldData.total_party:
		for item :ItemDefinition in unit.inventory.items:
			if item.has_expended_state:
				item.refresh_uses()

func unlock_new_unit_types():
	var unlocked_units := playerOverworldData.current_campaign.unit_unlock_rewards
	for unlocked_unit in unlocked_units:
		if UnitTypeDatabase.unit_types.has(unlocked_unit.db_key) and !playerOverworldData.unlock_manager.unit_types_unlocked[unlocked_unit]:
			#If the unit database has the unlocked unit and it hasn't been unlocked yet
			playerOverworldData.unlock_manager.unit_types_unlocked[unlocked_unit] = true
		elif UnitTypeDatabase.commander_types.has(unlocked_unit.db_key) and !playerOverworldData.unlock_manager.commander_types_unlocked[unlocked_unit]:
			#If the commander database has the unlocked commander and it hasn't been unlocked yet
			playerOverworldData.unlock_manager.commander_types_unlocked[unlocked_unit] = true
		create_unlock_panel(unlocked_unit)



func create_unlock_panel(unlocked_unit:UnitTypeDefinition):
	var unlock_panel : UnlockPanel= preload("res://ui/unlock_panel/unlock_panel.tscn").instantiate()
	unlock_panel.unlocked_entity = unlocked_unit
	game_ui.add_child(unlock_panel)
	await get_tree().create_timer(8).timeout
	unlock_panel.queue_free()


func combatant_die(combatant: CombatUnit):
	var comb_id = combatants.find(combatant)
	if comb_id != -1:
		combatant.alive = false
		groups[combatant.allegience].erase(comb_id)
		# Do player overworld data management
		if playerOverworldData.total_party.has(combatant.unit):
			#play unit died jingle?
			playerOverworldData.dead_party_members.append(combatant.unit)
			playerOverworldData.total_party.erase(combatant.unit)
			playerOverworldData.selected_party.erase(combatant.unit)
			convoy_inventory(combatant)
			level_reward.units_lost += 1
			combatant.unit.death_count += 1
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

func update_effective_combat_displays(combatant: CombatUnit):
	#get all units not in current unit faction
	for group_index in range(groups.size()):
		if group_index != combatant.allegience:
			#in future this data can be cached to speed up operations
			for combatant_index in groups[group_index]:
				if combatants[combatant_index].alive:
					if combatExchange.check_unit_can_do_effective_damage(combatants[combatant_index].unit, combatant.unit):
						combatants[combatant_index].map_display.set_is_effective(true)
					else :
						combatants[combatant_index].map_display.set_is_effective(false)


func reset_all_effective_indicators():
	for combatant in combatants:
		if combatant.alive:
			combatant.map_display.set_is_effective(false)

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
			comb.unit.set_equipped(action.selected_Weapon)
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
			#action.item_index = i
			action.selected_Weapon = usable_weapons[i]
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

func unit_gain_experience(cu: CombatUnit, value: int):
	await unit_experience_manager.process_experience_gain(cu, value)
	combatExchange.unit_gain_experience_complete()

func play_audio(sound : AudioStream):
	combat_audio.stream = sound
	combat_audio.play()
	await combat_audio.finished
	combatExchange.audio_player_ready()

func on_combat_entity_added(cme:CombatEntity):
	combat_entity_added.emit(cme)

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
	return turns_to_survive < current_turn

func check_lose():
	# Did we fail the objective?
	
	# Did our commander die?
	
	# Did all of our units die?
	return check_group_clear(groups[0])

#func calculate_reward_gold():
#	return base_win_gold_reward * clamp(turn_reward_modifier,1,999)

func heal_unit(cu:CombatUnit, amount:int):
	await combatExchange.heal_unit(cu, amount)

func entity_destroyed_combat(ce : CombatEntity):
	#entity_processing.emit()
	await entity_manager.entity_destroyed(ce)
	combatExchange._on_entity_destroyed_processing_completed()

func give_curent_unit_items(items: Array[ItemDefinition], source: String, target: CombatUnit = null):
	for item in items:
		if target != null :
			await combat_unit_item_manager.give_combat_unit_item(target, item)
		else : 
			await combat_unit_item_manager.give_combat_unit_item(get_current_combatant(), item)
	if source == CombatMapConstants.COMBAT_ENTITY:
		entity_manager._on_give_item_complete()
	if source == CombatMapConstants.COMBAT_EXCHANGE:
		combatExchange._on_give_item_complete()

func create_unit_item_discard_container(cu: CombatUnit, new_item: ItemDefinition):
	# Create inventory slot data
	var inventory_data : Array[UnitInventorySlotData] = combat_unit_item_manager.generate_combat_unit_inventory_data(cu)
	# Create new item slot data
	var new_item_data : UnitInventorySlotData = combat_unit_item_manager.generate_combat_unit_inventory_data_for_item(cu, new_item)
	# Create UI Component
	game_ui.create_combat_unit_discard_inventory(cu, inventory_data, new_item_data)

func discard_item_selected(discard_item: ItemDefinition, cu: CombatUnit):
	game_ui.destory_active_ui_node()
	await combat_unit_item_manager.give_item_discard_result_complete(cu, discard_item)

func create_item_obtained_pop_up(item:ItemDefinition):
	await game_ui.create_combat_view_pop_up_item_obtained(item)
	combat_unit_item_manager._on_give_item_popup_completed()

func create_item_broken_pop_up(item:ItemDefinition):
	await game_ui.create_combat_view_pop_up_item_broken(item)
	combatExchange._on_item_broken_popup_completed()

func create_item_expended_pop_up(item:ItemDefinition):
	await game_ui.create_combat_view_pop_up_expended(item)
	combatExchange._on_item_expended_popup_completed()

func create_stat_up_pop_up(item:ItemDefinition):
	await game_ui.create_combat_view_pop_up_stats_increased(item)
	combat_unit_item_manager._on_give_item_popup_completed()

func entity_interact_use_item(unit: CombatUnit, use_item:ItemDefinition, entity:CombatEntity):
	entity_processing.emit()
	unit.unit.inventory.use_item(use_item)
	await entity_manager.entity_interacted(entity)

func entity_interact(unit: CombatUnit, entity:CombatEntity):
	entity_processing.emit()
	entity_manager.entity_interacted(entity)

func _on_entity_processing_completed():
	entity_processing_completed.emit()

func _on_reinforcement_manager_spawn_reinforcement(cu: CombatUnit, position: Vector2i):
	if controller.perform_reinforcement_camera_adjustment(position):
		await get_tree().create_timer(1).timeout
		add_combatant(cu, position)
		await get_tree().create_timer(1).timeout
		reinforcement_manager._on_reinforcement_spawn_completed()

func combat_loss():
	reset_game_state()
	get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")

func combat_win():
	controller.update_game_state(CombatMapConstants.COMBAT_MAP_STATE.VICTORY)
	AudioManager.play_sound_effect("level_win")
	var reward_screen := preload("res://ui/combat/reward_panel/reward_panel.tscn").instantiate()
	level_reward.units_allowed = ally_spawn_tiles.size()
	level_reward.turns_survived = current_turn
	level_reward.calculate_survival_grade()
	level_reward.calculate_turn_grade()
	level_reward.calculate_overall_grade()
	level_reward.calculate_reward()
	reward_screen.reward = level_reward
	game_ui.add_child(reward_screen)
	reward_screen.rewards_complete.connect(_on_rewards_complete)
	reward_screen.gold_obtained.connect(_on_gold_obtained)
	reward_screen.bonus_exp_obtained.connect(_on_bonus_exp_obtained)

func remove_friendly_combatant(unit:Unit):
	for unit_index in groups[0]:
		print("Unit Index:" + str(unit_index))
		var target_combatant = combatants[unit_index]
		if target_combatant.unit == unit:
			groups[0].erase(unit_index)
			controller.grid.get_map_tile(target_combatant.map_position).unit = null
			combatants.erase(target_combatant)
			target_combatant.map_display.queue_free()
			#TO BE UPDATED LATER SO THAT LIST DOESN"T GET INFINITELY LONG
			#if unit_index >= combatants.size():
			#	return
			for index in range(groups[0].size()):
				print("Index Found with Value" + str(groups[0][index]))
				if groups[0][index] > unit_index:
					groups[0][index] -= 1
					print(str(unit_index) + "Index Updated to Value " + str(groups[0][index]))

func _on_gold_obtained(gold):
	#playerOverworldData.gold += calculate_reward_gold()
	playerOverworldData.gold += gold

func _on_bonus_exp_obtained(bonus_exp):
	playerOverworldData.bonus_experience += bonus_exp

func _on_rewards_complete():
	if heal_on_win:
		heal_ally_units()
	refresh_expended_weapons()
	#playerOverworldData.next_level = win_go_to_scene
	#playerOverworldData.current_level += 1
	playerOverworldData.level_entered = false
	playerOverworldData.battle_prep_complete = false
	if (is_key_campaign_level):
		playerOverworldData.combat_maps_completed += 1
	SelectedSaveFile.save(playerOverworldData)
	if is_tutorial:
		reset_game_state()
		SelectedSaveFile.save(playerOverworldData)
		get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")
	else:
		if playerOverworldData.last_room.type == CampaignRoom.TYPE.KEY_BATTLE or playerOverworldData.last_room.type == CampaignRoom.TYPE.BATTLE:
			playerOverworldData.level_entered = false
			playerOverworldData.current_level = null
			SelectedSaveFile.save(playerOverworldData)
			#Determine if a tier 1 unit needs to be promoted or not
			if check_tier_1_promotion_available():
				get_tree().change_scene_to_packed(preload("res://ui/promotion/promotion.tscn"))
			else:
				get_tree().change_scene_to_packed(preload("res://campaign_map/campaign_map.tscn"))
		else:
			#reset the game back to the start screen after final level so that it can be played again
			var win_number = playerOverworldData.hall_of_heroes_manager.latest_win_number + 1
			playerOverworldData.hall_of_heroes_manager.alive_winning_units[win_number] = playerOverworldData.total_party
			playerOverworldData.hall_of_heroes_manager.dead_winning_units[win_number] = playerOverworldData.dead_party_members
			playerOverworldData.hall_of_heroes_manager.winning_campaigns[win_number] = playerOverworldData.current_campaign
			playerOverworldData.hall_of_heroes_manager.latest_win_number += 1
			await unlock_new_unit_types()
			reset_game_state()
			SelectedSaveFile.save(playerOverworldData)
			#await get_tree().create_timer(8).timeout
			get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")

func convoy_item(item:ItemDefinition):
	playerOverworldData.convoy.append(item)

func convoy_inventory(combat_unit: CombatUnit):
	for item in combat_unit.unit.inventory.items:
		if item != null:
			combat_unit_item_manager.discard_item(combat_unit, item)

func check_tier_1_promotion_available() -> bool:
	for unit : Unit in playerOverworldData.selected_party:
		var unit_type = unit.get_unit_type_definition()
		if unit_type.tier == 1 and unit.level >= 10:
			return true
	return false
