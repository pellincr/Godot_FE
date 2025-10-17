extends Control

signal turn_ended()
signal unit_experience_ended()

@export var combat: Combat
@export var controller: CController
@export var ui_map_audio : AudioStreamPlayer
@export var ui_menu_audio : AudioStreamPlayer

var ui_node_stack : Stack = Stack.new()
#@export var active_ui_node : Node
@onready var unit_status: UnitSelectedFooterUI = $UnitStatus
@onready var combat_tile_info: VBoxContainer = $combat_tile_info

@onready var level_info_container: HBoxContainer = $LevelInfoContainer
@onready var battle_prep: BattlePrep = $BattlePrep


#Scene Imports
#Menu
const COMBAT_MAP_MENU = preload("res://ui/combat/combat_map_menu/combat_map_menu.tscn")
const COMBAT_MAP_CAMPAIGN_MENU = preload("res://ui/combat/combat_map_menu/combat_map_campaign_menu.tscn")
# Detail Menu
const UNIT_DETAILED_INFO_COMBAT_MAP = preload("res://ui/combat/unit_detailed_info_combat_map/unit_detailed_info_combat_map.tscn")

#Combat Action
const ATTACK_ACTION_INVENTORY = preload("res://ui/combat/attack_action_inventory/attack_action_inventory.tscn")
const UNIT_COMBAT_EXCHANGE_PREVIEW = preload("res://ui/combat/combat_exchange_preview/unit_combat_exchange_preview.tscn")

#Support Action
const SUPPORT_ACTION_INVENTORY = preload("res://ui/combat/support_action_inventory/support_action_inventory.tscn")
const UNIT_SUPPORT_EXCHANGE_PREVIEW = preload("res://ui/combat/support_exchange_preview/unit_support_exchange_preview.tscn")

#Inventory Action
const COMBAT_UNIT_INVENTORY = preload("res://ui/combat/unit_inventory/combat_unit_inventory.tscn")
const COMBAT_UNIT_INVENTORY_SELECTED_ITEM_OPTIONS = preload("res://ui/combat/unit_inventory/combat_unit_inventory_selected_item_options.tscn")

#Trade Action
#const tradeContainer = preload("res://ui/combat/unit_trade/trade_container.tscn")
const inventoryOptionsContainer = preload("res://ui/combat/option_container/inventory_options_container.tscn")
const UnitActionContainer = preload("res://ui/combat/unit_action_container/unit_action_container.tscn")

#Item Discard & Popup
const COMBAT_VIEW_POP_UP = preload("res://ui/shared/pop_up/combat_view_pop_up.tscn")
const DISCARD_ITEM_SELECTED = preload("res://ui/combat/discard_action_inventory_new/discard_item_selected.tscn")
const DISCARD_ACTION_INVENTORY = preload("res://ui/combat/discard_action_inventory_new/discard_action_inventory.tscn")

#Interact
const COMBAT_UNIT_INTERACT_ACTION_INVENTORY = preload("res://ui/combat/unit_interact_inventory/combat_unit_interact_action_inventory.tscn")

#Audio imports
const menu_back_sound = preload("res://resources/sounds/ui/menu_back.wav")
const menu_confirm_sound = preload("res://resources/sounds/ui/menu_confirm.wav")
const cursor_sound = preload("res://resources/sounds/ui/menu_cursor.wav")

#transition
const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

const turn_transition_scene = preload("res://scene_transitions/TurnTransitionAnimation.tscn")

var tutorial_panel = preload("res://ui/tutorial/tutorial_panel.tscn").instantiate()

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres")#.duplicate(true)

func _ready():
	#transition_in_animation()
	#battle_prep.set_po_data(playerOverworldData)
	#display_turn_transition_scene(CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN)
	ui_map_audio = $UIMapAudio
	ui_menu_audio = $UIMenuAudio
	#signal wiring
	#set_level_info_container
	level_info_container.set_objective_label(get_objective_text(combat.victory_condition))
	level_info_container.set_turn_count_label(str(combat.current_turn))

func set_po_data(po_data):
	playerOverworldData = po_data
#
# Plays the transition animation on combat map begin
#
func transition_in_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	if playerOverworldData.current_campaign:
		scene_transition.set_upper_label_text(playerOverworldData.current_campaign.name + " - Floor " + str(playerOverworldData.floors_climbed))
		scene_transition.set_middle_label_text("Objective")
		scene_transition.set_lower_label_text(get_objective_text(combat.victory_condition))
	else:
		show_tutorial_panel(scene_transition, playerOverworldData.current_level)
	scene_transition.play_animation("level_fade_out")
	await get_tree().create_timer(5).timeout
	scene_transition.queue_free()

