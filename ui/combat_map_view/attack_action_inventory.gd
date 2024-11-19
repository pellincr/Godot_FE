extends Control

class_name AttackActionInventory

var selected_item: ItemDefinition
var inventory: Inventory

#Imports
const UnitInventorySlot = preload("res://ui/combat_map_view/unit_inventory_slot.tscn")

static func create(inv: Inventory) -> AttackActionInventory: 
	var a_a_inv = AttackActionInventory.new()
	a_a_inv.set_unit(inv)
	return a_a_inv

func set_inventory(inv: Inventory):
	self.inventory = inv

func get_inventory_container_children() -> Array[Node]:
	return $MarginContainer/VBoxContainer.get_children()
