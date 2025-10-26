extends Panel

signal set_trade_item(item,unit)
signal sell_item(item)
signal send_item_to_convoy(item)

@onready var unit_name_label = $MarginContainer/VBoxContainer/UnitNameLabel
@onready var unit_icon = $UnitIcon

@onready var unit_experience_info = $MarginContainer/VBoxContainer/UnitExperienceInfo
@onready var weapon_icon_container = $MarginContainer/VBoxContainer/WeaponIconContainer

@onready var current_hp_value_label = $MarginContainer/VBoxContainer/HBoxContainer/CurrentHPValueLabel
@onready var hp_bar = $MarginContainer/VBoxContainer/HPBar

@onready var combat_stat_container = $MarginContainer/VBoxContainer/CombatStatContainer
@onready var unit_inventory_container = $MarginContainer/VBoxContainer/UnitInventoryContainer
@onready var constitution_value_label: Label = $MarginContainer/VBoxContainer/CombatStatContainer/ConstitutionContainer/ConstitutionValueLabel



var unit : Unit
#var trade = true

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

func set_constitution(con):
	constitution_value_label.text = str(con)

func update_by_unit():
	set_unit_name_label(unit.name)
	set_unit_icon(unit.icon)
	set_constitution(unit.stats.constitution)
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
	reset_inventory_selection_theme()

	#unit_inventory_container.set_trade_item.connect(_on_set_trade_item)

func _on_set_trade_item(item):
	set_trade_item.emit(item, unit)

func ready_for_trade():
	unit_inventory_container.set_inventory_for_trade_true()

func ready_for_sale():
	unit_inventory_container.set_inventory_for_sale_true()

func no_trading():
	unit_inventory_container.set_inventory_for_trade_false()

func reset_inventory_selection_theme():
	var inventory_slots = unit_inventory_container.get_inventory_slots()
	for slot in inventory_slots:
		slot.theme = preload("res://ui/battle_prep_new/inventory_not_focused.tres")


func _on_unit_inventory_container_item_used(item):
	update_by_unit()


func _on_unit_inventory_container_sell_item(item):
	#sell_item.emit(item,unit)
	sell_item.emit(item)


func set_invetory_state(state:InventoryContainer.INVENTORY_STATE):
	unit_inventory_container.set_current_state(state)


func _on_unit_inventory_container_send_to_convoy(item: Variant) -> void:
	send_item_to_convoy.emit(item)

func grab_first_inventory_slot_focus():
	unit_inventory_container.grab_first_slot_focus()

func clear_item_detail_panel():
	if get_child(2):
		get_child(2).queue_free()


func _on_unit_inventory_container_item_focused(item: Variant) -> void:
	clear_item_detail_panel()
	if item != null:
		var weapon_detailed_info = preload("res://ui/battle_prep_new/item_detailed_info/weapon_detailed_info.tscn").instantiate()
		weapon_detailed_info.item = item
		add_child(weapon_detailed_info)
		weapon_detailed_info.update_by_item()
		weapon_detailed_info.set_position(Vector2(330,20))
