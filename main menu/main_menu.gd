extends Control



@onready var main_container = get_node("MainVContainer")
@onready var option_container = get_node("OptionVContainer")
@onready var save_container = get_node("SaveVContainer")

#Save Files
var save_file = ConfigFile.new()
var save_file_1 = "res://save1.cfg"
var save_file_2 = "res://save2.cfg"
var save_file_3 = "res://save3.cfg"
@onready var save_1_button = $SaveVContainer/Save1HContainer/Save_Button1 as Button
@onready var save_1_delete_button = $SaveVContainer/Save1HContainer/Delete_Button as Button
@onready var save_2_button = $SaveVContainer/Save2HContainer/Save_Button2 as Button
@onready var save_2_delete_button = $SaveVContainer/Save2HContainer/Delete_Button as Button
@onready var save_3_button = $SaveVContainer/Save3HContainer/Save_Button3 as Button
@onready var save_3_delete_button = $SaveVContainer/Save3HContainer/Delete_Button as Button


#Create a New Save Slot when one does not already exist
func _create_new_save(save_slot) -> void:
	match(save_slot):#Set the Save Slot from New to Load
		save_file_1:
			save_1_button.text = save_1_button.text.replace("NEW","LOAD")
			save_1_delete_button.visible = true
		save_file_2:
			save_2_button.text = save_2_button.text.replace("NEW","LOAD")
			save_2_delete_button.visible = true
		save_file_3:
			save_3_button.text = save_3_button.text.replace("NEW","LOAD")
			save_3_delete_button.visible = true
	# -- Save Information Below
	#save_file.set_value("GROUP", "Name",VALUE)	
	save_file.save(save_slot)

#Load the Data from the existing save file and transition to the overworld
func _load_game(save_file):
	#save_file.get_value("GROUP", "Name")
	get_tree().change_scene_to_file("res://overworld/overworld.tscn")
	SelectedSaveFile.selected_save_file = save_file


#Called when the node enters the scene tree for the first time.
func _ready():
	if save_file.load(save_file_1) == OK:
		save_1_button.text = save_1_button.text.replace("NEW","LOAD")
		save_1_delete_button.visible = true
	if save_file.load(save_file_2) == OK:
		save_2_button.text = save_2_button.text.replace("NEW","LOAD")
		save_2_delete_button.visible = true
	if save_file.load(save_file_3) == OK:
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
	if save_file.load(save_file_1) != OK:
		_create_new_save(save_file_1)
	#otherwise, load the existing files data and move to the overworld scene
	else:
		_load_game(save_file_1)

#Deletes the Save Slot 1 File
func _on_save_slot_1_delete_button_pressed():
	var dir = DirAccess.open("res://")
	dir.remove(save_file_1)
	save_1_delete_button.visible = false
	save_1_button.text = save_1_button.text.replace("LOAD","NEW")

#Navigates to the Overworld for Save Slot 2. If it doesn't exist it will be created.
func _on_save_button_2_pressed():
	#if the save file does not already exist, create a new one
	if save_file.load(save_file_2) != OK:
		_create_new_save(save_file_2)
	#otherwise, load the existing files data and move to the overworld scene
	else:
		_load_game(save_file_2)

#Deletes the Save Slot 2 File
func _on_save_slot_2_delete_button_pressed():
	var dir = DirAccess.open("res://")
	dir.remove(save_file_2)
	save_2_delete_button.visible = false
	save_2_button.text = save_2_button.text.replace("LOAD","NEW")

#Navigates to the Overworld for Save Slot 2. If it doesn't exist it will be created.
func _on_save_button_3_pressed():
	#if the save file does not already exist, create a new one
	if save_file.load(save_file_3) != OK:
		_create_new_save(save_file_3)
	#otherwise, load the existing files data and move to the overworld scene
	else:
		_load_game(save_file_3)

#Deletes the Save Slot 3 File
func _on_save_slot_3_delete_button_pressed():
	var dir = DirAccess.open("res://")
	dir.remove(save_file_3)
	save_3_delete_button.visible = false
	save_3_button.text = save_3_button.text.replace("LOAD","NEW")
