extends Node

var selected_save_path = ""
var save_file_name = "PlayerOverworldSave.tres"



func save(playerOverworldData):
	if !DirAccess.dir_exists_absolute(SelectedSaveFile.selected_save_path):
		DirAccess.make_dir_absolute(SelectedSaveFile.selected_save_path)
	ResourceSaver.save(playerOverworldData,SelectedSaveFile.selected_save_path + save_file_name)
	print("Saved")
