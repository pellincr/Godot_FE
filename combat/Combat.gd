# ==============================================================================
# [Project Name]
# Copyright (c) 2026 Derc Development
# All rights reserved.
#
# File:     combat.gd
# Author:   Devin Murphy, Craig Pelling
# Created:  October 7 2024
# Modified: December 26 2025
# ==============================================================================
extends Node
class_name Combat
## Manages combat encounters and unit interactions.
##
## Works with [CController] to perform combat actions, storing unit data
## and coordinating battles between factions. Handles turn management,
## victory/defeat conditions, AI processing, and reward distribution.[br]
## [br]
## This node serves as the central hub for all combat-related operations
## including unit spawning, combat exchanges, item management, and
## reinforcement spawning.[br]
## [br]
## @tutorial(Combat System Overview): https://docs.example.com/combat
##
## @todo: TOD-001 - Update groups array to Dictionary keyed by Constants.FACTION.
## @todo: TOD-002 - Allow user to override item table in generate_random_unit().

# ==============================================================================
# CONSTANTS
# ==============================================================================

## Size of a single tile in pixels.
const TILE_SIZE: int = 32

## Half the tile size, used for centering sprites.
const TILE_HALF_SIZE: int = 16

## Delay between reinforcement spawn operations in seconds.
const REINFORCEMENT_SPAWN_DELAY: float = 0.25

## Duration to display reinforcement check timer in seconds.
const REINFORCEMENT_CHECK_DELAY: float = 0.5

## Duration to display unlock panels in seconds.
const UNLOCK_PANEL_DURATION: float = 8.0

## Small delay for UI transitions in seconds.
const UI_TRANSITION_DELAY: float = 0.1

## Preloaded scene for combat unit display sprites.
const COMBAT_UNIT_DISPLAY: PackedScene = preload(
	"res://ui/combat/combat_unit_display/combat_unit_display.tscn"
)

## Preloaded scene for combat map entity display sprites.
const COMBAT_MAP_ENTITY_DISPLAY: PackedScene = preload(
	"res://ui/combat/combat_map_entity_display/combat_map_entity_display.tscn"
)
# ==============================================================================
# SIGNALS
# ==============================================================================

## Emitted when combat is registered with the game controller.
## @param combat_node: The [Combat] node being registered.
signal register_combat(combat_node: Node)

## Emitted when the turn advances to the next phase.
signal turn_advanced()

## Emitted when a new combatant is added to the battlefield.
## @param combatant: The [CombatUnit] that was added.
signal combatant_added(combatant: CombatUnit)

## Emitted when a combat entity is added to the battlefield.
## @param cme: The [CombatEntity] that was added.
signal combat_entity_added(cme: CombatEntity)

## Emitted when a combatant dies in battle.
## @param combatant: The [CombatUnit] that died.
signal combatant_died(combatant: CombatUnit)

## Emitted to update the information display with new text.
## @param text: The BBCode-formatted text to display.
signal update_information(text: String)

## Emitted when the combatants list is updated.
## @param combatants: Array of all [CombatUnit] instances.
## @deprecated: This signal may be obsolete.
signal update_combatants(combatants: Array)

## Emitted when a target is selected for combat.
## @param combat_exchange_info: The selected [CombatUnit] target.
signal target_selected(combat_exchange_info: CombatUnit)

## Emitted to perform a shove action on a unit.
## @param unit: The [CombatUnit] being shoved.
## @param push_vector: The direction to push the unit.
signal perform_shove(unit: CombatUnit, push_vector: Vector2i)

## Emitted when a major action (attack, support, etc.) is completed.
signal major_action_completed()

## Emitted when a minor action (trade, etc.) is completed.
signal minor_action_completed()

## Emitted when trading between units is completed.
signal trading_completed()

## Emitted when a shove action is completed.
signal shove_completed()

## Emitted to pause the finite state machine.
signal pause_fsm()

## Emitted to resume the finite state machine.
signal resume_fsm()

## Emitted when entity processing is completed.
signal entity_processing_completed()

## Emitted when entity processing begins.
signal entity_processing()

## Emitted to spawn a reinforcement unit.
## @param reinforcement: The [CombatUnit] to spawn.
signal spawn_reinforcement(reinforcement: CombatUnit)

## Emitted when reinforcement checking is completed.
signal reinforcement_check_completed()

# ==============================================================================
# ENUMS
# ==============================================================================

# (No custom enums in this class - uses Constants.FACTION, Constants.VICTORY_CONDITION, etc.)


# ==============================================================================
# EXPORTED VARIABLES
# ==============================================================================
## The victory condition for this combat encounter.
## Overwritten during [method _ready] based on level configuration.
@export var victory_condition: Constants.VICTORY_CONDITION = Constants.VICTORY_CONDITION.DEFEAT_ALL

## Number of turns to survive for SURVIVE_TURNS victory condition.
@export var turns_to_survive: int = 0

## Reference to the game UI control node.
@export var game_ui: Control

## Reference to the combat controller.
@export var controller: CController

## Audio player for combat sounds.
@export var combat_audio: AudioStreamPlayer

## Manager for unit experience gains and level ups.
@export var unit_experience_manager: UnitExperienceManager

## Manager for combat unit item operations.
@export var combat_unit_item_manager: CombatUnitItemManager

## Manager for combat map entities (chests, destructibles, etc.).
@export var entity_manager: CombatMapEntityManager

## Data resource containing reinforcement spawn information.
@export var mapReinforcementData: MapReinforcementData

## Manager for spawning reinforcements during combat.
@export var reinforcement_manager: CombatMapReinforcementManager

## Reference to the combat map grid.
@export var game_grid: CombatMapGrid

## Spawn positions for ally units.
@export var ally_spawn_tiles: Array[Vector2i] = []

## Data resource containing unit spawn information for this map.
@export var unit_data: CombatMapUnitData = CombatMapUnitData.new()

## Reward configuration for completing this combat.
@export var level_reward: CombatReward

## Whether this is a boss encounter.
@export var is_boss_level: bool = false

## Whether this is a key campaign level that advances progress.
@export var is_key_campaign_level: bool = false

## Whether this is a tutorial level.
@export var is_tutorial: bool = false

## Whether this is a dev level for unit preview/testing.
@export var is_unit_preview_dev_level: bool = false

## The tutorial type for tutorial levels.
## @todo update all tutorial components
@export var tutorial_level: TutorialPanel.TUTORIAL

## Whether to heal all units on victory.
@export var heal_on_win: bool = true

## Storage for faction group indices.
## Example groups[0][index] 
## @todo: TOD-001 - Convert to Dictionary keyed by Constants.FACTION.
@export_storage var groups: Array = [
	[],  # PLAYERS (faction 0)
	[],  # ENEMIES (faction 1)
	[],  # FRIENDLY (faction 2)
	[],  # NOMAD (faction 3)
	[]   # TERRAIN (faction 4)
]

# ==============================================================================
# PUBLIC VARIABLES
# ==============================================================================

## Array of units that have died during this combat.
var dead_units: Array[CombatUnit] = []

## Array of all active combatants in this combat.
var combatants: Array[CombatUnit] = []

## Array of inactive units (benched, retreated, etc.).
var inactive_units: Array[CombatUnit] = []

## Generic units array.
## @deprecated: Consider using [member combatants] instead.
var units: Array[CombatUnit]

## Index of the current combatant in the [member combatants] array.
var current_combatant: int = 0

## Reference to the combat exchange handler.
var combatExchange: CombatExchange

## The current turn number.
@onready var current_turn: int = 1

## Instnace of Player overworld data loaded from save file, to be altered on and re-saved on level completion.
@onready var playerOverworldData: PlayerOverworldData = ResourceLoader.load(
	SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres"
).duplicate()


# ==============================================================================
# PRIVATE VARIABLES
# ==============================================================================

