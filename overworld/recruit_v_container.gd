extends VBoxContainer

signal unit_recruited(unit: Unit)

const overworldButtonScene = preload("res://overworld/overworld_button.tscn")
var playerOverworldData : PlayerOverworldData
var control_node : Node

func _ready():
	if playerOverworldData != null:
		instantiate_recruit_buttons()
	else:
		playerOverworldData = PlayerOverworldData.new()
		instantiate_recruit_buttons()

func set_po_data(po_data):
	playerOverworldData = po_data

func set_control_node(c_node):
	control_node = c_node

#This section will have all the methods for recruiting new units to the party
var recruit_buttons = []

#num string container -> list of buttons
#Creates a given amount of buttons with the specified text in the entered container
func create_buttons_list(button_count, button_text, button_function, button_container):
	var accum = []
	for i in range(button_count):
		#var button = OverworldButton.new()
		var button : OverworldButton = overworldButtonScene.instantiate()
		button.set_button_text(button_text)
		button.set_button_pressed(button_function, i)
		button_container.add_child(button)
		accum.append(button)
	return accum


#Creates the initial amount of buttons needed in the Recruit Units menu
func instantiate_recruit_buttons():
	recruit_buttons = create_buttons_list(playerOverworldData.total_recruits_available,
											"-EMPTY-",_on_recruit_button_pressed,
											$RecruitHContainer)
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




#When a new recruit is pressed, they are added to the memebers total party and then rerolled
func _on_recruit_button_pressed(button_index):
	if(recruit_buttons.size() > button_index and playerOverworldData.gold >= 100):
		unit_recruited.emit(recruit_buttons[button_index].get_contained_var())
		#reroll all the units on the recruit page
		set_recruit_buttons(recruit_buttons, generate_recruits(3))
