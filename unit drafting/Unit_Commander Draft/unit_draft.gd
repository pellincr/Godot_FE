extends Control

signal commander_drafted(commander)

signal unit_drafted(unit)

const unit_selector_scene = preload("res://unit drafting/Unit_Commander Draft/unit_draft_selector.tscn")

var playerOverworldData : PlayerOverworldData
var control_node : Node

var current_state = Constants.DRAFT_STATE.COMMANDER

@onready var main_container = $MainContainer

func _init(state : Constants.DRAFT_STATE = Constants.DRAFT_STATE.COMMANDER) -> void:
	self.current_state = state

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
var randomized_commander_types = []

#Creates the initial amount of buttons needed in the Recruit Units menu
func instantiate_unit_selectors():
	if current_state == Constants.DRAFT_STATE.COMMANDER:
		var unlocked_commander_count = playerOverworldData.unlock_manager.get_unlocked_count(playerOverworldData.unlock_manager.commander_types_unlocked)
		var selector_count = min(playerOverworldData.current_campaign.commander_draft_limit,unlocked_commander_count)
		unit_selectors = create_unit_selector_list(selector_count, main_container)
	else:
		unit_selectors = create_unit_selector_list(4, main_container)


#num string container -> list of buttons
#Creates a given amount of buttons with the specified text in the entered container
func create_unit_selector_list(selector_count: int, selector_container):
	var accum = []
	for i in range(selector_count):
		var unit_selector : unitDraftSelector = unit_selector_scene.instantiate()
		unit_selector.connect("unit_selected",unit_selected)
		unit_selector.next_screen.connect(next_screens)
		unit_selector.previous_screen.connect(previous_screens)
		unit_selector.set_po_data(playerOverworldData)
		unit_selector.current_draft_state = current_state
		unit_selector.randomized_commander_types = randomized_commander_types
		selector_container.add_child(unit_selector)
		randomized_commander_types.append(unit_selector.unit.unit_type_key)
		accum.append(unit_selector)
	accum[0].grab_focus()
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

func next_screens():
	for selector in unit_selectors:
		selector.show_next_screen()

func previous_screens():
	for selector in unit_selectors:
		selector.show_previous_screen()

func update_unit_selectors():
	for i in unit_selectors.size():
		var selector: unitDraftSelector = unit_selectors[i]
		selector.randomize_selection()
		selector.update_information()
		selector.current_state = unitDraftSelector.SELECTOR_STATE.OVERVIEW
		var last_child = selector.main_container.get_children()[-1]
		last_child.queue_free()
		selector.instantiate_unit_draft_selector()

func get_first_selector():
	return main_container.get_child(0)

func set_selectors_focus(focus):
	for child in main_container.get_children():
		child.focus_mode = focus

func enable_selector_focus():
	set_selectors_focus(FOCUS_ALL)

func disable_selector_focus():
	set_selectors_focus(FOCUS_NONE)
