extends HBoxContainer

signal archetype_selection_complete()

const overworldButtonScene = preload("res://overworld/overworld_button.tscn")
var playerOverworldData : PlayerOverworldData
var control_node : Node

var army_archetype_names = ArmyArchetypeDatabase.army_archetypes.keys()

func _ready():
	if playerOverworldData != null:
		instantiate_archetype_buttons()
	else:
		playerOverworldData = PlayerOverworldData.new()
		instantiate_archetype_buttons()

func set_po_data(po_data):
	playerOverworldData = po_data

func set_control_node(c_node):
	control_node = c_node

#This section will have all the methods for recruiting new units to the party
var archetype_buttons = []

#num string container -> list of buttons
#Creates a given amount of buttons with the specified text in the entered container
func create_buttons_list(button_count: int, button_text: String, button_function, button_container):
	var accum = []
	for i in range(button_count):
		#var button = OverworldButton.new()
		var button : OverworldButton = overworldButtonScene.instantiate()
		button.set_button_text(button_text)
		#sets the contained variable to be the specified army archetype listed
		button.set_contained_var(ArmyArchetypeDatabase.army_archetypes.get(button_text))
		button.set_button_pressed(button_function, i)
		button_container.add_child(button)
		accum.append(button)
	return accum


#Creates the initial amount of buttons needed in the Recruit Units menu
func instantiate_archetype_buttons():
	archetype_buttons = create_buttons_list(3,
											army_archetype_names.pick_random(),_on_archetype_selected,
											$".")

func _on_archetype_selected(button_index):
	playerOverworldData.current_archetype_count += 1
	#Get the archetype associated with the pressed button
	var selected_archetype = archetype_buttons[button_index].get_contained_var()
	#add the classes expected to appear from the selected archetype to the archetype allotments
	playerOverworldData.archetype_allotments.append_array(selected_archetype.given_classes)
	print("Archetype Selected!")
	if (playerOverworldData.current_archetype_count == playerOverworldData.max_archetype):
		archetype_selection_complete.emit()
