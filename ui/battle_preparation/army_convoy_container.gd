extends VBoxContainer

signal unit_focused(unit)
signal unit_selected(unit)


var playerOverworldData : PlayerOverworldData

@onready var army_convoy_header = $ArmyConvoyHeader

@onready var main_scroll_container = $ScrollContainer/VBoxContainer


const unit_army_panel_container_scene = preload("res://ui/battle_preparation/unit_army_panel_container.tscn")
const convoy_item_panel_container_scene = preload("res://ui/battle_preparation/convoy_item_panel_container.tscn")

@onready var temp = 4

enum CONTAINER_STATE{
	ARMY, CONVOY
}

var current_container_state = CONTAINER_STATE.ARMY

func _ready():
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	fill_army_scroll_container()

func set_po_data(po_data):
	playerOverworldData = po_data


func fill_army_scroll_container():
	for unit in playerOverworldData.total_party:
		var unit_army_panel_container = unit_army_panel_container_scene.instantiate()
		unit_army_panel_container.unit = unit
		main_scroll_container.add_child(unit_army_panel_container)
		unit_army_panel_container.focus_entered.connect(unit_focus_entered.bind(unit))
	var test = main_scroll_container.get_child(0)
	if(test):
		test.grab_focus()

func fill_convoy_scroll_container():
	var i = 0
	while i < temp:
		var convoy_item_panel_container = convoy_item_panel_container_scene.instantiate()
		main_scroll_container.add_child(convoy_item_panel_container)
		i += 1

func clear_scroll_scontainer():
	var children = main_scroll_container.get_children()
	for child in children:
		child.queue_free()


func _on_army_convoy_header_header_swapped():
	match current_container_state:
		CONTAINER_STATE.ARMY:
			current_container_state = CONTAINER_STATE.CONVOY
			clear_scroll_scontainer()
			fill_convoy_scroll_container()
		CONTAINER_STATE.CONVOY:
			current_container_state = CONTAINER_STATE.ARMY
			clear_scroll_scontainer()
			fill_army_scroll_container()


func unit_focus_entered(unit):
	unit_focused.emit(unit)
