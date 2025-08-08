extends Control
class_name DiscardItemInventory

var inventory: Array[ItemDefinition]
var index : int

func get_inventory_container_children() -> Array[Node]:
	return $PanelContainer/MarginContainer/VboxContainer/InventoryPanel/CenterContainer/Inventory.get_children()

func btn_entered(item: ItemDefinition):
	pass
