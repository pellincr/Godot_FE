extends Control

var playerOverworldData : PlayerOverworldData

@onready var gold_counter = $MarginContainer/VBoxContainer/GoldCounter
@onready var army_convoy_container = $MarginContainer/VBoxContainer/MainContainer/ArmyConvoyContainer

@onready var main_container = $MarginContainer/VBoxContainer/MainContainer

const unit_detailed_info_scene = preload("res://ui/battle_preparation/unit_detailed_info/unit_detailed_info.tscn")
const unit_detailed_info_simple_scene = preload("res://ui/battle_preparation/unit_detailed_view_simple/unit_detailed_view_simple.tscn")

const weapon_detailed_info_scene = preload("res://ui/battle_preparation/item_detailed_info/weapon_detailed_info.tscn")

const shop_container_scene = preload("res://ui/battle_preparation/shop/shop_container.tscn")

const trade_container_scene = preload("res://ui/battle_preparation/trade_container/trade_container.tscn")

enum PREPARATION_STATE{
	NEUTRAL, TRADE, SHOP
}

@onready var current_prep_state = PREPARATION_STATE.NEUTRAL

@onready var focused_selection
@onready var focused_detailed_view

@onready var current_trade_detailed_view

@onready var current_trade_item = 1
@onready var trade_item_1 : ItemDefinition
@onready var trade_unit_1 : Unit
@onready var trade_item_2 : ItemDefinition
@onready var trade_unit_2 : Unit

func _ready():
	load_data()
	playerOverworldData.selected_party = []
	army_convoy_container.set_po_data(playerOverworldData)
	army_convoy_container.fill_army_scroll_container()

func _process(delta):
	if Input.is_action_just_pressed("start_game") and playerOverworldData.selected_party.size() > 0:
		playerOverworldData.began_level = true
		SelectedSaveFile.save(playerOverworldData)
		get_tree().change_scene_to_packed(playerOverworldData.current_campaign.levels[playerOverworldData.current_level])
	if Input.is_action_just_pressed("trade_menu") and current_prep_state != PREPARATION_STATE.TRADE:
		current_prep_state = PREPARATION_STATE.TRADE
		update_army_convoy_container_state()
	
	if Input.is_action_just_pressed("shop") and current_prep_state != PREPARATION_STATE.SHOP:
		current_prep_state = PREPARATION_STATE.SHOP
		update_army_convoy_container_state()

func set_po_data(po_data):
	playerOverworldData = po_data

func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)
	print("Loaded")

func clear_sub_container():
	var children = army_convoy_container.get_sub_container().get_children()
	for child_index in children.size():
		if child_index == 0:
			pass
		else:
			children[child_index].queue_free()

func clear_main_contianer():
	var children = main_container.get_children()
	for child_index in children.size():
		if child_index == 0:
			pass
		else:
			children[child_index].queue_free()

func update_army_convoy_container_state():
	clear_main_contianer()
	clear_sub_container()
	match current_prep_state:
		PREPARATION_STATE.NEUTRAL:
			open_detailed_selection_view()
		PREPARATION_STATE.TRADE:
			if focused_selection is Unit:
				var unit_detailed_simple_info = unit_detailed_info_simple_scene.instantiate()
				unit_detailed_simple_info.unit = focused_selection
				army_convoy_container.get_sub_container().add_child(unit_detailed_simple_info)
				unit_detailed_simple_info.set_trade_item.connect(set_trade_item)
				focused_detailed_view = unit_detailed_simple_info
			elif focused_selection is ItemDefinition:
				var weapon_deatailed_info = weapon_detailed_info_scene.instantiate()
				weapon_deatailed_info.item = focused_selection
				army_convoy_container.get_sub_container().add_child(weapon_deatailed_info)
				weapon_deatailed_info.update_by_item()
				focused_detailed_view = weapon_deatailed_info
				trade_item_1 = focused_selection
				trade_unit_1 = null
				current_trade_item = 2
			var trade_container = trade_container_scene.instantiate()
			trade_container.set_po_data(playerOverworldData)
			trade_container.set_trade_item.connect(set_trade_item)
			trade_container.unit_focused.connect(set_trade_detailed)
			main_container.add_child(trade_container)
		PREPARATION_STATE.SHOP:
			if focused_selection is Unit:
				var unit_detailed_simple_info = unit_detailed_info_simple_scene.instantiate()
				unit_detailed_simple_info.unit = focused_selection
				army_convoy_container.get_sub_container().add_child(unit_detailed_simple_info)
				unit_detailed_simple_info.no_trading()
				#unit_detailed_simple_info.set_trade_item.connect(set_trade_item_1) THIS ISN'T NEEDED IN SHOP TECHNICALLY
				focused_detailed_view = unit_detailed_simple_info
			var shop = shop_container_scene.instantiate()
			shop.item_bought.connect(_on_item_bought)
			main_container.add_child(shop)

