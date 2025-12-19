extends Control

signal menu_back()
signal save_entered()

@onready var save_button_1: GeneralMenuButton = $MainContainer/Save1Container/SaveButton1
@onready var delete_button_1: GeneralMenuButton = $MainContainer/Save1Container/DeleteButton1
@onready var save_button_2: GeneralMenuButton = $MainContainer/Save2Container/SaveButton2
@onready var delete_button_2: GeneralMenuButton = $MainContainer/Save2Container/DeleteButton2
@onready var save_button_3: GeneralMenuButton = $MainContainer/Save3Container/SaveButton3
@onready var delete_button_3: GeneralMenuButton = $MainContainer/Save3Container/DeleteButton3


#Save File Paths
var save_path_1 = "user://save1/"
var save_path_2 = "user://save2/"
var save_path_3 = "user://save3/"

var playerOverworldData : PlayerOverworldData


func _ready():
	save_button_1.grab_focus()
	if verify_save_path(save_path_1):
		set_node_text(save_button_1,"Slot 1 - LOAD")
		set_node_visibility(delete_button_1,true)
	if verify_save_path(save_path_2):
		set_node_text(save_button_2,"Slot 2 - LOAD")
		set_node_visibility(delete_button_2,true)
	if verify_save_path(save_path_3):
		set_node_text(save_button_3,"Slot 3 - LOAD")
		set_node_visibility(delete_button_3,true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		menu_back.emit()


func set_node_text(node,text):
	node.text = text

func set_node_visibility(node:Control, vis:bool):
	node.visible = vis

func verify_save_path(save_path):
	return DirAccess.dir_exists_absolute(save_path)

#TODO Move to Overworld Main Scene so that data is loaded on enter rather than leave. If data is loaded on leave nothing is tecnically done with it
#func load_data():
#	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)
#	print("Loaded")

##SAVE BUTTON FUNCTIONALITY
#Load the Data from the existing save file and transition to the overworld
func enter_game(save_path):
	SelectedSaveFile.selected_save_path = save_path
	#if DirAccess.dir_exists_absolute(SelectedSaveFile.selected_save_path):
	#	load_data()
	#SelectedSaveFile.save(playerOverworldData)
	#transition_out_animation()
	#get_tree().change_scene_to_packed(main_menu_scene)
	save_entered.emit()

#Navigates to the Overworld for Save Slot 1. If it doesn't exist it will be created.
func _on_save_button_1_pressed():
	#AudioManager.play_sound_effect("menu_confirm")
	enter_game(save_path_1)

#Navigates to the Overworld for Save Slot 1. If it doesn't exist it will be created.
func _on_save_button_2_pressed():
	#AudioManager.play_sound_effect("menu_confirm")
	enter_game(save_path_2)

#Navigates to the Overworld for Save Slot 1. If it doesn't exist it will be created.
func _on_save_button_3_pressed():
	#AudioManager.play_sound_effect("menu_confirm")
	enter_game(save_path_3)

##DELETE BUTTON FUNCTIONALITY

func delete_save_path(save_path):
	var dir = DirAccess.open(save_path)
	for file in dir.get_files():
		dir.remove(file)
	dir.remove(save_path)

func delete_button_pressed(save_path, save_button, delete_button):
	delete_save_path(save_path)
	delete_button.visible = false
	save_button.text = save_button.text.replace("LOAD","NEW")
	#AudioManager.play_sound_effect("menu_confirm")
	save_button.grab_focus()


func _on_delete_button_1_pressed() -> void:
	delete_button_pressed(save_path_1,save_button_1,delete_button_1)


func _on_delete_button_2_pressed() -> void:
	delete_button_pressed(save_path_2,save_button_2,delete_button_2)


func _on_delete_button_3_pressed() -> void:
	delete_button_pressed(save_path_3,save_button_3,delete_button_3)