## Cached reference to the unit layer for sprite management.
@onready var _unit_layer: Node2D = $"../Terrain/UnitLayer"

## Tracks whether a player unit is still alive during combat exchange.
var _player_unit_alive: bool = true

# ==============================================================================
# BUILT-IN CALLBACKS
# ==============================================================================

func _ready() -> void:
	register_combat.emit(self)
	
	reinforcement_manager = CombatMapReinforcementManager.new()
	# Note: If async initialization is needed, the manager should emit a signal
	# await reinforcement_manager.initialized
	
	combatExchange = $CombatExchange
	combat_audio = $CombatAudio
	unit_experience_manager = $UnitExperienceManager
	entity_manager = $CombatMapEntityManager
	
	_connect_combat_exchange_signals()
	_connect_item_manager_signals()
	_connect_entity_manager_signals()
	_connect_reinforcement_manager_signals()
	
	unit_data.populate_map()

# ==============================================================================
# PRIVATE METHODS - SETUP & INITIALIZATION
# ==============================================================================

## Connects signals from the combat exchange system.
func _connect_combat_exchange_signals() -> void:
	combatExchange.combat_exchange_finished.connect(combatExchangeComplete)
	combatExchange.play_audio.connect(play_audio)
	combatExchange.gain_experience.connect(unit_gain_experience)
	combatExchange.unit_defeated.connect(combatant_die)
	combatExchange.entity_destroyed.connect(entity_destroyed_combat)
	combatExchange.give_items.connect(give_curent_unit_items)
	combatExchange.item_broken_popup_create.connect(create_item_broken_pop_up)
	combatExchange.item_expended_popup_create.connect(create_item_expended_pop_up)


## Connects signals from the item manager.
func _connect_item_manager_signals() -> void:
	combat_unit_item_manager.heal_unit.connect(heal_unit)
	combat_unit_item_manager.create_discard_container.connect(create_unit_item_discard_container)
	combat_unit_item_manager.create_give_item_pop_up.connect(create_item_obtained_pop_up)
	combat_unit_item_manager.convoy_item.connect(convoy_item)


## Connects signals from the entity manager.
func _connect_entity_manager_signals() -> void:
	entity_manager.entity_added.connect(_on_combat_entity_added)
	entity_manager.give_items.connect(give_curent_unit_items)
	entity_manager.entity_process_complete.connect(_on_entity_processing_completed)


## Connects signals from the reinforcement manager.
func _connect_reinforcement_manager_signals() -> void:
	reinforcement_manager.game_grid = game_grid
	reinforcement_manager.populate(mapReinforcementData)
	reinforcement_manager.spawn_reinforcement.connect(_on_reinforcement_manager_spawn_reinforcement)

# ==============================================================================
# PUBLIC METHODS - SETUP & INITIALIZATION
# ==============================================================================

## Sets the game grid reference for this combat and the reinforcement manager.
## @param grid: The [CombatMapGrid] to use.
func set_game_grid(grid: CombatMapGrid) -> void:
	self.game_grid = grid
	reinforcement_manager.game_grid = grid


## Populates the battlefield with units based on save state.
##
## If this is a unit preview dev level, spawns all unit types for testing.
## If battle prep is not complete, spawns initial units at starting positions.
## Otherwise, restores units to their saved positions.
func populate() -> void:
	if is_unit_preview_dev_level:
		spawn_all_unit_types()
		return
	
	if is_tutorial:
			set_player_tutorial_party()
	
	if not playerOverworldData.battle_prep_complete:
		entity_manager.load_entities()
		spawn_initial_units()
		
		for tile_index in ally_spawn_tiles.size():
			if tile_index < playerOverworldData.selected_party.size():
				var unit: Unit = playerOverworldData.selected_party[tile_index]
				var combat_unit: CombatUnit = create_combatant_unit(unit, 0)
				add_combatant(combat_unit, ally_spawn_tiles[tile_index])
	else:
		#if it has begun, spawn the units according to where they were saved
		for unit: Unit in playerOverworldData.unit_positions.keys():
			var saved_position = playerOverworldData.unit_positions[unit]
			var combat_unit = create_combatant_unit(unit,0)
			add_combatant(combat_unit, saved_position)

## Configures the player's party for tutorial levels.
##
## Creates specific unit compositions based on the tutorial type
## to teach different game mechanics.
func set_player_tutorial_party() -> void:
	match tutorial_level:
		TutorialPanel.TUTORIAL.HOW_TO_PLAY:
			var commander: Unit = Unit.create_generic_unit(
				"iron_viper",
				[ItemDatabase.commander_weapons["vipers_bite"]],
				"Commander",
				2
			)
			playerOverworldData.selected_party.append(commander)
			
		TutorialPanel.TUTORIAL.MUNDANE_WEAPONS:
			_add_tutorial_unit("sellsword", [ItemDatabase.items["iron_sword"]], "Sword", 2)
			_add_tutorial_unit("fighter", [ItemDatabase.items["iron_axe"]], "Axe", 2)
			_add_tutorial_unit("pikeman", [ItemDatabase.items["iron_lance"]], "Lance", 2)
			
		TutorialPanel.TUTORIAL.MAGIC_WEAPONS:
			_add_tutorial_unit("shaman", [ItemDatabase.items["evil_eye"]], "Dark", 2)
			_add_tutorial_unit("mage", [ItemDatabase.items["fire_spell"]], "Nature", 2)
			_add_tutorial_unit("bishop", [ItemDatabase.items["smite"]], "Light", 2)
			
		TutorialPanel.TUTORIAL.WEAPON_CYCLE:
			_add_tutorial_unit("sellsword", [ItemDatabase.items["iron_sword"]], "Mundane", 2)
			_add_tutorial_unit("bishop", [ItemDatabase.items["smite"]], "Magic", 2)
			_add_tutorial_unit("thief", [ItemDatabase.items["iron_dagger"]], "Nimble", 2)
			_add_tutorial_unit("ward", [ItemDatabase.items["iron_shield"]], "Defensive", 2)
			
		TutorialPanel.TUTORIAL.WEAPON_EFFECTIVENESS:
			_add_tutorial_unit("archer", [ItemDatabase.items["iron_bow"]], "Bow User", 2)
			_add_tutorial_unit("sellsword", [ItemDatabase.items["rapier"]], "Rapier User", 2)
			
		TutorialPanel.TUTORIAL.SUPPORT_ACTIONS:
			pass  # No special party configuration
			
		TutorialPanel.TUTORIAL.STAFFS:
			_add_tutorial_unit("healer", [ItemDatabase.items["minor_heal"]], "Staff", 2)
			var commander: Unit = Unit.create_generic_unit(
				"iron_viper",
				[ItemDatabase.commander_weapons["vipers_bite"]],
				"Commander",
				2
			)
			playerOverworldData.selected_party.append(commander)
			
		TutorialPanel.TUTORIAL.BANNERS:
			pass  # No special party configuration, STILL NEEDS TO BE CREATED
			
		TutorialPanel.TUTORIAL.TERRAIN:
			_add_tutorial_unit("axe_armor", [ItemDatabase.items["iron_axe"]], "Heavy", 2)
			_add_tutorial_unit(
				"thief",
				[ItemDatabase.items["iron_dagger"], ItemDatabase.items["skeleton_key"]],
				"Nimble",
				2
			)
			_add_tutorial_unit("freewing", [ItemDatabase.items["iron_sword"]], "Flying", 2)
			
		TutorialPanel.TUTORIAL.MAP_ENTITY:
			var commander: Unit = Unit.create_generic_unit(
				"iron_viper",
				[ItemDatabase.items["iron_sword"]],
				"Commander",
				2
			)
			playerOverworldData.selected_party.append(commander)
			
		TutorialPanel.TUTORIAL.DEFEAT_ALL_ENEMIES:
			var commander: Unit = Unit.create_generic_unit(
				"iron_viper",
				[ItemDatabase.commander_weapons["vipers_bite"]],
				"Commander",
				4
			)
			playerOverworldData.selected_party.append(commander)
			
		TutorialPanel.TUTORIAL.SIEZE_LANDMARK:
			var commander: Unit = Unit.create_generic_unit(
				"iron_viper",
				[ItemDatabase.commander_weapons["vipers_bite"]],
				"Commander",
				2
			)
			playerOverworldData.selected_party.append(commander)
			
		TutorialPanel.TUTORIAL.DEFEAT_BOSSES:
			var commander: Unit = Unit.create_generic_unit(
				"iron_viper",
				[ItemDatabase.commander_weapons["vipers_bite"]],
				"Commander",
				2
			)
			playerOverworldData.selected_party.append(commander)
			
		TutorialPanel.TUTORIAL.SURVIVE_TURNS:
			var commander: Unit = Unit.create_generic_unit(
				"iron_viper",
				[ItemDatabase.commander_weapons["vipers_bite"]],
				"Commander",
				2
			)
			playerOverworldData.selected_party.append(commander)