func _on_army_convoy_container_unit_focused(unit):
	focused_selection = unit
	current_prep_state = PREPARATION_STATE.NEUTRAL
	update_army_convoy_container_state()
	trade_item_1 = null
	trade_unit_1 = null


func _on_army_convoy_container_header_swapped():
	clear_sub_container()
	focused_detailed_view = null
	focused_selection = null
	#update_army_convoy_container_state()


func _on_army_convoy_container_item_focused(item):
	focused_selection = item
	current_prep_state = PREPARATION_STATE.NEUTRAL
	update_army_convoy_container_state()

func open_detailed_selection_view():
	if focused_selection is Unit:
		var unit_detailed_info = unit_detailed_info_scene.instantiate()
		unit_detailed_info.unit = focused_selection
		army_convoy_container.get_sub_container().add_child(unit_detailed_info)
	elif focused_selection is ItemDefinition:
		var item_detailed_info = weapon_detailed_info_scene.instantiate()
		item_detailed_info.item = focused_selection
		army_convoy_container.get_sub_container().add_child(item_detailed_info)
		item_detailed_info.update_by_item()

func _on_item_bought(item):
	if focused_selection is Unit:
		focused_selection.inventory.give_item(item)
		focused_detailed_view.update_by_unit()
	#elif focused_selection is ItemDefinition:
	else:
		playerOverworldData.append_to_array(playerOverworldData.convoy, item)
		army_convoy_container.clear_scroll_scontainer()
		army_convoy_container.fill_convoy_scroll_container()

func set_trade_detailed(detailed_view):
	current_trade_detailed_view = detailed_view

func set_trade_item(item,unit):
	match current_trade_item:
		1:
			trade_item_1 = item
			trade_unit_1 = unit
			current_trade_item = 2
		2:
			trade_item_2 = item
			trade_unit_2 = unit
			if trade_unit_1:
				swap_trade_items()
			else:
				swap_convoy_to_unit_items()
			current_trade_item = 1

func swap_trade_items():
	var inventory_1 = trade_unit_1.inventory
	var inventory_2 = trade_unit_2.inventory
	var item_1_index = inventory_1.items.find(trade_item_1)
	var item_2_index = inventory_2.items.find(trade_item_2)
	inventory_1.discard_item(trade_item_1)
	inventory_1.give_item(trade_item_2)
	inventory_2.discard_item(trade_item_2)
	inventory_2.give_item(trade_item_1)
	trade_item_1 = null
	trade_item_2 = null
	focused_detailed_view.update_by_unit()
	current_trade_detailed_view.update_by_unit()
	clear_sub_container()

func swap_convoy_to_unit_items():
	var unit_inventory = trade_unit_2.inventory
	unit_inventory.give_item(trade_item_1)
	playerOverworldData.convoy.erase(trade_item_1)
	playerOverworldData.convoy.append(trade_item_2)
	unit_inventory.discard_item(trade_item_2)
	army_convoy_container.clear_scroll_scontainer()
	army_convoy_container.fill_convoy_scroll_container()
	current_trade_detailed_view.update_by_unit()
