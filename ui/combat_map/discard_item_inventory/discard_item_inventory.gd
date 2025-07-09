extends Control
class_name ActionInventoryUI

signal item_selection_complete(i: int)

var inventory: Array[ItemDefinition]

func get_inventory_container_children() -> Array[Node]:
	return $PanelContainer/MarginContainer/VboxContainer/InventoryPanel/CenterContainer/Inventory.get_children()

func btn_entered(item: ItemDefinition):
	pass

func discard_item_index_chosen(chosen_index: int):
	item_selection_complete.emit(chosen_index)

func populate_menu(items: Array[ItemDefinition]):
	var item_slots = get_inventory_container_children()
	for i in range(item_slots.size()):
		if item_slots[i] is UnitInventorySlot:
			var item_btn = item_slots[i].get_button() as Button
			item_btn.disabled = false
			if not items.is_empty():
				if items.size() > i:
					var item = items[i]
					item_slots[i].set_all(item)
					item_slots[i].visible = true
					item_btn.pressed.connect(func():
						discard_item_index_chosen(i)
						#kill the menu
						#return the correct value
						)