#
# transitions out the animation played on combat map begin
#
func transition_out_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5).timeout

func get_objective_text(victory_condition:Constants.VICTORY_CONDITION) -> String:
	var objective_text := ""
	match victory_condition:
		Constants.VICTORY_CONDITION.DEFEAT_ALL:
			objective_text = "Defeat All Enemies"
		Constants.VICTORY_CONDITION.DEFEAT_BOSS:
			var boss_names = get_all_boss_names()
			objective_text = "Defeat : " + boss_names
		Constants.VICTORY_CONDITION.CAPTURE_TILE:
			objective_text = "Capture the Landmark"
		Constants.VICTORY_CONDITION.DEFEND_TILE:
			objective_text = "Defend Tile"
		Constants.VICTORY_CONDITION.SURVIVE_TURNS:
			objective_text = "Survive " + str(combat.turns_to_survive) + " Turns"
	return objective_text

func get_all_boss_names():
	var enemies = combat.groups[1]
	var boss_names = ""
	for enemy in enemies:
		var enemy_unit : CombatUnit = combat.combatants[enemy]
		if enemy_unit.is_boss:
			if boss_names.length() > 0:
				boss_names =  boss_names + ", " + enemy_unit.unit.name
			else :
				boss_names =  boss_names + enemy_unit.unit.name
	return boss_names

func show_tutorial_panel(scene_transition, current_level:PackedScene):
	match combat.tutorial_level:
		TutorialPanel.TUTORIAL.MUNDANE_WEAPONS:
			scene_transition.set_upper_label_text("Mundane Tutorial")
		TutorialPanel.TUTORIAL.MAGIC_WEAPONS:
			scene_transition.set_upper_label_text("Magic Tutorial")
		TutorialPanel.TUTORIAL.WEAPON_CYCLE:
			scene_transition.set_upper_label_text("Weapon Cycle Tutorial")
		TutorialPanel.TUTORIAL.WEAPON_EFFECTIVENESS:
			scene_transition.set_upper_label_text("Weapon Effectiveness Tutorial")
		TutorialPanel.TUTORIAL.SUPPORT_ACTIONS:
			scene_transition.set_upper_label_text("Support Actions Tutorial")
		TutorialPanel.TUTORIAL.STAFFS:
			scene_transition.set_upper_label_text("Staffs Tutorial")
		TutorialPanel.TUTORIAL.BANNERS:
			scene_transition.set_upper_label_text("Banners Tutorial")
		TutorialPanel.TUTORIAL.TERRAIN:
			scene_transition.set_upper_label_text("Terrain Tutorial")
		TutorialPanel.TUTORIAL.MAP_ENTITY:
			scene_transition.set_upper_label_text("Map Entity Tutorial")
		TutorialPanel.TUTORIAL.DEFEAT_ALL_ENEMIES:
			scene_transition.set_upper_label_text("Defeat All Enemies Tutorial")
		TutorialPanel.TUTORIAL.SIEZE_LANDMARK:
			scene_transition.set_upper_label_text("Sieze Landmark Tutorial")
		TutorialPanel.TUTORIAL.DEFEAT_BOSSES:
			scene_transition.set_upper_label_text("Defeat Bosses Tutorial")
		TutorialPanel.TUTORIAL.SURVIVE_TURNS:
			scene_transition.set_upper_label_text("Survive Turns Tutorial")
	tutorial_panel.current_state = combat.tutorial_level
	add_child(tutorial_panel)
	tutorial_panel.tutorial_completed.connect(tutorial_complete)

func tutorial_complete():
	print("Tutorial Complete")

#
# Creates the unit action container
#
func create_unit_action_container(available_actions:Array[String]):
	var unit_action_container = UnitActionContainer.instantiate()
	unit_action_container.populate(available_actions, controller)
	self.add_child(unit_action_container)
	push_ui_node_stack(unit_action_container)
	unit_action_container.grab_focus()

#
# Creates the combat map game menu screen
#
func create_combat_map_game_menu():
	var game_menu = COMBAT_MAP_CAMPAIGN_MENU.instantiate()
	await game_menu
	self.add_child(game_menu)
	game_menu.end_turn_btn.pressed.connect(func():controller.fsm_game_menu_end_turn())
	game_menu.main_menu_btn.pressed.connect(func (): controller.fsm_game_menu_main_menu())
	game_menu.cancel_btn.pressed.connect(func():controller.fsm_game_menu_cancel())
	push_ui_node_stack(game_menu)

