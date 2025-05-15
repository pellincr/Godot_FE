extends Node

var selected_save_path = ""


func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)
