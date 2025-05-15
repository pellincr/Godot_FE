extends Control

var save_file_name = "PlayerOverworldSave.tres"
var playerOverworldData = PlayerOverworldData.new()


@onready var main_container = get_node("MainVcontainer")
@onready var party_container = get_node("PartyVContainer")
@onready var shop_container = get_node("ShopVContainer")
@onready var convoy_container = get_node("ConvoyVContainer")
@onready var recruit_container = get_node("RecruitVContainer")
@onready var training_container = get_node("TrainingVContainer")

@onready var gold_counter = get_node("GoldCounter")

const overworldButtonScene = preload("res://overworld/overworld_button.tscn")
const unit_stats = preload("res://overworld/unit_stats.tscn")


func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + save_file_name).duplicate(true)
	#update the gui
	set_recruit_buttons(recruit_buttons, playerOverworldData.new_recruits)
	update_manage_party_buttons()
	print("Loaded")

func save():
	ResourceSaver.save(playerOverworldData,SelectedSaveFile.selected_save_path + save_file_name)
	print("Saved")

func _process(delta):
	if Input.is_action_just_pressed("load"):
		set_recruit_buttons(recruit_buttons, playerOverworldData.new_recruits)
		update_manage_party_buttons()

#Begins the adventure and transitions to the game scene
#NOTE This will be updated in the future to transition to the dungeon map
func _on_begin_adventure_button_pressed():
	get_tree().change_scene_to_file("res://combat/game.tscn")

#Returns to the main menu scene from the selected save
func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://main menu/main_menu.tscn")
	SelectedSaveFile.selected_save_path = ""

#Minimizes current submenu and returns back to the overworld main container selection
func _on_return_button_pressed():
	main_container.visible = true
	party_container.visible = false
	shop_container.visible = false
	convoy_container.visible = false
	recruit_container.visible = false
	training_container.visible = false
	$MainVcontainer/ManageParty_Button.grab_focus()

func initialize():
	SelectedSaveFile.verify_save_directory(SelectedSaveFile.selected_save_path)
	$MainVcontainer/ManageParty_Button.grab_focus()
	gold_counter.update_gold_count(playerOverworldData.gold)
	_instantiate_manage_party_buttons()
	#instantiate_manage_party_screen()
	_instantiate_recruit_selection_buttons()
	_instantiate_shop_selection_buttons()
	instantiate_convoy_buttons()

#num string container -> list of buttons
#Creates a given amount of buttons with the specified text in the entered container
func create_buttons_list(button_count, button_text, button_function, button_container, text = false):
	var accum = []
	for i in range(button_count):
		#var button = OverworldButton.new()
		var button : OverworldButton = overworldButtonScene.instantiate()
		button.set_button_text(button_text)
		if text:
			button.set_button_pressed(button_function, button_text)
		else:
			button.set_button_pressed(button_function, i)
		button_container.add_child(button)
		accum.append(button)
	return accum

#-----------MANAGE PARTY------------
#This section will have all the methods for managing the party
var party_buttons = []

#Creates the initial amount of buttons needed in the Manage Party menu
func _instantiate_manage_party_buttons():
	party_buttons = create_buttons_list(playerOverworldData.total_party_capacity,
	"-EMPTY-",_on_party_member_button_pressed,$PartyVContainer/ScrollContainer/VBoxContainer)

func update_manage_party_buttons():
	for i in party_buttons.size():
		if i < playerOverworldData.total_party.size():
			update_manage_party_button(party_buttons[i],playerOverworldData.total_party[i])
		else:
			party_buttons[i].set_button_text("-EMPTY-")

func update_manage_party_button(button: OverworldButton, unit: Unit):
	button.contained_variable = unit
	button.set_button_text("NAME:" + unit.unit_name + 
							"\n" + "CLASS:" + unit.unit_class_key)


#Shows the Mange Party Screen and minimizes the main container
func _on_manage_party_button_pressed():
	update_manage_party_buttons()
	main_container.visible = false
	party_container.visible = true


#Updgrades the total number of units the player is allowed to own
func _on_total_capacity_upgrade_button_pressed():
	#if the player has enough gold and isn't at the maximum possible capacity
	if(playerOverworldData.gold >= 100 and playerOverworldData.total_party_capacity <= 30):
		#increase capacity by 5 and create the new buttons
		playerOverworldData.total_party_capacity += 5
		create_buttons_list(5,"-EMPTY-",_on_return_button_pressed,$PartyVContainer/ScrollContainer/VBoxContainer)
		#Subtract 100 gold and update the counter
		playerOverworldData.gold -= 100
		gold_counter.update_gold_count(playerOverworldData.gold)

