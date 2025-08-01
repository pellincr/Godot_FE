extends PanelContainer

class_name UnitArmyPanelContainer

signal unit_selected(unit)
signal unit_deselected(unit)

@onready var check_box : CheckBox = $MarginContainer/Panel/HBoxContainer/CheckBox

@onready var unit_name_label = $MarginContainer/Panel/HBoxContainer/HBoxContainer/UnitNameLabel
@onready var unit_icon = $MarginContainer/Panel/HBoxContainer/HBoxContainer/UnitIcon

var unit : Unit

var focus_fired = false


func _ready():
	if unit!= null:
		update_by_unit()

func _process(delta):
	if Input.is_action_just_pressed("ui_confirm") and self.has_focus():
		check_box.button_pressed = !check_box.button_pressed
		
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



func _on_check_box_pressed():
	if check_box.button_pressed:
		unit_selected.emit()
	else:
		unit_deselected.emit()



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