#
# Frees the current node stored in the "active_ui_node" used in state transitions
#
func destory_active_ui_node():
	if get_active_ui_node() != null:
		var node_to_free = ui_node_stack.pop()
		node_to_free.queue_free()

#
# Frees the current node stored in the "active_ui_node" used in state transitions
#
func destory_all_active_ui_nodes_in_stack():
	while ui_node_stack.get_size() > 0:
		var node_to_free = ui_node_stack.pop()
		node_to_free.queue_free()

func flush_stack():
	ui_node_stack.flush()

func push_ui_node_stack(new_node : Node):
	ui_node_stack.push(new_node)

func get_active_ui_node()-> Node:
	return ui_node_stack.peek()

## OLD
func target_selected(info: Dictionary):  ##OLD
	populate_combat_info(info)
	
func populate_combat_info(info: Dictionary): ##OLD
	var attacker_info_name= $Actions/CombatInfo/Container/ActionsGrid/AttackerInfo/Name
	attacker_info_name.text = info.attacker_name
	##populate attack stats
	$Actions/CombatInfo/Container/ActionsGrid/AttackerStats/HP.text = info.attacker_hp
	$Actions/CombatInfo/Container/ActionsGrid/AttackerStats/Damage.text = info.attacker_damage
	$Actions/CombatInfo/Container/ActionsGrid/AttackerStats/Hit.text = info.attacker_hit_chance
	##populate defender stats
	$Actions/CombatInfo/Container/ActionsGrid/DefenderStats/HP.text = info.defender_hp
	$Actions/CombatInfo/Container/ActionsGrid/DefenderStats/Damage.text = info.defender_damage
	$Actions/CombatInfo/Container/ActionsGrid/DefenderStats/Hit.text = info.defender_hit_chance

func _on_end_turn_button_pressed(): ##OLD
	print("End Turn Button pressed")
	turn_ended.emit()

#
# Creates the attack action inventory used to select the weapon to be used in the combat preview
#
func create_attack_action_inventory(inputCombatUnit : CombatUnit, inventory: Array[UnitInventorySlotData]):
	var attack_action_inventory = ATTACK_ACTION_INVENTORY.instantiate()
	self.add_child(attack_action_inventory)
	await attack_action_inventory
	attack_action_inventory.item_selected.connect(controller.fsm_attack_action_inventory_confirm.bind())
	attack_action_inventory.new_item_hovered.connect(controller.fsm_attack_action_inventory_confirm_new_hover.bind())
	#TO BE CONNECTED CANCEL
	attack_action_inventory.populate(inputCombatUnit, inventory)
	push_ui_node_stack(attack_action_inventory)
	attack_action_inventory.grab_focus()

#
# Creates the attack action inventory used to select the weapon to be used in the combat preview
#
func create_support_action_inventory(inputCombatUnit : CombatUnit, inventory: Array[UnitInventorySlotData]):
	var support_action_inventory = SUPPORT_ACTION_INVENTORY.instantiate()
	self.add_child(support_action_inventory)
	await support_action_inventory
	support_action_inventory.item_selected.connect(controller.fsm_support_action_inventory_confirm.bind())
	support_action_inventory.new_item_hovered.connect(controller.fsm_support_action_inventory_confirm_new_hover.bind())
	#TO BE CONNECTED CANCEL
	support_action_inventory.populate(inputCombatUnit, inventory)
	push_ui_node_stack(support_action_inventory)
	support_action_inventory.grab_focus()

#
#
#
func create_attack_action_combat_exchange_preview(exchange_info: UnitCombatExchangeData, weapon_swap_visable: bool = false):
	var combat_exchange_preview = UNIT_COMBAT_EXCHANGE_PREVIEW.instantiate()
	self.add_child(combat_exchange_preview)
	await combat_exchange_preview
	combat_exchange_preview.set_all(exchange_info,weapon_swap_visable)
	push_ui_node_stack(combat_exchange_preview)
	combat_exchange_preview.grab_focus()

#
#
#
func create_attack_action_combat_exchange_preview_entity(exchange_info: UnitCombatExchangeData, target_entity: CombatEntity,weapon_swap_visable : bool = false):
	var combat_exchange_preview = UNIT_COMBAT_EXCHANGE_PREVIEW.instantiate()
	self.add_child(combat_exchange_preview)
	await combat_exchange_preview
	combat_exchange_preview.set_all_entity(exchange_info,target_entity,weapon_swap_visable)
	push_ui_node_stack(combat_exchange_preview)
	combat_exchange_preview.grab_focus()

