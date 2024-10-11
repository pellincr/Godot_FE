extends Control



@onready var main_container = get_node("MainVContainer")
@onready var option_container = get_node("OptionVContainer")
@onready var save_container = get_node("SaveVContainer")

#Save Files
#var save_file = ConfigFile.new()

var save_path_1 = "user://save1.save"
var save_path_2 = "user://save2.save"
var save_path_3 = "user://save3.save"
#var save_file_2 = "res://save2.cfg"
#var save_file_3 = "res://save3.cfg"
@onready var save_1_button = $SaveVContainer/Save1HContainer/Save_Button1 as Button
@onready var save_1_delete_button = $SaveVContainer/Save1HContainer/Delete_Button as Button
@onready var save_2_button = $SaveVContainer/Save2HContainer/Save_Button2 as Button
@onready var save_2_delete_button = $SaveVContainer/Save2HContainer/Delete_Button as Button
@onready var save_3_button = $SaveVContainer/Save3HContainer/Save_Button3 as Button
@onready var save_3_delete_button = $SaveVContainer/Save3HContainer/Delete_Button as Button
var gold = 15


#Create a New Save Slot when one does not already exist
func _create_new_save(save_path) -> void:
	match(save_path):#Set the Save Slot from New to Load
		save_path_1:
			save_1_button.text = save_1_button.text.replace("NEW","LOAD")
			save_1_delete_button.visible = true
		save_path_2:
			save_2_button.text = save_2_button.text.replace("NEW","LOAD")
			save_2_delete_button.visible = true
		save_path_3:
			save_3_button.text = save_3_button.text.replace("NEW","LOAD")
			save_3_delete_button.visible = true
	# -- Save Information Below
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(gold)
	#save_file.set_value("ITEMS", "gold",10)
	#save_file.save(save_slot)

#Load the Data from the existing save file and transition to the overworld
func _load_game(save_path):
	#save_file.get_value("GROUP", "Name")
	get_tree().change_scene_to_file("res://overworld/overworld.tscn")
	SelectedSaveFile.selected_save_path = save_path


#Called when the node enters the scene tree for the first time.
func _ready():
	if FileAccess.file_exists(save_path_1):
		save_1_button.text = save_1_button.text.replace("NEW","LOAD")
		save_1_delete_button.visible = true
	if FileAccess.file_exists(save_path_2):
		save_2_button.text = save_2_button.text.replace("NEW","LOAD")
		save_2_delete_button.visible = true
	if FileAccess.file_exists(save_path_3):
		save_3_button.text = save_3_button.text.replace("NEW","LOAD")
		save_3_delete_button.visible = true

#Quits the Game back to Desktop
func _on_quit_button_pressed():
	get_tree().quit()

#Returns to the Main Menu from one of the sub-menus
func _on_return_button_pressed():
	main_container.visible = true
	option_container.visible = false
	save_container.visible = false

#Opens the Options Menu and Minimizes the Main Menu
func _on_options_button_pressed():
	main_container.visible = false
	option_container.visible = true

#Opens the Save Slot Selection Menu and minimizes the Main Menu
func _on_start_button_pressed():
	main_container.visible = false
	save_container.visible = true

#Navigates to the Overworld for Save Slot 1. If it doesn't exist it will be created.
func _on_save_button_1_pressed():
	#if the save file does not already exist, create a new one
	if !FileAccess.file_exists(save_path_1):
		_create_new_save(save_path_1)
	#otherwise, load the existing files data and move to the overworld scene
	else:
		_load_game(save_path_1)

#Deletes the Save Slot 1 File
func _on_save_slot_1_delete_button_pressed():
	var dir = DirAccess.open("user://")
	dir.remove(save_path_1)
	save_1_delete_button.visible = false
	save_1_button.text = save_1_button.text.replace("LOAD","NEW")

#Navigates to the Overworld for Save Slot 2. If it doesn't exist it will be created.
func _on_save_button_2_pressed():
	#if the save file does not already exist, create a new one
	if !FileAccess.file_exists(save_path_2):
		_create_new_save(save_path_2)
	#otherwise, load the existing files data and move to the overworld scene
	else:
		_load_game(save_path_2)

#Deletes the Save Slot 2 File
func _on_save_slot_2_delete_button_pressed():
	var dir = DirAccess.open("user://")
	dir.remove(save_path_2)
	save_2_delete_button.visible = false
	save_2_button.text = save_2_button.text.replace("LOAD","NEW")

#Navigates to the Overworld for Save Slot 2. If it doesn't exist it will be created.
func _on_save_button_3_pressed():
	#if the save file does not already exist, create a new one
	if !FileAccess.file_exists(save_path_3):
		_create_new_save(save_path_3)
	#otherwise, load the existing files data and move to the overworld scene
	else:
		_load_game(save_path_3)

#Deletes the Save Slot 3 File
func _on_save_slot_3_delete_button_pressed():
	var dir = DirAccess.open("user://")
	dir.remove(save_path_3)
	save_3_delete_button.visible = false
	save_3_button.text = save_3_button.text.replace("LOAD","NEW")
