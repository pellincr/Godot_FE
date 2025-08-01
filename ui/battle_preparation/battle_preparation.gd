extends Control

var playerOverworldData : PlayerOverworldData
var save_file_name = "PlayerOverworldSave.tres"

@onready var gold_counter = $MarginContainer/VBoxContainer/GoldCounter
@onready var army_convoy_container = $MarginContainer/VBoxContainer/MainContainer/ArmyConvoyContainer

@onready var main_container = $MarginContainer/VBoxContainer/MainContainer

const unit_detailed_info_scene = preload("res://ui/battle_preparation/unit_detailed_info/unit_detailed_info.tscn")


func _ready():
	load_data()
	army_convoy_container.set_po_data(playerOverworldData)
	army_convoy_container.fill_army_scroll_container()

func _process(delta):
	if Input.is_action_just_pressed("start_game") and playerOverworldData.selected_party.size() > 0:
		save()
		get_tree().change_scene_to_file("res://combat/levels/test_level_1/test_game_1.tscn")

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


func clear_screen():
	var children = main_container.get_children()
	for child_index in children.size():
		if child_index == 0:
			pass
		else:
			children[child_index].queue_free()

func _on_army_convoy_container_unit_focused(unit):
	clear_screen()
	var unit_detailed_info = unit_detailed_info_scene.instantiate()
	unit_detailed_info.unit = unit
	main_container.add_child(unit_detailed_info)