func update_weapon_attack_action_combat_exchange_preview(exchange_info: UnitCombatExchangeData, weapon_swap_visable: bool = false):
	var active_ui_node = ui_node_stack.peek()
	if  active_ui_node is UnitCombatExchangePreview:
		active_ui_node.set_all(exchange_info,weapon_swap_visable)

func update_weapon_attack_action_combat_exchange_preview_entity(exchange_info: UnitCombatExchangeData, target_entity: CombatEntity, weapon_swap_visable: bool = false):
	var active_ui_node = ui_node_stack.peek()
	if  active_ui_node is UnitCombatExchangePreview:
		active_ui_node.set_all_entity(exchange_info,target_entity,weapon_swap_visable)
#
#
#
func create_support_action_exchange_preview(exchange_info: UnitSupportExchangeData, weapon_swap_visable: bool = false):
	var support_exchange_preview = UNIT_SUPPORT_EXCHANGE_PREVIEW.instantiate()
	self.add_child(support_exchange_preview)
	await support_exchange_preview
	support_exchange_preview.set_all(exchange_info,weapon_swap_visable)
	push_ui_node_stack(support_exchange_preview)
	support_exchange_preview.grab_focus()

func update_support_action_exchange_preview(exchange_info: UnitSupportExchangeData, weapon_swap_visable: bool = false):
	var active_ui_node = ui_node_stack.peek()
	if active_ui_node is UnitSupportExchangePreview:
		active_ui_node.set_all(exchange_info,weapon_swap_visable)


func create_unit_item_action_inventory(inputCombatUnit : CombatUnit, inventory: Array[UnitInventorySlotData]):
	var combat_unit_inventory = COMBAT_UNIT_INVENTORY.instantiate()
	self.add_child(combat_unit_inventory)
	await combat_unit_inventory
	combat_unit_inventory.populate(inputCombatUnit, inventory)
	combat_unit_inventory.item_data_selected.connect(controller.fsm_unit_inventory_item_selected.bind())
	combat_unit_inventory.new_item_hovered.connect(controller.fsm_attack_action_inventory_confirm_new_hover.bind())
	#TO BE CONNECTED CANCEL
	
	push_ui_node_stack(combat_unit_inventory)
	combat_unit_inventory.grab_focus()

func update_unit_item_action_inventory(inputCombatUnit : CombatUnit, inventory: Array[UnitInventorySlotData]):
	var active_ui_node = ui_node_stack.peek()
	if active_ui_node is CombatUnitInventoryDisplay:
		active_ui_node.populate(inputCombatUnit, inventory)
		active_ui_node.re_grab_focus()

func create_unit_inventory_action_item_selected_menu(data:UnitInventorySlotData):
	var inventory_options = COMBAT_UNIT_INVENTORY_SELECTED_ITEM_OPTIONS.instantiate()
	self.add_child(inventory_options)
	inventory_options.popualate(data.item, data.equipped, data.can_use, data.can_arrange)
	await inventory_options
	inventory_options.equip.connect(controller.fsm_unit_inventory_equip.bind())
	inventory_options.use.connect(controller.fsm_unit_inventory_use.bind())
	inventory_options.unequip.connect(controller.fsm_unit_inventory_un_equip.bind())
	inventory_options.arrange.connect(controller.fsm_unit_inventory_arrange.bind())
	inventory_options.discard.connect(controller.fsm_unit_inventory_discard.bind())
	push_ui_node_stack(inventory_options)
	inventory_options.grab_focus_btn()
	

#
# Populates and displayes the detailed info for a combat unit
#
func create_combat_unit_detail_panel(combat_unit: CombatUnit):
	var unit_detailed_info_combat_map = UNIT_DETAILED_INFO_COMBAT_MAP.instantiate()
	self.add_child(unit_detailed_info_combat_map)
	await unit_detailed_info_combat_map
	unit_detailed_info_combat_map.unit = combat_unit
	unit_detailed_info_combat_map.update_by_unit()
	push_ui_node_stack(unit_detailed_info_combat_map)
	
#
# Populates and displayes the detailed info for a combat unit
#
func update_combat_unit_detail_panel(combat_unit: CombatUnit):
	var active_ui_node = ui_node_stack.peek()
	active_ui_node.unit = combat_unit
	active_ui_node.update_by_unit()
	
#
#
#
func _set_tile_info(tile : CombatMapTile, unit:CombatUnit) :
	$combat_tile_info.update_tile(tile)
	if(unit):
		$UnitStatus.set_unit(tile.unit)
		#$UnitStatus.visible = true
	else:
		pass
		#$UnitStatus.visible = false

func display_unit_status():
	$UnitStatus.visible = true

