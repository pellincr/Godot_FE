extends Control

class_name armyArchetypeDraft

signal archetype_selection_complete(po_data)
signal archetype_selected()

const archetype_selector_scene = preload("res://unit drafting/Archetype Draft/archetype_draft_selector.tscn")
var playerOverworldData : PlayerOverworldData
var control_node : Node

@onready var main_container = $HBoxContainer

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
var archetype_selectors = []

#num string container -> list of buttons
#Creates a given amount of buttons with the specified text in the entered container
func create_archetype_selector_list(selector_count: int, selector_container):
	var accum = []
	for i in range(selector_count):
		var archetype_selector : archetypeDraftSelector = archetype_selector_scene.instantiate()
		selector_container.add_child(archetype_selector)
		archetype_selector.connect("archetype_selected",on_archetype_selected)
		accum.append(archetype_selector)
	return accum


#Creates the initial amount of buttons needed in the Recruit Units menu
func instantiate_archetype_buttons():
	archetype_selectors = create_archetype_selector_list(4,main_container )
	#update_archetype_buttons()

func update_archetype_selectors():
	for i in archetype_selectors.size():
		var selector = archetype_selectors[i]
		selector.randomize_archetype()
		selector.update_all()


func on_archetype_selected(archetype:ArmyArchetypeDefinition):
	#Increase the number of archetypes the player has selected by 1
	playerOverworldData.current_archetype_count += 1
	#add the archtype allotments to the players archetype allotment list
	var selected_archetype_picks = archetype.archetype_picks
	var archetype_list = create_archetype_list(selected_archetype_picks)
	playerOverworldData.archetype_allotments.append_array(archetype_list)
	#Re-Randomize the selectors
	update_archetype_selectors()
	archetype_selected.emit()
	if (playerOverworldData.current_archetype_count == playerOverworldData.max_archetype):
		archetype_selection_complete.emit(playerOverworldData)
		queue_free()
		print("All Archetypes Selected")


func create_archetype_list(archetype_picks):
	var accum = []
	for pick in archetype_picks:
		var volume = pick.volume
		while volume >= 1:
			accum.append(pick)
			volume -= 1
	return accum