#Upgrades the total number of units the player is allowed to bring into the dungeon
func _on_available_party_capacity_upgrade_button_pressed():
	if(playerOverworldData.gold >= 100 and playerOverworldData.available_party_capacity <= 5):
		playerOverworldData.available_party_capacity += 1
		playerOverworldData.gold -= 100
		gold_counter.update_gold_count(playerOverworldData.gold)


func _on_party_member_button_pressed(button_index):
	if(party_buttons.size() > button_index):
		var pressed_button = party_buttons[button_index]
		var unit = pressed_button.get_contained_var()
		var button_container = pressed_button.get_hbox_container()
		if unit != null:
			var u_stats = unit_stats.instantiate()
			u_stats.connect("unit_selected", unit_selected)
			u_stats.connect("unit_dismissed",unit_dismissed)
			u_stats.unit = unit
			u_stats.set_level(unit.level)
			u_stats.set_hp(unit.hp)
			u_stats.set_strength(unit.strength)
			u_stats.set_magic(unit.magic)
			u_stats.set_skill(unit.skill)
			u_stats.set_speed(unit.speed)
			u_stats.set_luck(unit.luck)
			u_stats.set_defense(unit.defense)
			u_stats.set_magic_defense(unit.magic_defense)
			button_container.add_child(u_stats)

#adds or removes the given unit to the selected party
func unit_selected(unit, selected):
	if selected:
		playerOverworldData.append_to_array(playerOverworldData.selected_party,unit)
	elif playerOverworldData.selected_party.size() < playerOverworldData.available_party_capacity:
		playerOverworldData.selected_party.remove_at(playerOverworldData.selected_party.find(unit))

#removes the given unit from the total party and selected party if necessary
func unit_dismissed(unit):
	playerOverworldData.total_party.remove_at(playerOverworldData.total_party.find(unit))
	if playerOverworldData.selected_party.find(unit) != -1:
		playerOverworldData.selected_party.remove_at(playerOverworldData.selected_party.find(unit))
	unit = null
	update_manage_party_buttons()

#-----------RECRUIT UNITS------------
#This section will have all the methods for recruiting new units to the party
var recruit_buttons = []
#Creates the initial amount of buttons needed in the Recruit Units menu
func _instantiate_recruit_selection_buttons():
	recruit_buttons = create_buttons_list(playerOverworldData.total_recruits_available,
											"-EMPTY-",_on_new_recruit_button_pressed,
											$RecruitVContainer/RecruitHContainer)
	playerOverworldData.new_recruits = generate_recruits(playerOverworldData.total_recruits_available)
	set_recruit_buttons(recruit_buttons, playerOverworldData.new_recruits)

#int -> array of units
#creates an array of random units of the given size
func generate_recruits(num):
	var accum = []
	var unit_classes = UnitTypeDatabase.unit_types.keys()
	for i in range(num):
		var new_recruit_class = unit_classes.pick_random()
		var new_unit_name = playerOverworldData.temp_name_list.pick_random()
		var iventory_array : Array[ItemDefinition]
		iventory_array.append(ItemDatabase.items["brass_knuckles"])
		var new_recruit = Unit.create_generic(UnitTypeDatabase.unit_types.get(new_recruit_class),iventory_array, new_unit_name, 2)
		accum.append(new_recruit)
	return accum

#Sets the text on the given Recruit button to be what is on the given unit
func set_recruit_button(button:OverworldButton, unit:Unit):
	button.set_contained_var(unit) #Associates the button to the recruit
	button.set_button_text("Name: " + unit.unit_name + 
							"\n" + "Class: " + UnitTypeDatabase.unit_types[unit.unit_class_key].unit_type_name + 
							"\n" + "Level: " + str(unit.level) +
							"\n" + "HP: " + str(unit.hp))


#Sets the given list of button to the text from the function
func set_recruit_buttons(buttons:Array, recruits:Array):
	for i in range(buttons.size()):
		set_recruit_button(buttons[i],recruits[i])

#Shows the Recruit Unit Screen and minimizes the main container
func _on_recruit_button_pressed():
	recruit_container.visible = true
	main_container.visible = false

#Upgrades the number of units the player can select from
func _on_upgrade_selection_amount_button_pressed():
	if(playerOverworldData.gold >= 100 and playerOverworldData.total_recruits_available <= 5):
		#increase the amount of selections and create the new button
		playerOverworldData.total_recruits_available += 1
		playerOverworldData.set_recruit_buttons(create_buttons_list(1,"-EMPTY-",_on_return_button_pressed,$RecruitVContainer/RecruitHContainer), generate_recruits(1))
		#subtract the gold and update the counter
		playerOverworldData.gold -= 100
		gold_counter.update_gold_count(playerOverworldData.gold)

