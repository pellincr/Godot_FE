extends Control

@onready var main_container = get_node("MainVcontainer")
@onready var party_container = get_node("PartyVContainer")
@onready var shop_container = get_node("ShopVContainer")
@onready var recruit_container = get_node("RecruitVContainer")
@onready var training_container = get_node("TrainingVContainer")

@onready var gold_counter = get_node("GoldCounter")


#Initialized Data (to be moved later when initialized in save file)
var gold = 15050
var total_party_capacity = 15 #number of units the player is allowed to own
var available_party_capacity = 3 #number of units the player is allowed to use in dungeon
var total_recruits_available = 3 #number of units the player is able to purchase
var shop_level = 1 #level of shop associated with what upgrades are availalble for purchase


func load_data():
	if FileAccess.file_exists(SelectedSaveFile.selected_save_path):
		var file = FileAccess.open(SelectedSaveFile.selected_save_path, FileAccess.READ)
		var gold = file.get_var()
		gold_counter.update_gold_count(gold)
	else:
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	gold_counter.update_gold_count(gold)
	_instantiate_manage_party_buttons()
	_instantiate_recruit_selection_buttons()
	_instantiate_shop_selection_buttons()
	#load_data()	

#Begins the adventure and transitions to the game scene
#NOTE This will be updated in the future to transition to the dungeon map
func _on_begin_adventure_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

#Returns to the main menu scene from the selected save
func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://main menu/main_menu.tscn")
	SelectedSaveFile.selected_save_path = ""

#Minimizes current submenu and returns back to the overworld main container selection
func _on_return_button_pressed():
	main_container.visible = true
	party_container.visible = false
	shop_container.visible = false
	recruit_container.visible = false
	training_container.visible = false

#num string container -> void
#Creates a given amount of buttons with the specified text in the entered container
func create_buttons_list(button_count, button_text, button_function, button_container):
	for i in range(button_count):
		var button := Button.new()
		button.text = str(button_text)
		button.pressed.connect(button_function)
		button_container.add_child(button)


#-----------MANAGE PARTY------------
#This section will have all the methods for managing the party

#Creates the initial amount of buttons needed in the Manage Party menu
func _instantiate_manage_party_buttons():
	create_buttons_list(total_party_capacity,"-EMPTY-",_on_return_button_pressed,$PartyVContainer/ScrollContainer/VBoxContainer)

#Shows the Mange Party Screen and minimizes the main container
func _on_manage_party_button_pressed():
	main_container.visible = false
	party_container.visible = true

#Updgrades the total number of units the player is allowed to own
func _on_total_capacity_upgrade_button_pressed():
	#if the player has enough gold and isn't at the maximum possible capacity
	if(gold >= 100 and total_party_capacity <= 30):
		#increase capacity by 5 and create the new buttons
		total_party_capacity += 5
		create_buttons_list(5,"-EMPTY-",_on_return_button_pressed,$PartyVContainer/ScrollContainer/VBoxContainer)
		#Subtract 100 gold and update the counter
		gold -= 100
		gold_counter.update_gold_count(gold)

#Upgrades the total number of units the player is allowed to bring into the dungeon
func _on_available_party_capacity_upgrade_button_pressed():
	if(gold >= 100 and available_party_capacity <= 5):
		available_party_capacity += 1
		gold -= 100
		gold_counter.update_gold_count(gold)


#-----------RECRUIT UNITS------------
#This section will have all the methods for recruiting new units to the party

#Creates the initial amount of buttons needed in the Recruit Units menu
func _instantiate_recruit_selection_buttons():
	create_buttons_list(total_recruits_available,"-EMPTY-",_on_return_button_pressed,$RecruitVContainer/RecruitHContainer)


#Shows the Recruit Unit Screen and minimizes the main container
func _on_recruit_button_pressed():
	recruit_container.visible = true
	main_container.visible = false

#Upgrades the number of units the player can select from
func _on_upgrade_selection_amount_button_pressed():
	if(gold >= 100 and total_recruits_available <= 5):
		#increase the amount of selections and create the new button
		total_recruits_available += 1
		create_buttons_list(1,"-EMPTY-",_on_return_button_pressed,$RecruitVContainer/RecruitHContainer)
		#subtract the gold and update the counter
		gold -= 100
		gold_counter.update_gold_count(gold)

func _on_upgrade_selection_levels_button_pressed():
	pass # Replace with function body.
	#will upgrade the units available by the following chances for appearing:
	#Level 1 – 30%
	#Level 2 – 25%
	#Level 3 – 20%
	#Level 4 – 10%
	#Level 5 – 5%
	#Level 6 – 4%
	#Level 7 – 3%
	#Level 8 – 2%
	#Level 9 – 0.9%
	#Level 10 – 0.1%


#-----------SHOP------------
#This section will have all the methods for interacting with the shop menu

#Creates the initial amount of buttons needed in the Shop menu
func _instantiate_shop_selection_buttons():
	create_buttons_list(5,"-UPDATE WITH SHOP ITEM-",_on_return_button_pressed,$ShopVContainer/ScrollContainer/VBoxContainer)

#Shows the Shop Screen and minimizes the main container
func _on_shop_button_pressed():
	shop_container.visible = true
	main_container.visible = false

func _on_upgrade_shop_button_pressed():
	if(gold >= 100 and shop_level <= 5):
		#increase the amount of selections and create the new button
		shop_level += 1
		create_buttons_list(5,"-EMPTY-",_on_return_button_pressed,$ShopVContainer/ScrollContainer/VBoxContainer)
		#subtract the gold and update the counter
		gold -= 100
		gold_counter.update_gold_count(gold)

#-----------TRAIN PARTY MEMBERS------------
#This section will have all the methods for interacting with the training menu

#Shows the Training Screen and minimizes the main container
func _on_train_party_button_pressed():
	training_container.visible = true
	main_container.visible = false