# ==============================================================================
# PUBLIC METHODS - UNIT MANAGEMENT
# ==============================================================================

## Returns the first available spawn tile that is not occupied.
## Returns: The first unoccupied [Vector2i] spawn position, or [code]null[/code].
func get_first_available_unit_spawn_tile() -> Variant:
	for tile in ally_spawn_tiles:
		if not controller.grid.is_position_occupied(tile):
			return tile
	return null

## Gets all unit positions for a given faction.
## @param faction: The faction index to query.
## Returns: Array of [Vector2i] positions for all units in the faction.
func get_all_unit_positions_of_faction(faction: int) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for unit_index in groups[faction]:
		var unit_position: Vector2i = combatants[unit_index].map_position
		positions.append(unit_position)
	return positions


## Gets the next unit in turn order from the same faction.
## @param cu: The current [CombatUnit], or [code]null[/code] for first unit.
## @param forwards: If [code]true[/code], search forwards; otherwise backwards.
## Returns: The next [CombatUnit] in turn order.
func get_next_unit(cu: CombatUnit = null, forwards: bool = true) -> CombatUnit:
	if cu == null:
		if groups[0].is_empty():
			return combatants.front()
		else:
			return combatants[groups[0].front()]
	
	var current_unit_index: int = combatants.find(cu)
	var faction_index: int = groups[cu.allegience].find(current_unit_index)
	var faction_index_iterator: int = faction_index
	var next_unit_index: int = 0
	
	if forwards:
		for _i in range(groups[cu.allegience].size()):
			next_unit_index = CustomUtilityLibrary.array_next_index_with_loop(
				groups[cu.allegience],
				faction_index_iterator
			)
			var potential_next_unit: CombatUnit = combatants[groups[cu.allegience][next_unit_index]]
			if not potential_next_unit.turn_taken:
				return combatants[groups[cu.allegience][next_unit_index]]
			faction_index_iterator = next_unit_index
		
		# Fallback if there are no available units
		next_unit_index = CustomUtilityLibrary.array_next_index_with_loop(
			groups[cu.allegience],
			faction_index
		)
		return combatants[groups[cu.allegience][next_unit_index]]
	else:
		for _i in range(groups[cu.allegience].size()):
			next_unit_index = CustomUtilityLibrary.array_previous_index_with_loop(
				groups[cu.allegience],
				faction_index_iterator
			)
			var potential_next_unit: CombatUnit = combatants[groups[cu.allegience][next_unit_index]]
			if not potential_next_unit.turn_taken:
				return combatants[groups[cu.allegience][next_unit_index]]
			faction_index_iterator = next_unit_index
		
		# Fallback if there are no available units
		next_unit_index = CustomUtilityLibrary.array_previous_index_with_loop(
			groups[cu.allegience],
			faction_index
		)
		return combatants[groups[cu.allegience][next_unit_index]]


## Gets the first unit in a faction that hasn't taken their turn.
## @param faction_index: The faction to search (default: 0 for players).
## Returns: The first available [CombatUnit], or the faction's first unit.
func get_first_available_unit(faction_index: int = 0) -> CombatUnit:
	var available: Array[CombatUnit] = get_available_units(faction_index)
	if available.is_empty():
		return combatants[groups[faction_index].front()]
	else:
		return available.front()


## Gets all units in a faction that haven't taken their turn.
## @param faction_index: The faction to search (default: 0 for players).
## Returns: Array of [CombatUnit] instances that can still act.
func get_available_units(faction_index: int = 0) -> Array[CombatUnit]:
	var available: Array[CombatUnit] = []
	for index in groups[faction_index]:
		if not combatants[index].turn_taken:
			available.append(combatants[index])
	return available


## Adds a combatant to the battlefield at the specified position.
## @param combat_unit: The [CombatUnit] to add.
## @param position: The [Vector2i] grid position to place the unit.
func add_combatant(combat_unit: CombatUnit, position: Vector2i) -> void:
	combat_unit.map_position = position
	combat_unit.map_terrain = controller.grid.get_terrain(position)
	combatants.append(combat_unit)
	groups[combat_unit.allegience].append(combatants.size() - 1)
	
	var new_combatant_sprite: CombatUnitDisplay = COMBAT_UNIT_DISPLAY.instantiate()
	combat_unit.stats.populate_unit_stats(combat_unit.unit)
	new_combatant_sprite.set_reference_unit(combat_unit)
	_unit_layer.add_child(new_combatant_sprite)
	new_combatant_sprite.position = Vector2(position * TILE_SIZE) + Vector2(TILE_HALF_SIZE, TILE_HALF_SIZE)
	new_combatant_sprite.z_index = 1
	combat_unit.map_display = new_combatant_sprite
	
	combatant_added.emit(combat_unit)


## Removes a friendly combatant from the battlefield. Assumes units have been populated in this order 1st AI then 2nd PLAYER.
## @param unit: The [Unit] resource to find and remove.
func remove_friendly_combatant(unit: Unit) -> void:
	for unit_index in groups[0]:
		var target_combatant: CombatUnit = combatants[unit_index]
		if target_combatant.unit == unit:
			groups[0].erase(unit_index)
			controller.grid.get_map_tile(target_combatant.map_position).unit = null
			combatants.erase(target_combatant)
			target_combatant.map_display.queue_free()
			
			# Update indices for remaining units
			for index in range(groups[0].size()):
				if groups[0][index] > unit_index:
					groups[0][index] -= 1
			return


## Returns the currently active combatant.
## Returns: The current [CombatUnit].
func get_current_combatant() -> CombatUnit:
	return combatants[current_combatant]


## Sets the currently active combatant.
## @param cu: The [CombatUnit] to set as current.
func set_current_combatant(cu: CombatUnit) -> void:
	current_combatant = combatants.find(cu)


## Creates a new [CombatUnit] from a [Unit] resource.
## @param unit: The base [Unit] to create from.
## @param team: The team/faction index.
## @param ai_type: The AI behavior type (default: 0).
## @param has_droppable_item: Whether the unit drops items on death.
## @param is_boss: Whether this is a boss unit.
## Returns: The created [CombatUnit].
func create_combatant_unit(unit:Unit, team:int, ai_type: int = 0, has_droppable_item:bool = false, is_boss: bool = false)-> CombatUnit:
	return CombatUnit.create(unit, team, ai_type, is_boss, has_droppable_item)


# ==============================================================================
# PUBLIC METHODS - COMBAT ACTIONS
# ==============================================================================

