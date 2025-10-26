extends Control



@onready var main_container = get_node("MainVContainer")
@onready var option_container = get_node("OptionVContainer")
@onready var save_container = get_node("SaveVContainer")

@onready var start_button = $MainVContainer/Start_Button
#Save Files
#var save_file = ConfigFile.new()

var save_path_1 = "user://save1/"
var save_path_2 = "user://save2/"
var save_path_3 = "user://save3/"
#var save_file_2 = "res://save2.cfg"
#var save_file_3 = "res://save3.cfg"
@onready var save_1_button = $SaveVContainer/Save1HContainer/Save_Button1 as Button
@onready var save_1_delete_button = $SaveVContainer/Save1HContainer/Delete_Button as Button
@onready var save_2_button = $SaveVContainer/Save2HContainer/Save_Button2 as Button
@onready var save_2_delete_button = $SaveVContainer/Save2HContainer/Delete_Button as Button
@onready var save_3_button = $SaveVContainer/Save3HContainer/Save_Button3 as Button
@onready var save_3_delete_button = $SaveVContainer/Save3HContainer/Delete_Button as Button


var playerOverworldData : PlayerOverworldData

const main_menu_scene = preload("res://Game Main Menu/main_menu.tscn")
const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

#Load the Data from the existing save file and transition to the overworld
func enter_game(save_path):
	SelectedSaveFile.selected_save_path = save_path
	if DirAccess.dir_exists_absolute(SelectedSaveFile.selected_save_path):
		load_data()
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	get_tree().change_scene_to_packed(main_menu_scene)



#Called when the node enters the scene tree for the first time.
func _ready():
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
	transition_in_animation()
	SelectedSaveFile.selected_save_path = ""
	$MainVContainer/Start_Button.grab_focus()
	if verify_save_path(save_path_1):
		set_save_button_text(save_1_button,"Slot 1 - LOAD")
		set_delete_visibility(save_1_delete_button,true)
	if verify_save_path(save_path_2):
		set_save_button_text(save_2_button,"Slot 2 - LOAD")
		set_delete_visibility(save_2_delete_button,true)
	if verify_save_path(save_path_3):
		set_save_button_text(save_3_button,"Slot 3 - LOAD")
		set_delete_visibility(save_3_delete_button,true)
	AudioManager.play_music("menu_theme")

func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)
	print("Loaded")


func transition_in_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_out")
	await get_tree().create_timer(.5).timeout
	scene_transition.queue_free()

func transition_out_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5).timeout





func set_save_button_text(button, text):
	button.text = text

func set_delete_visibility(button, vis):
	button.visible = vis

func verify_save_path(save_path):
	return DirAccess.dir_exists_absolute(save_path)

#Quits the Game back to Desktop
func _on_quit_button_pressed():
	get_tree().quit()

#Returns to the Main Menu from one of the sub-menus
func _on_return_button_pressed():
	main_container.visible = true
	option_container.visible = false
	save_container.visible = false
	start_button.grab_focus()

#Opens the Options Menu and Minimizes the Main Menu
func _on_options_button_pressed():
	main_container.visible = false
	option_container.visible = true

#Opens the Save Slot Selection Menu and minimizes the Main Menu
func _on_start_button_pressed():
	main_container.visible = false
	save_container.visible = true
	save_1_button.grab_focus()
	AudioManager.play_sound_effect("menu_confirm")


func on_save_button_delete(save_path, button):
	var dir = DirAccess.open(save_path)
	for file in dir.get_files():
		dir.remove(file)
	dir.remove(save_path)
	button.grab_focus()
	button.text = button.text.replace("LOAD","NEW")


func _on_save_button_pressed(save_path):
	enter_game(save_path)

func _on_delete_save_button_pressed(save_path, save_button, delete_button):
	on_save_button_delete(save_path,save_button)
	delete_button.visible = false
	AudioManager.play_sound_effect("menu_confirm")


#Navigates to the Overworld for Save Slot 1. If it doesn't exist it will be created.
func _on_save_button_1_pressed():
	AudioManager.play_sound_effect("menu_confirm")
	enter_game(save_path_1)

#Deletes the Save Slot 1 File
func _on_save_slot_1_delete_button_pressed():
	_on_delete_save_button_pressed(save_path_1,save_1_button,save_1_delete_button)

#Navigates to the Overworld for Save Slot 2. If it doesn't exist it will be created.
func _on_save_button_2_pressed():
	AudioManager.play_sound_effect("menu_confirm")
	enter_game(save_path_2)

#Deletes the Save Slot 2 File
func _on_save_slot_2_delete_button_pressed():
	_on_delete_save_button_pressed(save_path_2,save_2_button,save_2_delete_button)

#Navigates to the Overworld for Save Slot 2. If it doesn't exist it will be created.
func _on_save_button_3_pressed():
	AudioManager.play_sound_effect("menu_confirm")
	enter_game(save_path_3)

#Deletes the Save Slot 3 File
func _on_save_slot_3_delete_button_pressed():
	_on_delete_save_button_pressed(save_path_3,save_3_button,save_3_delete_button)
