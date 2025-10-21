extends Control
class_name TradeUnitInventory

signal item_selected(item: ItemDefinition, item_index: int, unit: Unit)
signal item_hovered(item : ItemDefinition)

var unit: Unit

@onready var unit_inventory_slot_1: UnitInventorySlot = $Background/MarginContainer/VBoxContainer/Inventory/UnitInventorySlot
@onready var unit_inventory_slot_2: UnitInventorySlot = $Background/MarginContainer/VBoxContainer/Inventory/UnitInventorySlot2
@onready var unit_inventory_slot_3: UnitInventorySlot = $Background/MarginContainer/VBoxContainer/Inventory/UnitInventorySlot3
@onready var unit_inventory_slot_4: UnitInventorySlot = $Background/MarginContainer/VBoxContainer/Inventory/UnitInventorySlot4
@onready var unit_name_label: Label = $Background/MarginContainer/VBoxContainer/HeaderPanel/UnitName

static func create(target_unit: Unit) -> TradeUnitInventory: 
	var tui = TradeUnitInventory.new()
	tui.set_unit(target_unit)
	tui.update_fields()
	return tui

func _ready() -> void:
	pass

func configure_btns():
	#set buttons to toggle mode
	unit_inventory_slot_1.toggle_mode = true
	unit_inventory_slot_2.toggle_mode = true
	unit_inventory_slot_3.toggle_mode = true
	unit_inventory_slot_4.toggle_mode = true
	#connect the buttons to the correct method
	unit_inventory_slot_1.connect("selected_item", _on_button_item_selected.bind(1))
	unit_inventory_slot_2.connect("selected_item", _on_button_item_selected.bind(2))
	unit_inventory_slot_3.connect("selected_item", _on_button_item_selected.bind(3))
	unit_inventory_slot_4.connect("selected_item", _on_button_item_selected.bind(4))

func set_unit(target_unit: Unit):
	self.unit = target_unit

func update_fields():
	update_name()
	update_iventory_btns()
	configure_btns()

func update_iventory_btns():
	#get unit inventory
	set_inventory_btn_info(unit_inventory_slot_1,unit.inventory.get_item(0),unit.inventory.equipped)
	set_inventory_btn_info(unit_inventory_slot_2,unit.inventory.get_item(1))
	set_inventory_btn_info(unit_inventory_slot_3,unit.inventory.get_item(2))
	set_inventory_btn_info(unit_inventory_slot_4,unit.inventory.get_item(3))

func set_inventory_btn_info(slot:UnitInventorySlot, item:ItemDefinition, equipped: bool = false):
	if item != null:
		slot.set_fields(item, equipped)
	else: 
		slot.set_fields(null, false)
func set_unit_inventory_slot_info(target:UnitInventorySlot, item:ItemDefinition, equipped: bool = false, valid : bool = false):
	target.disabled = !valid
	target.set_fields(item, equipped)

func get_inventory_container_children() -> Array[Node]:
	return $Background/MarginContainer/VBoxContainer/Inventory.get_children()

func update_name():
	unit_name_label.text = unit.name

func clear_action_button_connections(action: Button):
	var connections = action.pressed.get_connections()
	for connection in connections:
		action.pressed.disconnect(connection.callable)

func set_selected_item(item_index: int, item: ItemDefinition):
	#self.selected_item = item
	item_selected.emit(item_index, item, unit)

func reset_btns():
	unit_inventory_slot_1.button_pressed = false
	unit_inventory_slot_2.button_pressed = false
	unit_inventory_slot_3.button_pressed = false
	unit_inventory_slot_4.button_pressed = false

func _on_button_item_selected(item: ItemDefinition, index: int):
	item_selected.emit(item, index, self.unit)

func _on_item_hovered(item: ItemDefinition):
	item_hovered.emit(item)

func grab_primary_btn_focus():
	unit_inventory_slot_1.grab_focus()
