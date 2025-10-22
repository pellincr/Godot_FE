extends Control

class_name BattlePrep

signal begin_battle()
signal unit_selected(unit:Unit)
signal unit_deselected(unit:Unit)
signal swap_spaces()
signal award_bonus_exp(unit:CombatUnit,xp:int)

@onready var main_container: VBoxContainer = $MarginContainer/MainContainer

@onready var battle_prep_header: PanelContainer = $MarginContainer/MainContainer/BattlePrepHeader
@onready var header_upper_label: RichTextLabel = $MarginContainer/MainContainer/BattlePrepHeader/VBoxContainer/HeaderUpperLabel
@onready var header_lower_label: Label = $MarginContainer/MainContainer/BattlePrepHeader/VBoxContainer/HeaderLowerLabel

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")
const main_pause_menu_scene = preload("res://ui/main_pause_menu/main_pause_menu.tscn")

var playerOverworldData : PlayerOverworldData #= ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name)#.duplicate(true)

var tutorial_complete := true


enum PREP_STATE{
	MENU,
	UNIT_SELECTION,
	SWAP_SPACES,
	SHOP,
	INVENTORY,
	TRAINING_GROUNDS
}

var current_state := PREP_STATE.MENU
var pause_menu_open = false

func _ready() -> void:
	#transition_in_animation()
	if playerOverworldData.current_campaign.name == "Tutorial" and playerOverworldData.floors_climbed == 1:
		tutorial_complete = false
		var tutorial_panel = preload("res://ui/tutorial/tutorial_panel.tscn").instantiate()
		tutorial_panel.current_state = TutorialPanel.TUTORIAL.BATTLE_PREP
		tutorial_panel.tutorial_completed.connect(tutorial_completed)
		add_child(tutorial_panel)
	else:
		tutorial_completed()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if !pause_menu_open and tutorial_complete and current_state != PREP_STATE.SWAP_SPACES:
			var main_pause_menu = main_pause_menu_scene.instantiate()
			add_child(main_pause_menu)
			main_pause_menu.menu_closed.connect(_on_menu_closed)
			#disable_button_focus()
			pause_menu_open = true
		else:
			if tutorial_complete and current_state != PREP_STATE.SWAP_SPACES:
				get_child(-1).queue_free()
				_on_menu_closed()

func set_po_data(po_data):
	playerOverworldData = po_data

func transition_in_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_out")
	await get_tree().create_timer(.5).timeout
	scene_transition.queue_free()

func transition_out_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5).timeout

func tutorial_completed():
	update_by_state()
	tutorial_complete = true

func update_by_state():
	clear_existing_menus()
	set_header_labels(current_state)
	match current_state:
		PREP_STATE.MENU:
			var hbox_container := HBoxContainer.new()
			var battle_prep_menu = preload("res://ui/battle_prep_new/menu_selection/battle_prep_menu_selection.tscn").instantiate()
			var next_level_info = preload("res://ui/battle_prep_new/next_level_info_panel/next_level_info.tscn").instantiate()
			battle_prep_menu.state_selected.connect(_on_battle_prep_menu_selection_state_selected)
			battle_prep_menu.save_game.connect(_on_save_game)
			battle_prep_menu.start_game.connect(_on_start_game)
			var current_level = playerOverworldData.current_level.instantiate()
			var combat = current_level.get_child(2)
			next_level_info.set_upcoming_enemies(combat.enemy_start_group)
			if combat.entity_manager:
				next_level_info.set_upcoming_entities(combat.entity_manager.mapEntityData)
			hbox_container.add_child(battle_prep_menu)
			hbox_container.add_child(next_level_info)
			main_container.add_child(hbox_container)
			next_level_info.fill_all_containers()
		PREP_STATE.UNIT_SELECTION:
			var unit_selection = preload("res://ui/battle_prep_new/unit_selection/UnitSelection.tscn").instantiate()
			unit_selection.set_po_data(playerOverworldData)
			main_container.add_child(unit_selection)
			unit_selection.return_to_menu.connect(_on_return_to_menu)
			unit_selection.unit_selected.connect(_on_unit_selected)
			unit_selection.unit_deselected.connect(_on_unit_deselected)
		PREP_STATE.SWAP_SPACES:
			swap_spaces.emit()
		PREP_STATE.SHOP:
			var shop = preload("res://ui/battle_prep_new/shop/shop.tscn").instantiate()
			shop.set_po_data(playerOverworldData)
			main_container.add_child(shop)
			shop.return_to_menu.connect(_on_return_to_menu)
		PREP_STATE.INVENTORY:
			var inventory_prep_screen = preload("res://ui/battle_prep_new/inventory/inventory_prep_screen.tscn").instantiate()
			inventory_prep_screen.set_po_data(playerOverworldData)
			inventory_prep_screen.return_to_menu.connect(_on_return_to_menu)
			main_container.add_child(inventory_prep_screen)
		PREP_STATE.TRAINING_GROUNDS:
			var training_ground = preload("res://ui/battle_prep_new/training_grounds/training_grounds.tscn").instantiate()
			training_ground.set_po_data(playerOverworldData)
			main_container.add_child(training_ground)
			training_ground.return_to_menu.connect(_on_return_to_menu)
			training_ground.award_exp.connect(_on_award_exp)

