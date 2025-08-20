extends Control
class_name UnitFooterInventoryContainer

@export var inventory : Inventory


func set_inventory(inv: Inventory):
	self.inventory = inv
	update()

func update():
	update_equipped()
	update_slot2()
	update_slot3()
	update_slot4()
	update_slot5()	

func update_equipped():
	if inventory.equipped: 
		$UnitInventoryContainer/InventoryPanelBack/InventoryContainer/MarginContainer/SelectedItemContainer/EquippedItemName.text = inventory.get_equipped_weapon().name
		$UnitInventoryContainer/InventoryPanelBack/InventoryContainer/MarginContainer/SelectedItemContainer/InventoryItemIcon.set_item(inventory.get_equipped_weapon())

func update_slot2():
	if inventory.get_item(1):
		$UnitInventoryContainer/InventoryPanelBack/InventoryContainer/MarginContainer2/InventoryItemIcon.set_item(inventory.get_item(1))
	else:
		$UnitInventoryContainer/InventoryPanelBack/InventoryContainer/MarginContainer2/InventoryItemIcon.clear_item()

func update_slot3():
	if inventory.get_item(2):
		$UnitInventoryContainer/InventoryPanelBack/InventoryContainer/MarginContainer3/InventoryItemIcon.set_item(inventory.get_item(2))
	else:
		$UnitInventoryContainer/InventoryPanelBack/InventoryContainer/MarginContainer3/InventoryItemIcon.clear_item()
		
func update_slot4():
	if inventory.get_item(3):
		$UnitInventoryContainer/InventoryPanelBack/InventoryContainer/MarginContainer4/InventoryItemIcon.set_item(inventory.get_item(3))
	else:
		$UnitInventoryContainer/InventoryPanelBack/InventoryContainer/MarginContainer4/InventoryItemIcon.clear_item()
		
func update_slot5():
	if inventory.get_item(4):
		$UnitInventoryContainer/InventoryPanelBack/InventoryContainer/MarginContainer5/InventoryItemIcon.set_item(inventory.get_item(4))
	else:
		$UnitInventoryContainer/InventoryPanelBack/InventoryContainer/MarginContainer5/InventoryItemIcon.clear_item()