## Calculates the Manhattan distance between two combatants.
## @param attacker: The attacking [CombatUnit].
## @param target: The target [CombatUnit].
## Returns: The distance in tiles.
func get_distance(attacker: CombatUnit, target: CombatUnit) -> int:
	var point1: Vector2i = attacker.map_position
	var point2: Vector2i = target.map_position
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)


## Performs an attack action between two units.
## @param attacker: The attacking [CombatUnit].
## @param target: The target [CombatUnit].
## @param data: The [UnitCombatExchangeData] containing attack parameters.
func perform_attack(attacker: CombatUnit, target: CombatUnit, data: UnitCombatExchangeData) -> void:
	_player_unit_alive = true
	await combatExchange.enact_combat_exchange_new(attacker, target, data)
	major_action_complete()
	
	if attacker.allegience == Constants.FACTION.ENEMIES:
		complete_unit_turn()

## Performs an attack action against a combat entity.
## @param attacker: The attacking [CombatUnit].
## @param target: The target [CombatEntity].
## @param data: The [UnitCombatExchangeData] containing attack parameters.
func perform_attack_entity(	attacker: CombatUnit, target: CombatEntity,	data: UnitCombatExchangeData) -> void:
	_player_unit_alive = true
	await combatExchange.enact_combat_exchange_entity(attacker, target, data)
	major_action_complete()
	
	if attacker.allegience == Constants.FACTION.ENEMIES:
		complete_unit_turn()


## Performs a support action between two units.
## @param supporter: The supporting [CombatUnit].
## @param target: The target [CombatUnit].
## @param data: The [UnitSupportExchangeData] containing support parameters.
func perform_support(supporter: CombatUnit, target: CombatUnit, data: UnitSupportExchangeData) -> void:
	_player_unit_alive = true
	await combatExchange.enact_support_exchange(supporter, target, data)
	major_action_complete()
	
	if supporter.allegience == Constants.FACTION.ENEMIES:
		complete_unit_turn()


## Initiates a trade between two units.
## @param unit: The initiating [CombatUnit].
## @param target: The target [CombatUnit] to trade with.
func Trade(unit: CombatUnit, target: CombatUnit) -> void:
	combat_unit_item_manager.trade(unit, target)
	await trading_completed
	combat_unit_item_manager.free_current_node()
	minor_action_complete(unit)


## Initiates a support action between two units.
## @param user: The supporting [CombatUnit].
## @param target: The target [CombatUnit].
## @deprecated: This function is no longer in use, use [perform_support] instead
func Support(user: CombatUnit, target: CombatUnit) -> void:
	#await perform_staff(user, target)
	major_action_complete()


## Ends the current unit's turn without taking an action.
## @param unit: The [CombatUnit] waiting.
## @deprecated: This method may be obsolete.
func Wait(unit: CombatUnit) -> void:
	major_action_complete()


## Placeholder for inventory management.
## @param unit: The [CombatUnit] managing items.
## @deprecated: This function is not implemented.
func Items(unit: CombatUnit) -> void:
	push_warning("Combat: Items() called but not implemented")


## Uses a consumable item on the current combatant.
## @param unit: The [CombatUnit] using the item.
## @param item: The [ConsumableItemDefinition] to use.
func Use(unit: CombatUnit, item: ConsumableItemDefinition) -> void:
	var current_unit: CombatUnit = get_current_combatant()
	current_unit.unit.use_consumable_item(item)
	current_unit.map_display.update_values()
	await current_unit.map_display.update_complete
	complete_unit_turn()
	major_action_complete()


## Performs a shove action to push a unit.
## @param unit: The [CombatUnit] performing the shove.
## @param target: The [CombatUnit] being shoved.
func Shove(unit: CombatUnit, target: CombatUnit) -> void:
	if get_distance(unit, target) == 1:
		var push_vector: Vector2i = target.map_tile.position - unit.map_tile.position
		perform_shove.emit(target, push_vector)
		await shove_completed
		set_current_combatant(unit)
	else:
		push_warning("Combat: Invalid shove target - distance must be 1")
	
	complete_unit_turn()
	major_action_complete()

## Marks the current combatant's turn as complete.
func complete_unit_turn() -> void:
	get_current_combatant().turn_taken = true


## Signals that a trade has been completed.
func complete_trade() -> void:
	trading_completed.emit()


## Signals that a shove has been completed.
func complete_shove() -> void:
	shove_completed.emit()


## Completes a minor action for a unit by adjusting appropriate fields.
## @param unit: The [CombatUnit] that completed the minor action.
func minor_action_complete(unit: CombatUnit) -> void:
	unit.minor_action_taken = true
	set_current_combatant(unit)
	unit.update_display()
	minor_action_completed.emit()


# ==============================================================================
# PUBLIC METHODS - TURN MANAGEMENT
# ==============================================================================

## Checks map reinforcement data and spawns reinforcements for the given turn if applicable.
## @param turn_number: The current turn number.
func check_reinforcement_spawn(turn_number: int) -> void:
	if mapReinforcementData != null:
		var unit_positions: Array[Vector2i] = get_all_unit_positions_of_faction(
			Constants.FACTION.PLAYERS
		)
		await reinforcement_manager.check_reinforcement_spawn(turn_number, unit_positions)
	
	await get_tree().create_timer(REINFORCEMENT_CHECK_DELAY).timeout
	reinforcement_check_completed.emit()


## Advances the turn for a faction, refreshing their units.
## @param faction: The faction index to advance.
func advance_turn(faction: int) -> void:
	if faction < groups.size():
		for entry in groups[faction]:
			var unit: CombatUnit = combatants[entry]
			if unit:
				unit.refresh_unit()
				unit.map_display.update_values()
	
	if is_equal_approx(current_turn, roundf(current_turn)):
		game_ui.set_turn_count_label(current_turn)
		game_ui.set_turn_count_color(current_turn, level_reward.par_turns)
	
	if victory_condition == Constants.VICTORY_CONDITION.SURVIVE_TURNS:
		if check_win():
			combat_win()


## Saves the current positions of all units for level persistence.
## Note
func save_level_unit_positions() -> void:
	for group in groups:
		for unit_index in group:
			var ally_combat_unit: CombatUnit = combatants[unit_index]
			playerOverworldData.unit_positions[ally_combat_unit] = ally_combat_unit.map_position


# ==============================================================================
# PUBLIC METHODS - COMBAT RESOLUTION
# ==============================================================================

## Checks if the win condition has been met.
## Returns: [code]true[/code] if the player has won.
func check_win() -> bool:
	match victory_condition:
		Constants.VICTORY_CONDITION.DEFEAT_ALL:
			return check_group_clear(groups[1])
		Constants.VICTORY_CONDITION.DEFEAT_BOSS:
			return check_all_bosses_killed()
		Constants.VICTORY_CONDITION.CAPTURE_TILE:
			return false  # Not implemented
		Constants.VICTORY_CONDITION.DEFEND_TILE:
			return false  # Not implemented
		Constants.VICTORY_CONDITION.SURVIVE_TURNS:
			return check_turns_survived()
	return false


## Checks if the lose condition has been met.
## Returns: [code]true[/code] if the player has lost.
## TODO needs to expand this to multiple losing criteria, protected unit dies, defended point is siezed etc.
func check_lose() -> bool:
	return check_group_clear(groups[0])


## Checks if a faction group has no remaining units.
## @param group: The group array to check.
## Returns: [code]true[/code] if the group is empty.
func check_group_clear(group: Array) -> bool:
	return group.is_empty()


## Checks if all boss units have been defeated.
## Returns: [code]true[/code] if no bosses remain alive.
func check_all_bosses_killed() -> bool:
	var enemy_units: Array = groups[1] ##NOTE verify this can be typed to Array[CombatUnit]
	for enemy in enemy_units:
		if combatants[enemy].is_boss:
			return false
	return true


