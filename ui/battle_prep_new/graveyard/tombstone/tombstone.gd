extends VBoxContainer

signal unit_revived(unit:Unit, cost : int)

@onready var unit_icon: TextureRect = $PanelContainer/MarginContainer/UnitContainer/UnitIcon
@onready var unit_name_label: Label = $PanelContainer/MarginContainer/UnitContainer/UnitNameLabel

@onready var revive_button: GeneralMenuButton = $ReviveButton

var unit : Unit

func _ready() -> void:
	#unit = Unit.create_generic_unit("fighter",[],"Test",1)
	#unit.death_count = 1
	revive_button.grab_focus()
	if unit:
		update_by_unit()

func update_by_unit():
	update_unit_icon(unit.icon)
	update_unit_name_label(unit.name)
	update_revive_button_cost(calc_revive_cost())

func update_unit_icon(icon):
	unit_icon.texture = icon

func update_unit_name_label(txt):
	unit_name_label.text = txt

func update_revive_button_cost(cost):
	revive_button.text = "Revive: " + str(cost) + "G"

func calc_revive_cost():
	var base_cost = 1000
	var unit_def := unit.get_unit_type_definition()
	return base_cost * unit.level * unit_def.tier * unit.death_count


func _on_revive_button_pressed() -> void:
	unit_revived.emit(unit,calc_revive_cost())
