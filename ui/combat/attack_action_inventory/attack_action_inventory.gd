extends Panel
class_name AttackActionInventory

#Imports
const UNIT_INVENTORY_SLOT = preload("res://ui/combat/shared/unit_inventory_slot/unit_inventory_slot.tscn")

@export var unit: Unit
var equippable_item_info : EquippableItemInformation
var equipped_item_info: EquippableItemInformation
var hover_item_info: EquippableItemInformation

@onready var unit_inventory_slot: UnitInventorySlot = $MarginContainer2/VBoxContainer/VBoxContainer2/UnitInventorySlot
@onready var unit_inventory_slot_2: UnitInventorySlot = $MarginContainer2/VBoxContainer/VBoxContainer2/UnitInventorySlot2
@onready var unit_inventory_slot_4: UnitInventorySlot = $MarginContainer2/VBoxContainer/VBoxContainer2/UnitInventorySlot4
@onready var backButton: Button = $MarginContainer2/VBoxContainer/VBoxContainer2/BackButton

@onready var equippable_item_information: EquippableItemInformation = $MarginContainer2/VBoxContainer/Equippable_item_information


func _ready():
	equippable_item_info = $Equippable_item_information

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
