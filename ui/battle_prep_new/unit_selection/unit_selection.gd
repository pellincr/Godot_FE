extends HBoxContainer

signal return_to_menu()
signal unit_selected(unit:Unit)
signal unit_deselected(unit:Unit)

@onready var army_container: HBoxContainer = $VBoxContainer/ArmyContainer
@onready var units_left_value_label: Label = $VBoxContainer/UnitSelectionHeader/UnitsLeftValueLabel

var playerOverworldData : PlayerOverworldData

func _ready() -> void:
	var campaign_level = playerOverworldData.current_level.instantiate() #playerOverworldData.current_campaign.levels[playerOverworldData.current_level].instantiate()
	#print(str(campaign_level.get_children()))
	var combat = campaign_level.get_child(2)
	playerOverworldData.available_party_capacity = combat.ally_spawn_tiles.size()
	SelectedSaveFile.save(playerOverworldData)
	army_container.unit_selection = true
	army_container.set_po_data(playerOverworldData)
	army_container.fill_army_scroll_container()
	set_units_left_value(playerOverworldData.selected_party.size(),playerOverworldData.available_party_capacity)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		return_to_menu.emit()
		queue_free()

func set_po_data(po_data):
	playerOverworldData = po_data

#func _on_army_scroll_container_unit_selected(unit: Unit) -> void:
#	unit_selected.emit(unit)


#func _on_army_scroll_container_unit_deselected(unit: Unit) -> void:
#	unit_deselected.emit(unit)

func clear_unit_detailed_view():
	if get_child_count() > 1:
		get_child(1).queue_free()

func set_units_left_value(left,total):
	units_left_value_label.text = str(left) + "/" + str(total)

func check_available_space():
	var current_party_size = playerOverworldData.selected_party.size()
	var max_party_size = playerOverworldData.available_party_capacity
	return current_party_size < max_party_size

func check_if_selected(unit:Unit):
	return playerOverworldData.selected_party.has(unit)


func _on_army_scroll_container_unit_panel_pressed(unit: Unit) -> void:
	if check_if_selected(unit):
	#If the unit is selected and it was pressed, deselect it
		playerOverworldData.selected_party.erase(unit)
		army_container.set_unit_panel_deselected(unit)
		unit_deselected.emit(unit)
	else:
		if check_available_space():
			playerOverworldData.selected_party.append(unit)
			army_container.set_unit_panel_selected(unit)
			unit_selected.emit(unit)
	set_units_left_value(playerOverworldData.selected_party.size(),playerOverworldData.available_party_capacity)

func grab_first_army_panel_focus():
	army_container.grab_first_army_panel_focus()
