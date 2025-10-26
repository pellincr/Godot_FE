extends HBoxContainer

signal item_panel_pressed(item)

@onready var main_container: VBoxContainer = $ConvoyScrollContainer/MainContainer


var playerOverworldData : PlayerOverworldData

var focused := false

func set_po_data(po_data):
	playerOverworldData = po_data
	

func fill_convoy_scroll_container():
	for item in playerOverworldData.convoy:
		var item_panel = preload("res://ui/battle_prep_new/item_panel/item_panel_container.tscn").instantiate()
		item_panel.item = item
		main_container.add_child(item_panel)
		item_panel.item_panel_pressed.connect(_on_item_panel_pressed)
		item_panel.focus_entered.connect(_on_item_panel_focused.bind(item))
		if !focused:
			item_panel.grab_focus()
			focused = true

func clear_main_container():
	var children = main_container.get_children()
	for child in children:
		child.queue_free()

func clear_detailed_view_container():
	var children = get_children()
	for child_index in children.size():
		if child_index != 0:
			children[child_index].queue_free()

func _on_item_panel_focused(item):
	clear_detailed_view_container()
	var weapon_detailed_info = preload("res://ui/battle_prep_new/item_detailed_info/weapon_detailed_info.tscn").instantiate()
	weapon_detailed_info.item = item
	add_child(weapon_detailed_info)
	weapon_detailed_info.update_by_item()
	#weapon_detailed_info.layout_direction = Control.LAYOUT_DIRECTION_LTR

func _on_item_panel_pressed(item):
	item_panel_pressed.emit(item)

func reset_convoy_container():
	clear_main_container()
	fill_convoy_scroll_container()