## Checks if the required turns have been survived.
## Returns: [code]true[/code] if enough turns have passed.
func check_turns_survived() -> bool:
	return turns_to_survive < current_turn


## Handles a combatant's death.
## @param combatant: The [CombatUnit] that died.
func combatant_die(combatant: CombatUnit) -> void:
	var comb_id: int = combatants.find(combatant)
	if comb_id == -1:
		return
	
	combatant.alive = false
	groups[combatant.allegience].erase(comb_id)
	# Do PlayerOverworldData clean up for friendlies
	if playerOverworldData.total_party.has(combatant.unit):
		playerOverworldData.dead_party_members.append(combatant.unit)
		playerOverworldData.total_party.erase(combatant.unit)
		playerOverworldData.selected_party.erase(combatant.unit)
		convoy_inventory(combatant)
		level_reward.units_lost += 1
		combatant.unit.death_count += 1
	else:
		#Do enemy kiled tracking updates
		var kill_count: Variant = playerOverworldData.game_stats_manager.enemy_types_killed.get(
			combatant.unit.unit_type_key
		)
		if not kill_count:
			playerOverworldData.game_stats_manager.enemy_types_killed[combatant.unit.unit_type_key] = 1
		else:
			playerOverworldData.game_stats_manager.enemy_types_killed[combatant.unit.unit_type_key] += 1
	
	dead_units.append(combatant)
	update_information.emit("[color=red]{0}[/color] died.\n".format([combatant.unit.name]))
	combatant_died.emit(combatant)


## Handles victory resolution and creates the reward panel.
func combat_win() -> void:
	controller.update_game_state(CombatMapConstants.COMBAT_MAP_STATE.VICTORY)
	AudioManager.play_sound_effect("level_win")
	
	var reward_screen: Node = preload("res://ui/combat/reward_panel/reward_panel.tscn").instantiate()
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


## Handles defeat resolution.
func combat_loss() -> void:
	reset_game_state()
	get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")


## Resets all game state for a new game.
func reset_game_state() -> void:
	playerOverworldData.gold = 0
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


# ==============================================================================
# PUBLIC METHODS - UNIT SPAWNING
# ==============================================================================

## Spawns initial enemy units for the map.
##
## Applies difficulty modifiers and level bonuses based on campaign settings.
func spawn_initial_units() -> void:
	var bonus_levels: int = 0
	var hard_mode_leveling: bool = false
	var goliath_mode: bool = playerOverworldData.campaign_modifiers.has(CampaignModifier.MODIFIER.GOLIATH_MODE)
	var hyper_growth: bool = playerOverworldData.campaign_modifiers.has(CampaignModifier.MODIFIER.HYPER_GROWTH)
	var effective_level_augment: int = 0
	
	if playerOverworldData.campaign_difficulty == CampaignModifier.DIFFICULTY.HARD:
		bonus_levels = 2 + int(playerOverworldData.combat_maps_completed * 1.4)
		hard_mode_leveling = true
	
	if playerOverworldData.campaign_difficulty == CampaignModifier.DIFFICULTY.EASY:
		bonus_levels = clampi(-2 + int(playerOverworldData.combat_maps_completed * 1.4), -2, 0)
	
	if playerOverworldData.campaign_modifiers.has(CampaignModifier.MODIFIER.LEVEL_SURGE):
		effective_level_augment = 9
	
	for unit_data_entry: CombatUnitData in unit_data.starting_enemy_group.group:
		if unit_data_entry is RandomCombatUnitData:
			generate_random_unit(unit_data_entry)
		
		var new_unit: Unit = Unit.create_generic_unit(
			unit_data_entry.unit_type_key,
			unit_data_entry.inventory,
			unit_data_entry.name,
			unit_data_entry.level + effective_level_augment,
			unit_data_entry.level_bonus + bonus_levels,
			hard_mode_leveling,
			goliath_mode,
			hyper_growth
		)
		var enemy_unit: CombatUnit = create_combatant_unit(
			new_unit,
			1,
			unit_data_entry.ai_type,
			unit_data_entry.drops_item,
			unit_data_entry.is_boss
		)
		add_combatant(enemy_unit, unit_data_entry.map_position)

## Generates random attributes for a random combat unit.
## @param target: The [RandomCombatUnitData] to populate.
##
## @todo: TOD-002 - Allow user to override item find if a table exists.
func generate_random_unit(target: RandomCombatUnitData) -> void:
	if not unit_data.map_unit_data_table.has(target.unit_group):
		return
	
	var drop_item: bool = false
	var unit_type: UnitTypeDefinition = UnitTypeDatabase.unit_types.get(
		unit_data.map_unit_data_table.get(target.unit_group).get_loot()
	)
	
	var inventory: Array[ItemDefinition] = []
	var weapon: ItemDefinition = unit_type.default_item_resource.weapon_default.get_loot()
	inventory.append(weapon)
	
	var treasure: ItemDefinition = unit_type.default_item_resource.treasure_default.get_loot()
	if treasure != null:
		drop_item = true
		inventory.append(treasure)
	
	#Unit Level Code
	var minimum_level: int = clampi(
		playerOverworldData.combat_maps_completed - 2,
		1,
		playerOverworldData.combat_maps_completed
	)
	var level: int = clampi(
		int(randfn(playerOverworldData.combat_maps_completed, 2)),
		minimum_level,
		playerOverworldData.combat_maps_completed + 4
	)
	var bonus_levels: int = target.level_bonus
	
	if target.is_boss:
		bonus_levels = 3 + int(level / 2)
		level = level + 2
	
	var map_position: Vector2i = target.map_position
	
	#Get all selectable tiles
	if target.position_variance:
		var selectable_tiles: Array[Vector2i] = game_grid.get_range_DFS(
			target.position_variance_weight,
			target.map_position,
			unit_type.movement_type,
			true,
			1
		)
		
		#Filter selectable tiles
		selectable_tiles = selectable_tiles.filter(func(tile: Vector2i) -> bool:
			if game_grid.is_position_occupied(tile):
				return false
			if game_grid.get_terrain(tile).blocks.has(unit_type.movement_type):
				return false
			return true
		)
		
		if not selectable_tiles.is_empty():
			map_position = selectable_tiles.pick_random()
	
	#populate output resource
	target.unit_type_key = unit_type.db_key
	target.inventory = inventory.duplicate()
	target.level = level
	target.drops_item = drop_item
	target.level_bonus = bonus_levels
	target.map_position = map_position

