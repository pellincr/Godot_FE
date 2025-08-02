extends Panel

@onready var unit_name_label = $MarginContainer/VBoxContainer/UnitNameLabel
@onready var unit_icon = $UnitIcon

@onready var unit_experience_info = $MarginContainer/VBoxContainer/UnitExperienceInfo
@onready var weapon_icon_container = $MarginContainer/VBoxContainer/WeaponIconContainer

@onready var current_hp_value_label = $MarginContainer/VBoxContainer/HBoxContainer/CurrentHPValueLabel
@onready var hp_bar = $MarginContainer/VBoxContainer/HPBar

@onready var combat_stat_container = $MarginContainer/VBoxContainer/CombatStatContainer
@onready var unit_inventory_container = $MarginContainer/VBoxContainer/UnitInventoryContainer

var unit : Unit

func _ready():
	if unit:
		update_by_unit()


func set_unit_name_label(name):
	unit_name_label.text = name

func set_unit_icon(icon):
	unit_icon.texture = icon

func set_hp_value(hp):
	current_hp_value_label.text = str(hp) + "/" + str(unit.stats.hp)

func set_hp_bar(hp):
	hp_bar.value = hp
	hp_bar.max_value = unit.stats.hp

func update_by_unit():
	set_unit_name_label(unit.name)
	set_unit_icon(unit.icon)
	set_hp_value(unit.hp)
	set_hp_bar(unit.hp)
	unit_experience_info.unit = unit
	unit_experience_info.update_by_unit()
	weapon_icon_container.unit = unit
	weapon_icon_container.set_icon_visibility_unit()
	combat_stat_container.unit = unit
	combat_stat_container.update_by_unit()
	unit_inventory_container.unit = unit
	unit_inventory_container.update_by_unit()
