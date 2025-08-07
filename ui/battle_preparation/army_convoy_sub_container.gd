extends HBoxContainer

signal unit_focused()
signal item_focused()
signal unit_selected()
signal unit_deselected()

signal convoy_item_to_unit(item)

signal item_sold(item)

@onready var main_scroll_container = $ScrollContainer/MainScrollContainer

const unit_army_panel_container_scene = preload("res://ui/battle_preparation/unit_army_panel_container.tscn")
const convoy_item_panel_container_scene = preload("res://ui/battle_preparation/convoy_item_panel_container.tscn")

var playerOverworldData : PlayerOverworldData


var in_shop = false

func _ready():
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
		

func set_po_data(po_data):
	playerOverworldData = po_data

func fill_army_scroll_container():
	for unit in playerOverworldData.total_party:
		var unit_army_panel_container = unit_army_panel_container_scene.instantiate()
		unit_army_panel_container.unit = unit
		unit_army_panel_container.set_po_data(playerOverworldData)
		main_scroll_container.add_child(unit_army_panel_container)
		unit_army_panel_container.focus_entered.connect(unit_focus_entered.bind(unit))
		unit_army_panel_container.unit_selected.connect(_on_unit_selected)
		unit_army_panel_container.unit_deselected.connect(_on_unit_deselected)
	#var test = main_scroll_container.get_child(0)
	#if(test):
	#	test.grab_focus()


func fill_convoy_scroll_container():
	for item in playerOverworldData.convoy:
		if item:
			var convoy_item_panel_container = convoy_item_panel_container_scene.instantiate()
			convoy_item_panel_container.item = item
			main_scroll_container.add_child(convoy_item_panel_container)
			convoy_item_panel_container.focus_entered.connect(item_focus_entered.bind(convoy_item_panel_container.item))
			convoy_item_panel_container.item_sent_to_unit.connect(_on_item_sent_to_unit)
			convoy_item_panel_container.item_sold.connect(_on_item_sold)
	#var test = main_scroll_container.get_child(0)
	#if(test):
	#	test.grab_focus()


func clear_scroll_container():
	var children = main_scroll_container.get_children()
	for child in children:
		child.queue_free()

func unit_focus_entered(unit):
	unit_focused.emit(unit)

func item_focus_entered(item):
	item_focused.emit(item)

func _on_unit_selected(unit):
	#var current_selected_count = playerOverworldData.selected_party.size()
	#var max_selected_count = playerOverworldData.available_party_capacity
	#army_convoy_header.set_units_left_value(current_selected_count,max_selected_count)
	unit_selected.emit(unit)

func _on_unit_deselected(unit):
	#var current_selected_count = playerOverworldData.selected_party.size()
	#var max_selected_count = playerOverworldData.available_party_capacity
	#army_convoy_header.set_units_left_value(current_selected_count,max_selected_count)
	unit_deselected.emit(unit)

func get_first_scroll_panel():
	return main_scroll_container.get_child(0)

func _on_item_sent_to_unit(item):
	convoy_item_to_unit.emit(item)

func _on_item_sold(item):
	item_sold.emit(item)
