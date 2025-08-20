extends PanelContainer

class_name UnitArmyPanelContainer

signal unit_selected(unit)
signal unit_deselected(unit)

@onready var check_box : CheckBox = $MarginContainer/Panel/HBoxContainer/CheckBox

@onready var unit_name_label = $MarginContainer/Panel/HBoxContainer/HBoxContainer/UnitNameLabel
@onready var unit_icon = $MarginContainer/Panel/HBoxContainer/HBoxContainer/UnitIcon

var playerOverworldData : PlayerOverworldData

var unit : Unit

var focus_fired = false


func _ready():
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	if unit!= null:
		update_by_unit()
	if check_if_selected():
		check_box.button_pressed = true



func _process(delta):
	if self.has_focus():
		#If the panel is the one that is currently focused
		if check_box.button_pressed:
			#if the unit is selected, set the text to green
			unit_name_label.self_modulate = "FFFFFF"
			self.theme = preload("res://ui/battle_preparation/unit_panel_selected_hovered.tres")
		else:
			unit_name_label.self_modulate = "828282"
			self.theme = preload("res://ui/battle_preparation/unit_panel_not_selected_hovered.tres")
	else:
		if check_box.button_pressed:
			unit_name_label.self_modulate = "FFFFFF"
			self.theme = preload("res://ui/battle_preparation/unit_panel_selected.tres")
		else:
			self.theme = preload("res://ui/battle_preparation/unit_panel_not_selected.tres")

func set_po_data(po_data):
	playerOverworldData = po_data



func _on_mouse_entered():
	self.grab_focus()
	print("Focused")



func set_unit_name_label(name):
	unit_name_label.text = name

func set_unit_icon(icon):
	unit_icon.texture = icon


func update_by_unit():
	set_unit_name_label(unit.name)
	set_unit_icon(unit.icon)

func check_available_space():
	var current_party_size = playerOverworldData.selected_party.size()
	var max_party_size = playerOverworldData.available_party_capacity
	return current_party_size < max_party_size

func check_if_selected():
	return playerOverworldData.selected_party.has(unit)


func _on_gui_input(event):
	if has_focus() and event.is_action_pressed("ui_accept"):
		if !check_box.button_pressed:
			if check_available_space():
				check_box.button_pressed = true
				playerOverworldData.append_to_array(playerOverworldData.selected_party,unit)
				unit_selected.emit(unit)
		else:
			check_box.button_pressed = false
			playerOverworldData.selected_party.erase(unit)
			unit_deselected.emit(unit)
