extends Control

class_name AttackActionInventory

#var selected_item: ItemDefinition
var unit: Unit
var inventory: Array[ItemDefinition]
var equippable_item_info : EquippableItemInformation
#Imports
const UnitInventorySlot = preload("res://ui/combat_map_view_components/unit_inventory_slot/unit_inventory_slot.tscn")

func _ready():
	equippable_item_info = $Equippable_item_information

func hide_equippable_item_info():
	equippable_item_info.visible = false

func show_equippable_item_info():
	equippable_item_info.visible = true
static func create(target_unit: Unit) -> AttackActionInventory: 
	var a_a_inv = AttackActionInventory.new()
	a_a_inv.set_unit(target_unit)
	return a_a_inv

func set_unit(target_unit: Unit):
	self.unit = target_unit
	equippable_item_info.set_unit(target_unit)

func get_inventory_container_children() -> Array[Node]:
	return $MarginContainer/VBoxContainer.get_children()

func btn_entered(item: ItemDefinition):
	if item is WeaponDefinition:
		equippable_item_info.update_values(item)