## Spawns all unit types at various levels for testing/preview.
##
## Used only in development for balance testing.
func spawn_all_unit_types() -> void:
	var bonus_levels: int = 0
	var hard_mode_leveling: bool = false
	var goliath_mode: bool = playerOverworldData.campaign_modifiers.has(
		CampaignModifier.MODIFIER.GOLIATH_MODE
	)
	var hyper_growth: bool = playerOverworldData.campaign_modifiers.has(
		CampaignModifier.MODIFIER.HYPER_GROWTH
	)
	var generic: bool = playerOverworldData.campaign_modifiers.has(
		CampaignModifier.MODIFIER.GENERICS
	)
	var effective_level_augment: int = 0
	var unit_levels: Array[int] = [1, 5, 10, 20]
	
	var available_positions: Array[Vector2i] = []
	var available_position_index: int = 0
	
	for x in 20:
		for y in 20:
			available_positions.append(Vector2i(x, y))
	
	if playerOverworldData.campaign_difficulty == CampaignModifier.DIFFICULTY.HARD:
		bonus_levels = 2 + int(playerOverworldData.combat_maps_completed * 1.4)
		hard_mode_leveling = true
	
	if playerOverworldData.campaign_difficulty == CampaignModifier.DIFFICULTY.EASY:
		bonus_levels = clampi(
			-2 + int(playerOverworldData.combat_maps_completed * 1.4),
			-2,
			0
		)
	
	if playerOverworldData.campaign_modifiers.has(CampaignModifier.MODIFIER.LEVEL_SURGE):
		effective_level_augment = 9
	
	for commander_unit: CommanderDefinition in UnitTypeDatabase.commander_types.values():
		for level_value in unit_levels:
			var new_unit: Unit = Unit.create_generic_unit(
				commander_unit.db_key,
				[],
				commander_unit.unit_type_name,
				level_value + effective_level_augment,
				0 + bonus_levels,
				hard_mode_leveling,
				goliath_mode,
				hyper_growth,
				generic
			)
			var enemy_unit: CombatUnit = create_combatant_unit(
				new_unit,
				1,
				Constants.UNIT_AI_TYPE.DEFEND_POINT,
				false,
				false
			)
			add_combatant(enemy_unit, available_positions[available_position_index])
			available_position_index += 1
	
	for unit: UnitTypeDefinition in UnitTypeDatabase.unit_types.values():
		for level_value in unit_levels:
			var new_unit: Unit = Unit.create_generic_unit(
				unit.db_key,
				[],
				unit.unit_type_name,
				level_value + effective_level_augment,
				0 + bonus_levels,
				hard_mode_leveling,
				goliath_mode,
				hyper_growth,
				generic
			)
			var enemy_unit: CombatUnit = create_combatant_unit(
				new_unit,
				1,
				Constants.UNIT_AI_TYPE.DEFEND_POINT,
				false,
				false
			)
			add_combatant(enemy_unit, available_positions[available_position_index])
			available_position_index += 1

# ==============================================================================
# PUBLIC METHODS - AI
# ==============================================================================

## Processes AI turn for a combatant (legacy method).
## @param comb: The [CombatUnit] to process AI for.
## @deprecated: Replaced by ai_process_new
func ai_process(comb: CombatUnit) -> void:
	var comb_attack_range: Array[int] = comb.unit.inventory.get_available_attack_ranges()
	var nearest_target: CombatUnit = null
	var nearest_distance: float = INF
	var attack_data: UnitCombatExchangeData
	
	for target_comb_index in groups[Constants.FACTION.PLAYERS]:
		var target: CombatUnit = combatants[target_comb_index]
		var distance: int = get_distance(comb, target)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_target = target
	
	if nearest_target:
		var distance_to_target: int = get_distance(comb, nearest_target)
		if comb_attack_range.has(distance_to_target):
			attack_data = ai_equip_best_weapon(comb, nearest_target, distance_to_target)
			await perform_attack(comb, nearest_target, attack_data)
			return
	
	if comb.ai_type != Constants.UNIT_AI_TYPE.DEFEND_POINT:
		await controller.ai_process(comb, nearest_target.map_tile.position)
		
		var distance_after_move: int = get_distance(comb, nearest_target)
		if comb_attack_range.has(distance_after_move):
			attack_data = ai_equip_best_weapon(comb, nearest_target, distance_after_move)
			await perform_attack(comb, nearest_target, attack_data)
			return
	
	if comb and is_instance_valid(comb.map_display):
		comb.update_display()


## Processes AI turn for a combatant using the new action system.
## @param ai_action: The [aiAction] to execute.
func ai_process_new(ai_action: aiAction) -> void:
	if ai_action == null:
		return
	
	if ai_action.action_type == aiAction.ACTION_TYPES.COMBAT or \
			ai_action.action_type == aiAction.ACTION_TYPES.COMBAT_AND_MOVE:
		ai_action.owner.unit.set_equipped(ai_action.selected_Weapon)
		await perform_attack(ai_action.owner, ai_action.target, ai_action.combat_action_data)
	
	if ai_action.owner and is_instance_valid(ai_action.owner.map_display):
		ai_action.owner.update_display()


## Gets all AI-controlled enemy units.
## Returns: Array of enemy [CombatUnit] instances.
func get_ai_units() -> Array[CombatUnit]:
	var enemy_unit_array: Array[CombatUnit] = []
	for enemy_unit in groups[Constants.FACTION.ENEMIES]:
		if combatants[enemy_unit]:
			enemy_unit_array.append(combatants[enemy_unit])
	return enemy_unit_array


## Calculates the expected outcome of a combat exchange.
## @param attacker: The attacking [CombatUnit].
## @param defender: The defending [CombatUnit].
## @param data: The [UnitCombatExchangeData] to evaluate.
## Returns: A [UnitCombatActionExpectedOutcome] with calculated values.
func calc_expected_combat_exchange(	attacker: CombatUnit, defender: CombatUnit, data: UnitCombatExchangeData ) -> UnitCombatActionExpectedOutcome:
	var outcome: UnitCombatActionExpectedOutcome = UnitCombatActionExpectedOutcome.new()
	
	for turn in data.exchange_data:
		if turn.owner == attacker:
			var crit_multiplier: float = attacker.get_equipped().critical_multiplier
			var turn_damage: float = (
				(turn.attack_damage * turn.attack_count) *
				(1.0 + turn.critical / 100.0 * crit_multiplier)
			)
			outcome.expected_damage += turn_damage
			outcome.maximum_damage += (
				(turn.attack_damage * turn.attack_count) * crit_multiplier
			)
			if outcome.expected_damage_taken < attacker.unit.hp:
				outcome.expected_damage_before_defeat += turn_damage
		elif turn.owner == defender:
			var crit_multiplier: float = defender.get_equipped().critical_multiplier
			var turn_damage: float = (
				(turn.attack_damage * turn.attack_count) *
				(1.0 + turn.critical / 100.0 * crit_multiplier)
			)
			outcome.expected_damage_taken += turn_damage
	
	if outcome.maximum_damage >= defender.unit.hp:
		outcome.can_lethal = true
	
	return outcome



## Calculates the best attack action for an AI unit.
## @param ai_unit: The AI [CombatUnit].
## @param distance: The distance to the target.
## @param target: The target [CombatUnit].
## @param terrain: The [Terrain] the AI unit is standing on.
## Returns: The best [aiAction] for this situation.
func ai_get_best_attack_action(ai_unit: CombatUnit,	distance: int,	target: CombatUnit,	terrain: Terrain) -> aiAction:
	var best_action: aiAction = aiAction.new()
	var usable_weapons: Array[WeaponDefinition] = ai_unit.unit.get_usable_weapons_at_range(distance)
	
	if usable_weapons.is_empty():
		return best_action
	
	for i in range(usable_weapons.size()):
		ai_unit.unit.set_equipped(usable_weapons[i])
		var action: aiAction = aiAction.new()
		var data: UnitCombatExchangeData = combatExchange.generate_combat_exchange_data(
			ai_unit,
			target,
			distance
		)
		var outcome: UnitCombatActionExpectedOutcome = calc_expected_combat_exchange(
			ai_unit,
			target,
			data
		)
		action.generate_attack_action_rating(
			terrain.avoid / 100.0,
			outcome.attacker_hit_chance,
			outcome.expected_damage,
			target.unit.stats.hp,
			outcome.can_lethal,
			outcome.expected_damage_taken
		)
		action.selected_Weapon = usable_weapons[i]
		action.target = target
		action.action_type = aiAction.ACTION_TYPES.COMBAT
		action.combat_action_data = data
		
		if best_action == null or action.rating > best_action.rating:
			best_action = action
	
	return best_action


