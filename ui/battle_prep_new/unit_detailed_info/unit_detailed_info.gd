extends Panel
class_name UnitDetailedInfo

const WEAPON_DETAILED_INFO = preload("res://ui/battle_prep_new/item_detailed_info/weapon_detailed_info.tscn")
const CONSUMABLE_ITEM_DETAILED_INFO = preload("res://ui/battle_prep_new/item_detailed_info/consumable_item_detailed_info.tscn")

signal set_trade_item(item,unit)

@onready var unit_name_label = $MarginContainer/HBoxContainer/LeftHalfContainer/UnitNameLabel
@onready var unit_experience_container = $MarginContainer/HBoxContainer/LeftHalfContainer/UnitExperienceInfo

@onready var weapon_icon_container = $MarginContainer/HBoxContainer/LeftHalfContainer/WeaponIconContainer

@onready var current_hp_label = $MarginContainer/HBoxContainer/LeftHalfContainer/HBoxContainer/CurrentHPValueLabel
@onready var hp_bar = $MarginContainer/HBoxContainer/LeftHalfContainer/HPBar

@onready var skills_container = $MarginContainer/HBoxContainer/LeftHalfContainer/SkillsContainer

@onready var unit_inventory_container : = $MarginContainer/HBoxContainer/LeftHalfContainer/UnitInventoryContainer

@onready var combat_stats_container = $MarginContainer/HBoxContainer/RightHalfContainer/CombatStatContainer

@onready var unit_stat_progression = $MarginContainer/HBoxContainer/RightHalfContainer/UnitStatProgression

@onready var unit_icon = $UnitIcon

@onready var faction_banner = $FactionBanner

@onready var item_info_container: CenterContainer = $ItemInfoContainer



var unit : Unit
var block_item_use : bool = false

func _ready():
	if unit != null:
		update_by_unit()

func set_block_item_use(state: bool):
	block_item_use = state
	unit_inventory_container.block_item_use = state

func set_hp_value(hp):
	current_hp_label.text = str(hp) + "/" + str(unit.stats.hp)

func set_hp_bar(hp):
	hp_bar.max_value = unit.stats.hp
	hp_bar.value = hp

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
		#if child_index != 0:
		children[child_index].queue_free()

func _on_unit_inventory_container_item_focused(item) -> void:
	clear_item_info_container()
	if item != null:
		if item is WeaponDefinition:
			var weapon_detailed_info = WEAPON_DETAILED_INFO.instantiate()
			weapon_detailed_info.item = item
			item_info_container.add_child(weapon_detailed_info)
			weapon_detailed_info.update_by_item()
			weapon_detailed_info.layout_direction = Control.LAYOUT_DIRECTION_LTR
		elif item is ConsumableItemDefinition:
			var consumable_item_detailed_info = CONSUMABLE_ITEM_DETAILED_INFO.instantiate()
			consumable_item_detailed_info.item = item
			item_info_container.add_child(consumable_item_detailed_info)
			consumable_item_detailed_info.layout_direction = Control.LAYOUT_DIRECTION_LTR
		elif item is ItemDefinition:
			if item.item_type == ItemConstants.ITEM_TYPE.EQUIPMENT:
				var equipment_detaied_info = preload("res://ui/battle_prep_new/item_detailed_info/equipment_detailed_info.tscn").instantiate()
				equipment_detaied_info.item = item
				item_info_container.add_child(equipment_detaied_info)
				equipment_detaied_info.layout_direction = Control.LAYOUT_DIRECTION_LTR
			elif item.item_type == ItemConstants.ITEM_TYPE.TREASURE:
				var treasure_detaied_info = preload("res://ui/battle_prep_new/item_detailed_info/treasure_detailed_info.tscn").instantiate()
				treasure_detaied_info.item = item
				item_info_container.add_child(treasure_detaied_info)
				treasure_detaied_info.layout_direction = Control.LAYOUT_DIRECTION_LTR


func get_first_inventory_container_slot():
	return unit_inventory_container.inventory_container_slot_1
