extends Control

signal adventure_begun()
const overworld_scene = "res://overworld_new/overworld.tscn"
var playerOverworldData : PlayerOverworldData
var save_file_name = "PlayerOverworldSave.tres"

func _ready():
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	save()

func save():
	if SelectedSaveFile.verify_save_directory(SelectedSaveFile.selected_save_path):
		DirAccess.make_dir_absolute(SelectedSaveFile.selected_save_path)
	var save_location = SelectedSaveFile.selected_save_path + save_file_name
	ResourceSaver.save(playerOverworldData,save_location)
	print("Saved")

func set_player_overworld_data(po_data):
	playerOverworldData = po_data

func _on_begin_adventure_button_pressed():
	var overworld = preload(overworld_scene)
	overworld.instantiate().set_po_data(playerOverworldData)
	get_tree().change_scene_to_packed(overworld)
	#adventure_begun.emit()
	#queue_free()

#Returns to the main menu scene from the selected save
func _on_return_to_start_button_pressed():
	get_tree().change_scene_to_file("res://Game Start Screen/start_screen.tscn")
	SelectedSaveFile.selected_save_path = ""