## Equips the best weapon for an AI unit attacking a target.
## @param comb: The AI [CombatUnit].
## @param target: The target [CombatUnit].
## @param distance: The distance to the target.
## Returns: The [UnitCombatExchangeData] for the best weapon choice.
func ai_equip_best_weapon(comb: CombatUnit,	target: CombatUnit,	distance: int) -> UnitCombatExchangeData:
	var data: UnitCombatExchangeData
	var usable_weapons: Array[WeaponDefinition] = comb.unit.get_usable_weapons_at_range(
		get_distance(comb, target) ##NOTE is this redundant? Why cant we just use the input distance?
	)
	
	if usable_weapons.is_empty():
		return data
	
	var expected_damage: Array[Vector2] = []
	for i in range(usable_weapons.size()):
		comb.unit.set_equipped(usable_weapons[i])
		data = combatExchange.generate_combat_exchange_data(comb, target, distance)
		var expected_outcome: UnitCombatActionExpectedOutcome = calc_expected_combat_exchange(
			comb,
			target,
			data
		)
		expected_damage.append(Vector2(i, expected_outcome.expected_damage))
	
	expected_damage.sort_custom(_sort_by_y_value)
	comb.unit.set_equipped(usable_weapons[int(expected_damage.front().x)])
	
	return data


# ==============================================================================
# PUBLIC METHODS - DISPLAY & UI
# ==============================================================================

## Updates effective damage indicators for all enemy units.
## @param combatant: The [CombatUnit] to check effectiveness against.
func update_effective_combat_displays(combatant: CombatUnit) -> void:
	for group_index in range(groups.size()):
		if group_index == combatant.allegience:
			continue
		
		for combatant_index in groups[group_index]:
			var enemy: CombatUnit = combatants[combatant_index]
			if not enemy.alive:
				continue
			
			var is_effective: bool = combatExchange.check_unit_can_do_effective_damage(
				enemy.unit,
				combatant.unit
			)
			enemy.map_display.set_is_effective(is_effective)


## Resets all effective damage indicators to off.
func reset_all_effective_indicators() -> void:
	for combatant in combatants:
		if combatant.alive:
			combatant.map_display.set_is_effective(false)


# ==============================================================================
# PUBLIC METHODS - ITEMS & INVENTORY
# ==============================================================================

## Heals a combat unit by the specified amount by calling [CombatExchange].
## @param cu: The [CombatUnit] to heal.
## @param amount: The amount of HP to restore.
func heal_unit(cu: CombatUnit, amount: int) -> void:
	await combatExchange.trigger_heal_unit(cu, amount)


## Gives items to a combat unit.
## @param items: Array of [ItemDefinition] to give.
## @param source: The source identifier (e.g., "combat_entity", "combat_exchange").
## @param target: Optional specific [CombatUnit] target.
func give_curent_unit_items(
	items: Array[ItemDefinition],
	source: String,
	target: CombatUnit = null
) -> void:
	var recipient: CombatUnit = target if target != null else get_current_combatant()
	
	for item in items:
		await combat_unit_item_manager.give_combat_unit_item(recipient, item)
	
	if source == CombatMapConstants.COMBAT_ENTITY:
		entity_manager._on_give_item_complete()
	if source == CombatMapConstants.COMBAT_EXCHANGE:
		combatExchange._on_give_item_complete()


## Sends an item to the convoy storage.
## @param item: The [ItemDefinition] to store.
func convoy_item(item: ItemDefinition) -> void:
	playerOverworldData.convoy.append(item)


## Sends all items from a combat unit's inventory to the convoy.
## @param combat_unit: The [CombatUnit] whose inventory to convoy.
## TODO this function has errors where it doesnt finish returning all items
func convoy_inventory(combat_unit: CombatUnit) -> void:
	for item in combat_unit.unit.inventory.items:
		if item != null:
			combat_unit_item_manager.discard_item(combat_unit, item)

## Creates a UI container for discarding items.
## @param cu: The [CombatUnit] managing inventory.
## @param new_item: The new [ItemDefinition] being added.
func create_unit_item_discard_container(cu: CombatUnit, new_item: ItemDefinition) -> void:
	var inventory_data: Array[UnitInventorySlotData] = (
		combat_unit_item_manager.generate_combat_unit_inventory_data(cu)
	)
	var new_item_slot_data: UnitInventorySlotData = (
		combat_unit_item_manager.generate_combat_unit_inventory_data_for_item(cu, new_item)
	)
	game_ui.create_combat_unit_discard_inventory(cu, inventory_data, new_item_slot_data)


## Handles the selection of an item to discard.
## @param discard_item: The [ItemDefinition] to discard.
## @param cu: The [CombatUnit] discarding the item.
func discard_item_selected(discard_item: ItemDefinition, cu: CombatUnit) -> void:
	game_ui.destory_active_ui_node()
	await combat_unit_item_manager.give_item_discard_result_complete(cu, discard_item)


## Creates a popup showing an item was obtained.
## @param item: The [ItemDefinition] obtained.
func create_item_obtained_pop_up(item: ItemDefinition) -> void:
	await game_ui.create_combat_view_pop_up_item_obtained(item)
	combat_unit_item_manager._on_give_item_popup_completed()


## Creates a popup showing an item was broken.
## @param item: The [ItemDefinition] that broke.
func create_item_broken_pop_up(item: ItemDefinition) -> void:
	await game_ui.create_combat_view_pop_up_item_broken(item)
	await get_tree().create_timer(UI_TRANSITION_DELAY).timeout
	combatExchange._on_item_broken_popup_completed()


## Creates a popup showing an item was expended.
## @param item: The [ItemDefinition] that was expended.
func create_item_expended_pop_up(item: ItemDefinition) -> void:
	await game_ui.create_combat_view_pop_up_expended(item)
	##NOTE why is there no timeout here?
	combatExchange._on_item_expended_popup_completed()


## Creates a popup showing stats were increased. 
## @param item: The [ItemDefinition] that granted stats. ##TODO ENSURE THIS CODE WORKS AS INTENDED
func create_stat_up_pop_up(item: ItemDefinition) -> void:
	await game_ui.create_combat_view_pop_up_stats_increased(item)
	combat_unit_item_manager._on_give_item_popup_completed()


# ==============================================================================
# PUBLIC METHODS - ENTITIES
# ==============================================================================

## Handles entity destruction during combat.
## @param combat_entity: The [CombatEntity] that was destroyed.
func entity_destroyed_combat(combat_entity: CombatEntity) -> void:
	await entity_manager.entity_destroyed(combat_entity)
	combatExchange._on_entity_destroyed_processing_completed()


## Interacts with an entity using an item.
## @param unit: The [CombatUnit] interacting.
## @param use_item: The [ItemDefinition] being used.
## @param entity: The [CombatEntity] being interacted with.
func entity_interact_use_item(
	unit: CombatUnit,
	use_item: ItemDefinition,
	entity: CombatEntity
) -> void:
	entity_processing.emit()
	unit.unit.inventory.use_item(use_item)
	await entity_manager.entity_interacted(entity)


## Interacts with an entity without using an item.
## @param unit: The [CombatUnit] interacting.
## @param entity: The [CombatEntity] being interacted with.
func entity_interact(unit: CombatUnit, entity: CombatEntity) -> void:
	entity_processing.emit()
	entity_manager.entity_interacted(entity)


# ==============================================================================
# PUBLIC METHODS - POST-COMBAT
# ==============================================================================

## Heals all ally units in party to full HP.
func heal_ally_units() -> void:
	for unit: Unit in playerOverworldData.total_party:
		unit.hp = unit.stats.hp


## Refreshes all expended weapons in the party.
func refresh_expended_weapons() -> void:
	for unit: Unit in playerOverworldData.total_party:
		for item: ItemDefinition in unit.inventory.items:
			if item.has_expended_state:
				item.refresh_uses()

