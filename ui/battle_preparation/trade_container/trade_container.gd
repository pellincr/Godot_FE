extends VBoxContainer

signal set_trade_item(item,unit)
signal unit_focused(detailed_view)

@onready var army_convoy_subcontainer = $MainContainer/ArmyConvoySubContainer
@onready var main_container = $MainContainer

const unit_detailed_view_simple_scene = preload("res://ui/battle_preparation/unit_detailed_view_simple/unit_detailed_view_simple.tscn")



var playerOverwordData : PlayerOverworldData

func _ready():
	if !playerOverwordData:
		playerOverwordData = PlayerOverworldData.new()
	army_convoy_subcontainer.set_po_data(playerOverwordData)
	fill_army_scroll_container()

func set_po_data(po_data):
	playerOverwordData = po_data


func fill_army_scroll_container():
	army_convoy_subcontainer.fill_army_scroll_container()

func clear_main_container():
	var children = main_container.get_children()
	for child in children:
		if child is Panel:
			child.queue_free()

func _on_unit_focused(unit):
	clear_main_container()
	var unit_detailed_view_simple = unit_detailed_view_simple_scene.instantiate()
	unit_detailed_view_simple.unit = unit
	main_container.add_child(unit_detailed_view_simple)
	unit_detailed_view_simple.set_trade_item.connect(_on_set_trade_item)
	unit_detailed_view_simple.update_by_unit()
	unit_detailed_view_simple.layout_direction = Control.LAYOUT_DIRECTION_LTR
	unit_focused.emit(unit_detailed_view_simple)

func _on_set_trade_item(item,unit):
	set_trade_item.emit(item,unit)

func get_detailed_view():
	return $MainContainer/ArmyConvoySubContainer.get_child(1)
