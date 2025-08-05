extends Control

var save_file_name = "PlayerOverworldSave.tres"
var playerOverworldData = PlayerOverworldData.new()
var control_node : Node

@onready var main_container = get_node("MainVcontainer")
@onready var party_container = get_node("PartyVContainer")
@onready var shop_container = get_node("ShopVContainer")
@onready var convoy_container = get_node("ConvoyVContainer")

@onready var gold_counter = get_node("GoldCounter")

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

const overworldButtonScene = preload("res://overworld/overworld_button.tscn")
const unit_stats = preload("res://overworld/unit_stats.tscn")

func _ready():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_out")
	await get_tree().create_timer(0.5)
	scene_transition.queue_free()

func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + save_file_name).duplicate(true)
	#update the gui
	#set_recruit_buttons(recruit_buttons, playerOverworldData.new_recruits)
	#update_manage_party_buttons()
	print("Loaded")

func save():
	ResourceSaver.save(playerOverworldData,SelectedSaveFile.selected_save_path + save_file_name)
	print("Saved")

#func _process(delta):
	#if Input.is_action_just_pressed("load"):
		#set_recruit_buttons(recruit_buttons, playerOverworldData.new_recruits)
		#update_manage_party_buttons()

#Begins the adventure and transitions to the game scene
#NOTE This will be updated in the future to transition to the dungeon map
func _on_begin_adventure_button_pressed():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5)
	get_tree().change_scene_to_file("res://combat/game.tscn")

#Returns to the main menu scene from the selected save
func _on_main_menu_button_pressed():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5)
	get_tree().change_scene_to_file("res://main menu/main_menu.tscn")
	SelectedSaveFile.selected_save_path = ""

#Minimizes current submenu and returns back to the overworld main container selection
func _on_return_button_pressed():
	main_container.visible = true
	party_container.visible = false
	shop_container.visible = false
	convoy_container.visible = false
	$MainVcontainer/ManageParty_Button.grab_focus()

func initialize():
	SelectedSaveFile.verify_save_directory(SelectedSaveFile.selected_save_path)
	$MainVcontainer/ManageParty_Button.grab_focus()
	gold_counter.update_gold_count(playerOverworldData.gold)
	convoy_container.set_po_data(playerOverworldData)
	shop_container.set_po_data(playerOverworldData)
	party_container.set_po_data(playerOverworldData)
	convoy_container.set_control_node(self)
	shop_container.set_control_node(self)
	party_container.set_control_node(self)


#-----------MANAGE PARTY------------
#Creates the initial amount of buttons needed in the Manage Party menu
#Shows the Mange Party Screen and minimizes the main container
func _on_manage_party_button_pressed():
	party_container.update_manage_party_buttons()
	main_container.visible = false
	party_container.visible = true


#-----------SHOP------------
#This section will have all the methods for interacting with the shop menu

#Shows the Shop Screen and minimizes the main container
func _on_shop_button_pressed():
	shop_container.visible = true
	main_container.visible = false

func item_bought(item:ItemDefinition):
	playerOverworldData.append_to_array(playerOverworldData.convoy, item)
	playerOverworldData.gold -= 100
	gold_counter.update_gold_count(playerOverworldData.gold)
	convoy_container.update_convoy_buttons()


#-----------------CONVOY------------------

func _on_convoy_button_pressed():
	convoy_container.update_convoy_buttons()
	main_container.visible = false
	convoy_container.visible = true
