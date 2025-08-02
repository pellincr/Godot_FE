extends Control

var playerOverworldData : PlayerOverworldData
var save_file_name = "PlayerOverworldSave.tres"

@onready var gold_counter = $MarginContainer/VBoxContainer/GoldCounter
@onready var army_convoy_container = $MarginContainer/VBoxContainer/MainContainer/ArmyConvoyContainer

@onready var main_container = $MarginContainer/VBoxContainer/MainContainer

const unit_detailed_info_scene = preload("res://ui/battle_preparation/unit_detailed_info/unit_detailed_info.tscn")
const unit_detailed_info_simple_scene = preload("res://ui/battle_preparation/unit_detailed_view_simple/unit_detailed_view_simple.tscn")

const weapon_detailed_info_scene = preload("res://ui/battle_preparation/item_detailed_info/weapon_detailed_info.tscn")

const shop_container_scene = preload("res://ui/battle_preparation/shop/shop_container.tscn")

enum PREPARATION_STATE{
	NEUTRAL, TRADE, SHOP
}

@onready var current_prep_state = PREPARATION_STATE.NEUTRAL

@onready var focused_selection
@onready var focused_detailed_view


func _ready():
	load_data()
	army_convoy_container.set_po_data(playerOverworldData)
	army_convoy_container.fill_army_scroll_container()

func _process(delta):
	if Input.is_action_just_pressed("start_game") and playerOverworldData.selected_party.size() > 0:
		save()
		get_tree().change_scene_to_file("res://combat/levels/test_level_1/test_game_1.tscn")
	if Input.is_action_just_pressed("trade_menu"):
		current_prep_state = PREPARATION_STATE.TRADE
		update_army_convoy_container_state()
	
	if Input.is_action_just_pressed("shop"):
		current_prep_state = PREPARATION_STATE.SHOP
		update_army_convoy_container_state()

func save():
	if SelectedSaveFile.verify_save_directory(SelectedSaveFile.selected_save_path):
		DirAccess.make_dir_absolute(SelectedSaveFile.selected_save_path)
	ResourceSaver.save(playerOverworldData,SelectedSaveFile.selected_save_path + save_file_name)
	print("Saved")

func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + save_file_name).duplicate(true)
	#update the gui
	#set_recruit_buttons(recruit_buttons, playerOverworldData.new_recruits)
	#update_manage_party_buttons()
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
				focused_detailed_view = unit_detailed_simple_info
		PREPARATION_STATE.SHOP:
			if focused_selection is Unit:
				var unit_detailed_simple_info = unit_detailed_info_simple_scene.instantiate()
				unit_detailed_simple_info.unit = focused_selection
				army_convoy_container.get_sub_container().add_child(unit_detailed_simple_info)
				focused_detailed_view = unit_detailed_simple_info
			var shop = shop_container_scene.instantiate()
			shop.item_bought.connect(_on_item_bought)
			main_container.add_child(shop)

func _on_army_convoy_container_unit_focused(unit):
	focused_selection = unit
	current_prep_state = PREPARATION_STATE.NEUTRAL
	update_army_convoy_container_state()


func _on_army_convoy_container_header_swapped():
	clear_sub_container()


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
	elif focused_selection is ItemDefinition:
		pass