## Unlocks new unit types earned from completing the campaign.
func unlock_new_unit_types() -> void:
	var unlocked_units: Array = playerOverworldData.current_campaign.unit_unlock_rewards ##NOTE Should this be changed to UnitTypeDefinition?
	
	for unlocked_unit in unlocked_units:
		var is_unit_type: bool = UnitTypeDatabase.unit_types.has(unlocked_unit.db_key)
		var is_commander: bool = UnitTypeDatabase.commander_types.has(unlocked_unit.db_key)
		
		if is_unit_type and not playerOverworldData.unlock_manager.unit_types_unlocked[unlocked_unit]:
			playerOverworldData.unlock_manager.unit_types_unlocked[unlocked_unit] = true
		elif is_commander and not playerOverworldData.unlock_manager.commander_types_unlocked[unlocked_unit]:
			playerOverworldData.unlock_manager.commander_types_unlocked[unlocked_unit] = true
		
		create_unlock_panel(unlocked_unit)


## Creates an unlock notification panel for a newly unlocked unit type.
## @param unlocked_unit: The [UnitTypeDefinition] that was unlocked.
func create_unlock_panel(unlocked_unit: UnitTypeDefinition) -> void:
	var unlock_panel: UnlockPanel = preload("res://ui/unlock_panel/unlock_panel.tscn").instantiate()
	unlock_panel.unlocked_entity = unlocked_unit
	game_ui.add_child(unlock_panel)
	await get_tree().create_timer(UNLOCK_PANEL_DURATION).timeout
	unlock_panel.queue_free()


## Checks if any tier 1 units are eligible for promotion.
## Returns: [code]true[/code] if a promotion is available.
## TODO Move to prep and battlemaster when impl
func check_tier_1_promotion_available() -> bool:
	for unit: Unit in playerOverworldData.selected_party:
		var unit_type: UnitTypeDefinition = unit.get_unit_type_definition()
		if unit_type.tier == 1 and unit.level >= 10:
			return true
	return false


# ==============================================================================
# PRIVATE METHODS - HELPERS
# ==============================================================================

## Helper to add a generic unit to the tutorial party.
## @param type_key: The unit type database key.
## @param items: Array of items for the unit.
## @param unit_name: Display name for the unit.
## @param level: Starting level for the unit.
func _add_tutorial_unit(type_key: String, items: Array[ItemDefinition], unit_name: String, unit_level: int ) -> void:
	var unit: Unit = Unit.create_generic_unit(type_key, items, unit_name, unit_level)
	playerOverworldData.selected_party.append(unit)


## Sort comparator for sorting by Y value (descending).
## @param a: First [Vector2] to compare.
## @param b: Second [Vector2] to compare.
## Returns: [code]true[/code] if a.y > b.y.
func _sort_by_y_value(a: Vector2, b: Vector2) -> bool:
	return a.y > b.y


## Sort comparator for turn queue based on initiative.
## @param a: First combatant index.
## @param b: Second combatant index.
## Returns: [code]true[/code] if b has lower initiative than a.
func sort_turn_queue(a: int, b: int) -> bool:
	return combatants[b].unit.initiative < combatants[a].unit.initiative


## Sort comparator for weight arrays.
## @param a: First weight entry.
## @param b: Second weight entry.
## Returns: [code]true[/code] if a[0] > b[0].
func sort_weight_array(a: Array, b: Array) -> bool:
	return a[0] > b[0]


# ==============================================================================
# PRIVATE METHODS - SIGNAL HANDLERS
# ==============================================================================

## Handles combat exchange completion.
## @param friendly_unit_alive: Whether the friendly unit survived.
func combatExchangeComplete(friendly_unit_alive: bool) -> void:
	_player_unit_alive = friendly_unit_alive
	major_action_complete()
	
	if check_win():
		combat_win()
	elif check_lose():
		reset_game_state()
		get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")

## Handles unit's major action completion.
func major_action_complete() -> void:
	var current_unit: CombatUnit = get_current_combatant()
	current_unit.minor_action_taken = true
	current_unit.turn_taken = true
	current_unit.minor_action_taken = true
	current_unit.update_display()
	major_action_completed.emit()

## Handles experience gain for a unit.
## @param cu: The [CombatUnit] gaining experience.
## @param value: The amount of experience gained.
func unit_gain_experience(combat_unit: CombatUnit, value: int) -> void:
	await unit_experience_manager.process_experience_gain(combat_unit, value)
	combatExchange.unit_gain_experience_complete()


## Handles audio playback requests.
## @param sound: The [AudioStream] to play.
func play_audio(sound: AudioStream) -> void:
	combat_audio.stream = sound
	combat_audio.play()
	await combat_audio.finished
	combatExchange.audio_player_ready()


## Handles combat entity addition.
## @param cme: The [CombatEntity] that was added.
func _on_combat_entity_added(added_combat_entity: CombatEntity) -> void:
	combat_entity_added.emit(added_combat_entity)


## Handles entity processing completion.
func _on_entity_processing_completed() -> void:
	entity_processing_completed.emit()


## Handles reinforcement spawn requests.
## @param cu: The [CombatUnit] to spawn.
## @param position: The [Vector2i] position to spawn at.
func _on_reinforcement_manager_spawn_reinforcement(cu: CombatUnit, position: Vector2i) -> void:
	if game_grid.is_position_occupied(position):
		var blocking_unit: String = game_grid.get_combat_unit(position).name
		push_warning(
			"Combat: Reinforcement spawn blocked at %s - [%s] already occupies space" % [
				position,
				blocking_unit
			]
		)
		return
	
	if controller.perform_reinforcement_camera_adjustment(position):
		await get_tree().create_timer(REINFORCEMENT_SPAWN_DELAY).timeout
		await add_combatant(cu, position)
		await get_tree().create_timer(REINFORCEMENT_SPAWN_DELAY).timeout
		reinforcement_manager._on_reinforcement_spawn_completed()


## Handles gold reward acquisition.
## @param gold: Amount of gold obtained.
func _on_gold_obtained(gold: int) -> void:
	playerOverworldData.gold += gold


## Handles bonus experience reward acquisition.
## @param bonus_exp: Amount of bonus experience obtained.
func _on_bonus_exp_obtained(bonus_exp: int) -> void:
	playerOverworldData.bonus_experience += bonus_exp

## Handles reward screen completion and routes user to correct next scene.
func _on_rewards_complete():
	if heal_on_win:
		heal_ally_units()
	refresh_expended_weapons()
	
	playerOverworldData.level_entered = false
	playerOverworldData.battle_prep_complete = false
	
	if is_key_campaign_level:
		playerOverworldData.combat_maps_completed += 1
	
	SelectedSaveFile.save(playerOverworldData)
	
	if is_tutorial:
		reset_game_state()
		SelectedSaveFile.save(playerOverworldData)
		get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")
		return
	
	var room_type: int = playerOverworldData.last_room.type
	var is_battle_room: bool = (
		room_type == CampaignRoom.TYPE.KEY_BATTLE or
		room_type == CampaignRoom.TYPE.BATTLE
	)
	
	if is_battle_room:
		playerOverworldData.level_entered = false
		playerOverworldData.current_level = null
		SelectedSaveFile.save(playerOverworldData)
		#Determine if a tier 1 unit needs to be promoted or not
		if check_tier_1_promotion_available():
			get_tree().change_scene_to_packed(preload("res://ui/promotion/promotion.tscn"))
		else:
			get_tree().change_scene_to_packed(preload("res://campaign_map/campaign_map.tscn"))
	else:
		# Final level - record victory and return to main menu
		var win_number = playerOverworldData.hall_of_heroes_manager.latest_win_number + 1
		playerOverworldData.hall_of_heroes_manager.alive_winning_units[win_number] = playerOverworldData.total_party
		playerOverworldData.hall_of_heroes_manager.dead_winning_units[win_number] = playerOverworldData.dead_party_members
		playerOverworldData.hall_of_heroes_manager.winning_campaigns[win_number] = playerOverworldData.current_campaign
		playerOverworldData.hall_of_heroes_manager.latest_win_number += 1
		
		await unlock_new_unit_types()
		reset_game_state()
		SelectedSaveFile.save(playerOverworldData)
		get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")
