extends VBoxContainer

signal item_equipped(item)
signal set_trade_item(item)

@onready var inventory_slot_1 = $PanelContainer/MarginContainer/VBoxContainer/InventoryContainerSlot
@onready var inventory_slot_2 = $PanelContainer/MarginContainer/VBoxContainer/InventoryContainerSlot2
@onready var inventory_slot_3 = $PanelContainer/MarginContainer/VBoxContainer/InventoryContainerSlot3
@onready var inventory_slot_4 = $PanelContainer/MarginContainer/VBoxContainer/InventoryContainerSlot4
@onready var inventory_slot_5 = $PanelContainer/MarginContainer/VBoxContainer/InventoryContainerSlot5

@onready var inventory_slot_array = [inventory_slot_1,inventory_slot_2,inventory_slot_3,inventory_slot_4,inventory_slot_5]

@onready var equipping_item = true

const equipped_icon = preload("res://ui/battle_preparation/E.png")

var unit :Unit


func _ready():
	if unit != null:
		update_by_unit()


func clear_slot(inventory_slot):
	inventory_slot.set_item_name_label("")
	inventory_slot.set_item_uses(-1)
	inventory_slot.set_invetory_item_icon(null)

func set_inventory_slot(item:ItemDefinition, slot):
	if item != null:
		slot.item = item
		slot.update_by_item()

func update_by_unit():
	for slot_index in inventory_slot_array.size():
		if slot_index < unit.inventory.items.size():
			set_inventory_slot(unit.inventory.items[slot_index], inventory_slot_array[slot_index])
			if unit.inventory.items[slot_index] == unit.inventory.equipped:
				var texture = TextureRect.new()
				texture.texture = equipped_icon
				inventory_slot_array[slot_index].inventory_item_icon.add_child(texture)
		else:
			clear_slot(inventory_slot_array[slot_index])

func clear_equipped_symbol(): #NOT WORKING
	for slot in inventory_slot_array:
		var children = slot.get_children()
		for child in children:
			if child is TextureRect and child.texture == equipped_icon:
				child.queue_free()

func set_inventory_for_trade_true():
	for slot in inventory_slot_array:
		slot.set_for_trade = true

func set_inventory_for_trade_false():
	for slot in inventory_slot_array:
		slot.set_for_trade = false


func _on_item_equipped(item):
	unit.set_equipped(item)
	clear_equipped_symbol()
	update_by_unit()
	item_equipped.emit(item)

func _on_item_set_for_trade(item):
	set_trade_item.emit(item)
