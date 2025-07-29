extends Control

signal adventure_begun()
const draft_scene = "res://unit drafting/Unit_Commander Draft/army_drafting.tscn"
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
	var army_draft = preload(draft_scene)
	var test = army_draft.instantiate()
	test.set_player_overworld_data(playerOverworldData)
	get_tree().change_scene_to_packed(army_draft)
	#adventure_begun.emit()
	#queue_free()

#Returns to the main menu scene from the selected save
func _on_return_to_start_button_pressed():
	get_tree().change_scene_to_file("res://Game Start Screen/start_screen.tscn")
	SelectedSaveFile.selected_save_path = ""