func _on_upgrade_selection_levels_button_pressed():
	pass # Replace with function body.

#When a new recruit is pressed, they are added to the memebers total party and then rerolled
func _on_new_recruit_button_pressed(button_index):
	if(recruit_buttons.size() > button_index and playerOverworldData.gold >= 100):
		var recruit_buttons = $RecruitVContainer/RecruitHContainer.get_children()
		#get the unit on the button that was pressed
		var pressed_button = recruit_buttons[button_index]
		var unit = pressed_button.get_contained_var()
		#add the unit to the total party
		playerOverworldData.append_to_array(playerOverworldData.total_party, unit)
		update_manage_party_buttons()
		#update_manage_party_screen()
		#reroll the selected unit on the recruit page
		set_recruit_buttons([pressed_button], generate_recruits(1))
		#decrease gold cost by unit price
		playerOverworldData.gold -= 100
		gold_counter.update_gold_count(playerOverworldData.gold)
		#save()



#-----------SHOP------------
#This section will have all the methods for interacting with the shop menu
var all_items = ItemDatabase.items.keys()
var magic_items = filter_items_by_damage_type(all_items, Constants.DAMAGE_TYPE.MAGIC)
var axe_items = filter_items_by_weapon_type(all_items, "Axe")

#Creates the initial amount of buttons needed in the Shop menu
func _instantiate_shop_selection_buttons():
	#set all items tab
	for i in all_items.size():
		create_buttons_list(1,all_items[i],_on_shop_item_button_pressed,
						$"ShopVContainer/TabContainer/All Items/VBoxContainer", true)
	#set axes tab
	for i in axe_items.size():
		create_buttons_list(1,axe_items[i],_on_shop_item_button_pressed,
						$ShopVContainer/TabContainer/Axes/VBoxContainer, true)
	#set magic tab
	for i in magic_items.size():
		create_buttons_list(1,magic_items[i],_on_shop_item_button_pressed,
						$ShopVContainer/TabContainer/Magic/VBoxContainer, true)

#Shows the Shop Screen and minimizes the main container
func _on_shop_button_pressed():
	shop_container.visible = true
	main_container.visible = false

func _on_shop_item_button_pressed(button_text):
	if playerOverworldData.convoy.size() < playerOverworldData.convoy_size and playerOverworldData.gold >= 100:
		playerOverworldData.append_to_array(playerOverworldData.convoy, ItemDatabase.items.get(button_text))
		playerOverworldData.gold -= 100
		gold_counter.update_gold_count(playerOverworldData.gold)
		print("Item Bought!")

func _on_upgrade_shop_button_pressed():
	if(playerOverworldData.gold >= 100 and playerOverworldData.shop_level <= 5):
		#increase the amount of selections and create the new button
		playerOverworldData.shop_level += 1
		#subtract the gold and update the counter
		playerOverworldData.gold -= 100
		gold_counter.update_gold_count(playerOverworldData.gold)


func filter_items_by_weapon_type(items, filter):
	var accum = []
	for i in items:
		var temp = ItemDatabase.items.get(i)
		if temp is WeaponDefinition:
			temp = temp.weapon_type
			if temp == filter:
				accum.append(i)
	return accum

func filter_items_by_damage_type(items, filter):
	var accum = []
	for i in items:
		var temp = ItemDatabase.items.get(i)
		if temp is WeaponDefinition:
			temp = temp.item_damage_type
			if temp == filter:
				accum.append(i)
	return accum
	


#-----------------CONVOY------------------
var convoy_buttons = []

func instantiate_convoy_buttons():
	convoy_buttons = create_buttons_list(playerOverworldData.convoy_size,"-EMPTY-",_on_return_button_pressed,
								$ConvoyVContainer/ScrollContainer/VBoxContainer)


func update_convoy_buttons():
	for i in convoy_buttons.size():
		if i < playerOverworldData.convoy.size():
			update_convoy_button(convoy_buttons[i],playerOverworldData.convoy[i])
		else:
			convoy_buttons[i].set_button_text("-EMPTY-")

func update_convoy_button(button: OverworldButton, item):
	button.contained_variable = item
	button.set_button_text(str(item.name))


func _on_convoy_button_pressed():
	update_convoy_buttons()
	main_container.visible = false
	convoy_container.visible = true



#-----------TRAIN PARTY MEMBERS------------
#This section will have all the methods for interacting with the training menu

#Shows the Training Screen and minimizes the main container
func _on_train_party_button_pressed():
	training_container.visible = true
	main_container.visible = false
