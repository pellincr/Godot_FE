extends Panel
class_name SupportActionInventory

#Imports
const UNIT_INVENTORY_SLOT = preload("res://ui/combat/shared/unit_inventory_slot/unit_inventory_slot.tscn")

@onready var unit_inventory_slot_1: UnitInventorySlot = $MarginContainer2/VBoxContainer/VBoxContainer2/UnitInventorySlot1
@onready var unit_inventory_slot_2: UnitInventorySlot = $MarginContainer2/VBoxContainer/VBoxContainer2/UnitInventorySlot2
@onready var unit_inventory_slot_3: UnitInventorySlot = $MarginContainer2/VBoxContainer/VBoxContainer2/UnitInventorySlot3
@onready var unit_inventory_slot_4: UnitInventorySlot = $MarginContainer2/VBoxContainer/VBoxContainer2/UnitInventorySlot4
@onready var backButton: Button = $MarginContainer2/VBoxContainer/VBoxContainer2/BackButton

@onready var equippable_item_information: EquippableItemInformation = $MarginContainer2/VBoxContainer/Equippable_item_information

signal item_selected(item:ItemDefinition)
signal new_item_hovered(item:ItemDefinition)
signal back()

@export var data : Array[UnitInventorySlotData] 
@export var combatUnit: CombatUnit
@export var hovered_item : ItemDefinition
var focus_grabbed : bool

func _ready() -> void:
	unit_inventory_slot_1.connect("_hover_item", reset_focus)
	unit_inventory_slot_2.connect("_hover_item", update_hover_item)
	unit_inventory_slot_3.connect("_hover_item", update_hover_item)
	unit_inventory_slot_4.connect("_hover_item", update_hover_item)
	unit_inventory_slot_1.connect("selected_item",item_selected_button_press)
	unit_inventory_slot_2.connect("selected_item",item_selected_button_press)
	unit_inventory_slot_3.connect("selected_item",item_selected_button_press)
	unit_inventory_slot_4.connect("selected_item",item_selected_button_press)
	backButton.connect("pressed", back_btn_pressed)

func populate(inputCombatUnit : CombatUnit, inventory: Array[UnitInventorySlotData]):
	await equippable_item_information
	self.combatUnit = inputCombatUnit
	self.data = inventory
	update_display()

func update_display():
	equippable_item_information.populate_equipped_stats(combatUnit.stats,combatUnit.get_equipped())
	if data.size() == 4:
		set_unit_inventory_slot_info(unit_inventory_slot_1, data[0].item, data[0].equipped, data[0].valid)
		set_unit_inventory_slot_info(unit_inventory_slot_2, data[1].item, data[1].equipped, data[1].valid)
		set_unit_inventory_slot_info(unit_inventory_slot_3, data[2].item, data[2].equipped, data[2].valid)
		set_unit_inventory_slot_info(unit_inventory_slot_4, data[3].item, data[3].equipped, data[3].valid)

func set_unit_inventory_slot_info(target:UnitInventorySlot, item:ItemDefinition, equipped: bool = false, valid : bool = false):
	target.disabled = !valid
	target.set_fields(item, equipped)
	if valid and focus_grabbed == false:
		target.grab_focus()
		focus_grabbed = true
		update_hover_item(item)
		

func update_hover_item(item: ItemDefinition):
	if item is WeaponDefinition:
		equippable_item_information.update_hover_stats(combatUnit, item)
		new_item_hovered.emit(item)
		

func reset_focus(item: ItemDefinition):
	equippable_item_information.hovering_new_item = false
	equippable_item_information.update_fields()
	new_item_hovered.emit(item)
	

func item_selected_button_press(item: ItemDefinition):
	item_selected.emit(item)

func back_btn_pressed():
	back.emit()
