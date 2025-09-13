extends Button
class_name UnitInventorySlot

const UNIT_INVENTORY_SLOT_DISABLED = preload("res://ui/combat/shared/unit_inventory_slot/unit_inventory_slot_disabled.tres")
const UNIT_INVENTORY_SLOT_ENABLED = preload("res://ui/combat/shared/unit_inventory_slot/unit_inventory_slot_enabled.tres")
#Signals
signal _hover_item(item: ItemDefinition)
signal selected_item(item: ItemDefinition)

#Export
@export var item : ItemDefinition
@export var equipped : bool

#onready vars (references to ui components)
@onready var inventory_item_icon: InventoryItemIcon = $MarginContainer/HBoxContainer/LeftContainer/InventoryItemIcon
@onready var item_name_label: Label = $MarginContainer/HBoxContainer/LeftContainer/ItemNameLabel
@onready var item_type_icon: ItemTypeIcon = $MarginContainer/HBoxContainer/LeftContainer/ItemTypeIcon
@onready var uses_label: Label = $MarginContainer/HBoxContainer/UsesLabel

func _ready() -> void:
	self.update_inventory_item_icon()
	self.update_item_name_label()
	self.update_item_type_icon()
	self.update_uses_label()
	self.style_fields()

func update_inventory_item_icon():
	if item != null:
		inventory_item_icon.set_image(item.icon)
	else : 
		inventory_item_icon.set_image(null)
	inventory_item_icon.set_equipped(equipped)

func update_item_name_label():
	if item != null:
		item_name_label.text = item.name
	else :
		item_name_label.text = ""

func update_item_type_icon():
	item_type_icon.set_types_from_item(item)

func update_uses_label():
	if item != null:
		uses_label.text = str(item.uses)
	else :
		uses_label.text = ""

func set_fields(input_item: ItemDefinition, e:bool = false) :
	self.item = input_item
	self.equipped = e
	self.update_inventory_item_icon()
	self.update_item_name_label()
	self.update_item_type_icon()
	self.update_uses_label()
	self.style_fields()

func style_fields():
	if disabled:
		self.theme = UNIT_INVENTORY_SLOT_DISABLED
	else :
		self.theme = UNIT_INVENTORY_SLOT_ENABLED

func create(item:ItemDefinition, e:bool = false) -> UnitInventorySlot:
	var unitInventorySlot = UnitInventorySlot.new()
	unitInventorySlot.set_fields(item, e)
	return unitInventorySlot

func grab_button_focus():
	$Button.grab_focus()

func _on_focus_entered() -> void:
	if not disabled:
		emit_signal("_hover_item", item)

func _on_pressed() -> void:
	if not disabled:
		emit_signal("selected_item", item)
