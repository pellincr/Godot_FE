extends Panel


const WEAPON_DETAILED_INFO = preload("res://ui/battle_prep_new/item_detailed_info/weapon_detailed_info.tscn")

signal set_trade_item(item,unit)

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

@onready var item_info_container: CenterContainer = $ItemInfoContainer



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
	weapon_icon_container.set_icon_visibility_unit()
	unit_experience_container.unit = unit
	unit_experience_container.update_by_unit()
	unit_stat_progression.unit = unit
	unit_stat_progression.update_by_unit()
	set_unit_name_label(unit.name)
	set_hp_value(unit.hp)
	set_hp_bar(unit.hp)
	unit_inventory_container.unit = unit
	unit_inventory_container.update_by_unit()
	update_unit_icon(unit.icon)
	combat_stats_container.unit = unit
	combat_stats_container.update_by_unit()

func _on_unit_inventory_item_entered(item):
	pass
	
func _on_unit_inventory_item_focus_exited():
	pass

func _on_unit_inventory_container_item_equipped(item):
	combat_stats_container.unit = unit
	combat_stats_container.update_by_unit()

func _on_set_trade_item(item):
	set_trade_item.emit(item, unit)
	update_by_unit()
	

func _on_unit_inventory_container_item_used(item):
	update_by_unit()
	


func clear_item_info_container():
	var children = item_info_container.get_children()
	for child_index in children.size():
		if child_index != 0:
			children[child_index].queue_free()

func _on_unit_inventory_container_item_focused(item) -> void:
	clear_item_info_container()
	if item != null:
		var weapon_detailed_info = WEAPON_DETAILED_INFO.instantiate()
		weapon_detailed_info.item = item
		item_info_container.add_child(weapon_detailed_info)
		weapon_detailed_info.update_by_item()
		weapon_detailed_info.layout_direction = Control.LAYOUT_DIRECTION_LTR
		
