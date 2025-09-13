extends VBoxContainer

signal unit_focused(unit)
#signal unit_selected(unit)
signal header_swapped()
signal item_focused(item)

signal convoy_item_to_unit(item)

signal item_sold(item)

var playerOverworldData : PlayerOverworldData

@onready var army_convoy_header = $ArmyConvoyHeader

#@onready var main_scroll_container = $HBoxContainer/ScrollContainer/VBoxContainer

@onready var army_convoy_sub_container = $ArmyConvoySubContainer

const unit_army_panel_container_scene = preload("res://ui/battle_preparation/unit_army_panel_container.tscn")
const convoy_item_panel_container_scene = preload("res://ui/battle_preparation/convoy_item_panel_container.tscn")

var in_shop = false


enum CONTAINER_STATE{
	ARMY, CONVOY
}

var current_container_state = CONTAINER_STATE.ARMY

"""
func _ready():
	
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	army_convoy_sub_container.set_po_data(playerOverworldData)
	var current_selected_count = playerOverworldData.selected_party.size()
	var max_selected_count = playerOverworldData.available_party_capacity
	army_convoy_header.set_units_left_value(current_selected_count,max_selected_count)
	army_convoy_sub_container.fill_army_scroll_container()
	army_convoy_sub_container.get_first_child_focus()
"""

func set_po_data(po_data):
	playerOverworldData = po_data
	army_convoy_sub_container.set_po_data(playerOverworldData)

func set_units_left_value(current_selected_count,max_selected_count):
	army_convoy_header.set_units_left_value(current_selected_count,max_selected_count)

func fill_army_scroll_container():
	army_convoy_sub_container.fill_army_scroll_container()
#	for unit in playerOverworldData.total_party:
#		var unit_army_panel_container = unit_army_panel_container_scene.instantiate()
#		unit_army_panel_container.unit = unit
#		unit_army_panel_container.set_po_data(playerOverworldData)
#		main_scroll_container.add_child(unit_army_panel_container)
#		unit_army_panel_container.focus_entered.connect(unit_focus_entered.bind(unit))
#		unit_army_panel_container.unit_selected.connect(_on_unit_selected)
#		unit_army_panel_container.unit_deselected.connect(_on_unit_deselected)
#	var test = main_scroll_container.get_child(0)
#	if(test):
#		test.grab_focus()

func fill_convoy_scroll_container():
	army_convoy_sub_container.fill_convoy_scroll_container()
#	var i = 0
#	while i < temp:
#		var convoy_item_panel_container = convoy_item_panel_container_scene.instantiate()
#		main_scroll_container.add_child(convoy_item_panel_container)
#		convoy_item_panel_container.focus_entered.connect(item_focus_entered.bind(convoy_item_panel_container.item))
#		if i == 0:
#			convoy_item_panel_container.grab_focus()
#		i += 1

func clear_scroll_scontainer():
#	var children = main_scroll_container.get_children()
#	for child in children:
#		child.queue_free()
	army_convoy_sub_container.clear_scroll_container()

#func get_first_scroll_panel():
#	return main_scroll_container.get_child(0)

func _on_army_convoy_header_header_swapped():
	match current_container_state:
		CONTAINER_STATE.ARMY:
			current_container_state = CONTAINER_STATE.CONVOY
			army_convoy_sub_container.clear_scroll_container()
			army_convoy_sub_container.fill_convoy_scroll_container()
			army_convoy_sub_container.convoy_item_to_unit.connect(_on_convoy_item_to_unit)
			army_convoy_sub_container.item_sold.connect(_on_item_sold)
		CONTAINER_STATE.CONVOY:
			current_container_state = CONTAINER_STATE.ARMY
			army_convoy_sub_container.clear_scroll_container()
			army_convoy_sub_container.fill_army_scroll_container()
	army_convoy_sub_container.get_first_scroll_panel().grab_focus()
	header_swapped.emit()


func unit_focus_entered(unit):
	unit_focused.emit(unit)

func item_focus_entered(item):
	item_focused.emit(item)

func _on_unit_selected(unit):
	var current_selected_count = playerOverworldData.selected_party.size()
	var max_selected_count = playerOverworldData.available_party_capacity
	army_convoy_header.set_units_left_value(current_selected_count,max_selected_count)
	sort_party_by_selected()

func _on_unit_deselected(unit):
	var current_selected_count = playerOverworldData.selected_party.size()
	var max_selected_count = playerOverworldData.available_party_capacity
	army_convoy_header.set_units_left_value(current_selected_count,max_selected_count)
	sort_party_by_selected()

func get_sub_container():
	return army_convoy_sub_container

func _on_convoy_item_to_unit(item):
	convoy_item_to_unit.emit(item)

func _on_item_sold(item):
	item_sold.emit(item)

func in_shop_state():
	in_shop = true
	army_convoy_sub_container.in_shop = in_shop

#func get_sub_container_first_child_focus():
#	army_convoy_sub_container.get_first_child_focus()

func get_first_sub_container_child():
	return army_convoy_sub_container.get_child(0)

func sort_party_by_selected():
	var party = []
	for unit : Unit in playerOverworldData.total_party:
		if playerOverworldData.selected_party.has(unit):
			party.append(unit)
	for unit : Unit in playerOverworldData.total_party:
		if !playerOverworldData.selected_party.has(unit):
			party.append(unit)
	playerOverworldData.total_party = party
	clear_scroll_scontainer()
	fill_army_scroll_container()
	