func _on_battle_prep_menu_selection_state_selected(state: PREP_STATE) -> void:
	current_state = state
	update_by_state()

func set_header_labels(state : PREP_STATE) -> void:
	var upper_label_text = ""
	var lower_label_text = ""
	match state:
		PREP_STATE.MENU:
			upper_label_text = "Prepare For Battle!"
			battle_prep_header.visible = true
		PREP_STATE.SWAP_SPACES:
			battle_prep_header.visible = false
		PREP_STATE.UNIT_SELECTION:
			upper_label_text = "Unit Selection"
			lower_label_text = "Select which allies will fight"
		PREP_STATE.SHOP:
			upper_label_text = "Shop"
			lower_label_text = "Buy and Sell Items"
		PREP_STATE.INVENTORY:
			upper_label_text = "Inventory"
			lower_label_text = "Select An Inventory to Update"
		PREP_STATE.TRAINING_GROUNDS:
			upper_label_text = "Training Grounds"
			lower_label_text= "Choose a Unit to Train"
	header_upper_label.text = upper_label_text
	header_lower_label.text = lower_label_text


func clear_existing_menus():
	if current_state != PREP_STATE.MENU:
		if main_container.get_child(1):
			main_container.get_child(1).queue_free()

func _on_return_to_menu():
	current_state = PREP_STATE.MENU
	update_by_state()

func _on_start_game():
	if playerOverworldData.selected_party.size() > 0:
		#playerOverworldData.began_level = true
		#SelectedSaveFile.save(playerOverworldData)
		#transition_out_animation()
		#get_tree().change_scene_to_packed(playerOverworldData.current_level)
		begin_battle.emit()
		queue_free()

func _on_menu_closed():
	pause_menu_open = false
	var open_screen = main_container.get_child(-1)
	match current_state:
		PREP_STATE.MENU:
			var prep_menu = open_screen.get_child(0)
			prep_menu.grab_start_button_focus()
		PREP_STATE.UNIT_SELECTION:
			open_screen.grab_first_army_panel_focus()
		PREP_STATE.SWAP_SPACES:
			pass
		PREP_STATE.SHOP:
			open_screen.update_by_shop_state()
		PREP_STATE.INVENTORY:
			open_screen.update_by_state()

func _on_unit_selected(unit:Unit):
	unit_selected.emit(unit)

func _on_unit_deselected(unit:Unit):
	unit_deselected.emit(unit)

func _on_award_exp(unit:CombatUnit, xp:int):
	award_bonus_exp.emit(unit,xp)

func update_training_grounds_stats():
	if current_state == PREP_STATE.TRAINING_GROUNDS:
		var training_grounds = main_container.get_child(1)
		var unit_level_info = training_grounds.get_child(0)
		unit_level_info.unit.hp = unit_level_info.unit.stats.hp
		unit_level_info.update_by_unit()
		var bonus_exp_spend = training_grounds.get_child(1)
		bonus_exp_spend.update_by_unit()

func _on_save_game():
	SelectedSaveFile.save(playerOverworldData)