func hide_unit_status():
	$UnitStatus.visible = false

func display_unit_experience_bar(u : Unit):
	$unit_experience_bar.set_reference_unit(u)
	$unit_experience_bar.visible = true

func unit_experience_bar_gain(value: int):
	$unit_experience_bar.update_xp(value)
	await $unit_experience_bar.finished
	hide_unit_experience_bar()
	emit_signal("unit_experience_ended")

#
#
#
func hide_unit_experience_bar():
	$unit_experience_bar.visible = false

#
# Calls play_audio with parameters to play the cursor, or move sound in menus
#
func play_cursor():
	play_audio(cursor_sound, ui_map_audio)

#
# Calls play_audio with parameters to play the confirm sound
#
func play_menu_confirm():
	play_audio(menu_confirm_sound, ui_menu_audio)

#
# Calls play_audio with parameters to play the back or cancel sound
#
#
func play_menu_back():
	play_audio(menu_back_sound, ui_menu_audio)

#
# Used to play audio in ui components
#
func play_audio(sound : AudioStream, audio_source: AudioStreamPlayer):
	audio_source.stream = sound
	audio_source.play()
	await audio_source.finished

#
# @Signal 
# emits unit_experience_ended after unit experience bar animation is complete
#
func _on_unit_experience_bar_finished() -> void:
	hide_unit_experience_bar()
	emit_signal("unit_experience_ended")

func create_combat_unit_discard_inventory(unit: CombatUnit, inventory: Array[UnitInventorySlotData], new_item:UnitInventorySlotData):
	var discard_container = DISCARD_ACTION_INVENTORY.instantiate()
	self.add_child(discard_container)
	await discard_container
	discard_container.item_selected.connect(combat.discard_item_selected.bind(unit))
	discard_container.populate(unit, inventory, new_item)
	push_ui_node_stack(discard_container)
	discard_container.grab_focus_btn()

func create_item_obtained_pop_up(item:ItemDefinition):
	var _pop_up = COMBAT_VIEW_POP_UP.instantiate()
	await _pop_up
	self.add_child(_pop_up)
	_pop_up.set_item(item)
	_pop_up.visible = true
	await get_tree().create_timer(1).timeout
	_pop_up.queue_free()

#
# Creates the attack action inventory used to select the weapon to be used in the combat preview
#
func create_interact_action_inventory(inputCombatUnit : CombatUnit, inventory: Array[UnitInventorySlotData]):
	var interact_action_inventory = COMBAT_UNIT_INTERACT_ACTION_INVENTORY.instantiate()
	self.add_child(interact_action_inventory)
	await interact_action_inventory
	interact_action_inventory.item_selected.connect(controller.fsm_interact_action_inventory_confirm.bind())
	#TO BE CONNECTED CANCEL
	interact_action_inventory.populate(inputCombatUnit, inventory)
	push_ui_node_stack(interact_action_inventory)
	interact_action_inventory.grab_focus()
	
func display_turn_transition_scene(state:CombatMapConstants.COMBAT_MAP_STATE):
	var turn_transition = turn_transition_scene.instantiate()
	self.add_child(turn_transition)
	match state:
		CombatMapConstants.COMBAT_MAP_STATE.PLAYER_TURN:
			turn_transition.set_label("Player Turn")
			turn_transition.set_texture_hue(Color.BLUE)
		CombatMapConstants.COMBAT_MAP_STATE.AI_TURN:
			turn_transition.set_label("Enemy Turn")
			turn_transition.set_texture_hue(Color.RED)
	turn_transition.play_animation("new_turn")
	await turn_transition.animation_player.animation_finished
	turn_transition.queue_free()

func set_turn_count_label(turn_count):
	level_info_container.set_turn_count_label(str(turn_count))


func _on_battle_prep_swap_spaces() -> void:
	combat_tile_info.visible = true
	level_info_container.visible = true
	controller._on_swap_unit_spaces()
	#swap_unit_spaces.emit(

func return_to_battle_prep_screen():
	combat_tile_info.visible = false
	level_info_container.visible = false
	battle_prep.current_state = BattlePrep.PREP_STATE.MENU
	battle_prep.update_by_state()


func _on_battle_prep_begin_battle() -> void:
	controller._on_battle_prep_start_battle()
	combat_tile_info.visible = true
	level_info_container.visible = true


func _on_battle_prep_unit_deselected(unit: Unit) -> void:
	combat.remove_friendly_combatant(unit)


func _on_battle_prep_unit_selected(unit: Unit) -> void:
	combat.add_combatant(combat.create_combatant_unit(unit,0),combat.get_first_available_unit_spawn_tile())
