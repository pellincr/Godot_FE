extends Control

signal commander_drafted(commander)

signal unit_drafted(unit)

const unit_selector_scene = preload("res://unit drafting/Unit_Commander Draft/unit_draft_selector.tscn")

var playerOverworldData : PlayerOverworldData
var control_node : Node

var current_state = Constants.DRAFT_STATE.COMMANDER

@onready var main_container = $HBoxContainer


func _ready():
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	instantiate_unit_selectors()

func set_po_data(po_data):
	playerOverworldData = po_data

func set_control_node(c_node):
	control_node = c_node

#This section will have all the methods for recruiting new units to the party
var unit_selectors = []

#Creates the initial amount of buttons needed in the Recruit Units menu
func instantiate_unit_selectors():
	unit_selectors = create_unit_selector_list(4, main_container)

#num string container -> list of buttons
#Creates a given amount of buttons with the specified text in the entered container
func create_unit_selector_list(selector_count: int, selector_container):
	var accum = []
	for i in range(selector_count):
		var unit_selector : unitDraftSelector = unit_selector_scene.instantiate()
		unit_selector.connect("unit_selected",unit_selected)
		unit_selector.set_po_data(playerOverworldData)
		unit_selector.current_draft_state = current_state
		selector_container.add_child(unit_selector)
		accum.append(unit_selector)
	return accum

func unit_selected(unit):
	match(current_state):
		Constants.DRAFT_STATE.COMMANDER:
			commander_drafted.emit(unit)
			print("Commander Drafted!")
			queue_free()
		Constants.DRAFT_STATE.UNIT:
			unit_drafted.emit(unit)
			if (playerOverworldData.archetype_allotments.size() > 0):
				#if there are still unit types left to draft
				update_unit_selectors()
			print("Unit Drafted!")

func update_unit_selectors():
	for i in unit_selectors.size():
		var selector: unitDraftSelector = unit_selectors[i]
		selector.randomize_unit()
		selector.update_information()
		var last_child = selector.main_container.get_children()[-1]
		last_child.queue_free()
		selector.instantiate_unit_draft_selector()
