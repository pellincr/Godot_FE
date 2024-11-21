extends Control

class_name AttackActionInventory

#var selected_item: ItemDefinition
var unit: Unit
var inventory: Inventory
var equippable_item_info : EquippableItemInformation
#Imports
const UnitInventorySlot = preload("res://ui/combat_map_view/unit_inventory_slot.tscn")

func _ready():
	equippable_item_info = $Equippable_item_information
	

static func create(unit: Unit) -> AttackActionInventory: 
	var a_a_inv = AttackActionInventory.new()
	a_a_inv.set_unit(unit)
	return a_a_inv

func set_unit(unit: Unit):
	self.unit = unit
	self.inventory = unit.inventory
	equippable_item_info.set_unit(unit)

func get_inventory_container_children() -> Array[Node]:
	return $MarginContainer/VBoxContainer.get_children()

func btn_entered(item: ItemDefinition):
	print("attack item btn entered")
	equippable_item_info.update_values(item)
	
