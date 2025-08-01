extends PanelContainer

class_name UnitArmyPanelContainer

signal unit_selected()
signal unit_deselected()
signal unit_hovered(unit)
signal unit_exited()

@onready var check_box : CheckBox = $MarginContainer/Panel/HBoxContainer/CheckBox

@onready var unit_name_label = $MarginContainer/Panel/HBoxContainer/HBoxContainer/UnitNameLabel
@onready var unit_icon = $MarginContainer/Panel/HBoxContainer/HBoxContainer/UnitIcon

var unit : Unit

var focus = false


func _ready():
	if unit!= null:
		update_by_unit()



func _on_check_box_pressed():
	if check_box.button_pressed:
		unit_name_label.self_modulate = "FFFFFF"
		self.theme = preload("res://ui/battle_preparation/unit_panel_selected_hovered.tres")
		unit_selected.emit()
	else:
		unit_name_label.self_modulate = "828282"
		self.theme = preload("res://ui/battle_preparation/unit_panel_not_selected_hovered.tres")
		unit_deselected.emit()



func _on_mouse_entered():
	if check_box.button_pressed:
		self.theme = preload("res://ui/battle_preparation/unit_panel_selected_hovered.tres")
	else:
		self.theme = preload("res://ui/battle_preparation/unit_panel_not_selected_hovered.tres")
	unit_hovered.emit(unit)
	print("Hovered")


func _on_mouse_exited():
	if check_box.button_pressed:
		self.theme = preload("res://ui/battle_preparation/unit_panel_selected.tres")
	else:
		self.theme = preload("res://ui/battle_preparation/unit_panel_not_selected.tres")
	unit_exited.emit()
	print("Exited")



func set_unit_name_label(name):
	unit_name_label.text = name

func set_unit_icon(icon):
	unit_icon.texture = icon


func update_by_unit():
	set_unit_name_label(unit.name)
	set_unit_icon(unit.icon)
