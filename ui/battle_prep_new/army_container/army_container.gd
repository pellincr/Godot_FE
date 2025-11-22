extends HBoxContainer


#signal unit_selected(unit:Unit)
#signal unit_deselected(unit:Unit)
signal unit_panel_pressed(unit:Unit)
signal convoy_panel_pressed()

@onready var main_scroll_container: VBoxContainer = $ArmyScrollContainer/MainScrollContainer


var unit_army_panel_container_scene = preload("res://ui/battle_prep_new/unit_army_panel/unit_army_panel_container.tscn")

var playerOverworldData : PlayerOverworldData
var units_list : Array

var focused := false

var unit_selection := false
var unit_panels = []

func set_po_data(po_data):
	playerOverworldData = po_data

func set_units_list(u_list):
	units_list = u_list

func get_unit_panel_from_container(unit:Unit):
	for unit_panel in unit_panels:
		if unit_panel.unit == unit:
			return unit_panel

func fill_army_scroll_container(add_convoy:=false):
	for unit in units_list:
		var unit_army_panel_container = unit_army_panel_container_scene.instantiate()
		unit_army_panel_container.unit = unit
		#unit_army_panel_container.set_po_data(playerOverworldData)
		main_scroll_container.add_child(unit_army_panel_container)
		unit_panels.append(unit_army_panel_container)
		if !focused:
			unit_army_panel_container.grab_focus.call_deferred()
			focused = true
		unit_army_panel_container.focus_entered.connect(unit_focus_entered.bind(unit))
		#unit_army_panel_container.unit_selected.connect(_on_unit_selected)
		#unit_army_panel_container.unit_deselected.connect(_on_unit_deselected)
		unit_army_panel_container.unit_panel_pressed.connect(_on_unit_panel_pressed)
		unit_army_panel_container.set_checkbox_visibility(unit_selection)
		if check_if_selected(unit):
			set_unit_panel_selected(unit)
	if add_convoy:
		var convoy_panel = preload("res://ui/battle_prep_new/convoy/convoy_panel/convoy_panel.tscn").instantiate()
		convoy_panel.convoy_panel_pressed.connect(_on_convoy_panel_pressed)
		main_scroll_container.add_child(convoy_panel)

func unit_focus_entered(unit):
	var unit_detailed_info = preload("res://ui/battle_prep_new/unit_detailed_info/unit_detailed_info.tscn").instantiate()
	unit_detailed_info.unit = unit
	var unit_panel = get_unit_panel_from_container(unit)
	clear_detailed_view()
	add_child(unit_detailed_info)
	unit_panel.focus_neighbor_right = unit_detailed_info.get_first_inventory_container_slot().get_path()
	unit_detailed_info.unit_inventory_container.set_inventory_slots_left_focus_neighbor(unit_panel.get_path())

func _on_unit_panel_pressed(unit:Unit):
	unit_panel_pressed.emit(unit)

func clear_detailed_view():
	var children = get_children()
	for child_index in get_child_count():
		if child_index > 0:
			get_child(child_index).queue_free()


func clear_scroll_container():
	var children = main_scroll_container.get_children()
	for child in children:
		child.queue_free()
		focused = false
		unit_panels = []

func set_unit_panel_selection(unit:Unit, selected:bool):
	for unit_panel in unit_panels:
		if unit_panel.unit == unit:
			unit_panel.selected = selected


func set_unit_panel_selected(unit:Unit):
	set_unit_panel_selection(unit,true)

func set_unit_panel_deselected(unit:Unit):
	set_unit_panel_selection(unit,false)

func check_if_selected(unit:Unit):
	return playerOverworldData.selected_party.has(unit)

func _on_convoy_panel_pressed():
	convoy_panel_pressed.emit()

func disable_army_container_focus():
	var children = main_scroll_container.get_children()
	for child in children:
		child.focus_mode = Control.FOCUS_NONE

func enable_army_container_focus():
	var children = main_scroll_container.get_children()
	for child in children:
		child.focus_mode = Control.FOCUS_ALL

func grab_first_army_panel_focus():
	main_scroll_container.get_child(0).grab_focus()

func remove_unit_panel(unit):
	var unit_army_panels = main_scroll_container.get_children()
	for army_panel in unit_army_panels:
		if army_panel.unit == unit:
			army_panel.queue_free()
			unit_panels.erase(army_panel)
	
	grab_first_army_panel_focus()
