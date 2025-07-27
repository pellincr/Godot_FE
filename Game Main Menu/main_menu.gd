extends Control

signal adventure_begun()

func _on_begin_adventure_button_pressed():
	#get_tree().change_scene_to_file("res://unit drafting/unit_drafting.tscn")
	adventure_begun.emit()
	queue_free()

#Returns to the main menu scene from the selected save
func _on_return_to_start_button_pressed():
	get_tree().change_scene_to_file("res://Game Start Screen/start_screen.tscn")
	SelectedSaveFile.selected_save_path = ""
