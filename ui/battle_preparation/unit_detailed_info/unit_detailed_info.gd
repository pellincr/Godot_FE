extends Panel

@onready var unit_name_label = $MarginContainer/HBoxContainer/LeftHalfContainer/UnitNameLabel
@onready var unit_experience_container = $MarginContainer/HBoxContainer/LeftHalfContainer/UnitExperienceInfo

@onready var weapon_icon_container = $MarginContainer/HBoxContainer/LeftHalfContainer/WeaponIconContainer

@onready var current_hp_label = $MarginContainer/HBoxContainer/LeftHalfContainer/HBoxContainer/CurrentHPValueLabel
@onready var hp_bar = $MarginContainer/HBoxContainer/LeftHalfContainer/HPBar

@onready var skills_container = $MarginContainer/HBoxContainer/LeftHalfContainer/SkillsContainer

@onready var unit_inventory_container = $MarginContainer/HBoxContainer/LeftHalfContainer/UnitInventoryContainer

@onready var combat_stats_container = $MarginContainer/HBoxContainer/RightHalfContainer/CombatStatContainer

@onready var unit_stat_progression = $MarginContainer/HBoxContainer/RightHalfContainer/UnitStatProgression

@onready var unit_icon = $UnitIcon

@onready var faction_banner = $FactionBanner



var unit : Unit



func _ready():
	if unit != null:
		update_by_unit()


func set_hp_value(hp):
	current_hp_label.text = str(hp) + "/" + str(unit.stats.hp)

func set_hp_bar(hp):
	hp_bar.value = hp
	hp_bar.max_value = unit.stats.hp

func update_unit_icon(icon):
	unit_icon.texture = icon

func set_unit_name_label(name):
	unit_name_label.text = name

func update_by_unit():
	weapon_icon_container.unit = unit
	weapon_icon_container.set_icon_visibility()
	unit_experience_container.unit = unit
	unit_experience_container.update_by_unit()
	unit_stat_progression.unit = unit
	unit_stat_progression.update_by_unit()
	set_unit_name_label(unit.name)
	set_hp_value(unit.stats.hp)
	set_hp_bar(unit.stats.hp)
	unit_inventory_container.unit = unit
	unit_inventory_container.update_by_unit()
	update_unit_icon(unit.icon)
