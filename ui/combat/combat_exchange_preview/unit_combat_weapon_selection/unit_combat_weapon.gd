extends HBoxContainer

@onready var inventory_item_icon = $InventoryItemIcon
@onready var item_name_label = $ItemNameLabel
@onready var unit_combat_weapon_types = $UnitCombatWeaponTypes

var item : ItemDefinition

func _ready():
	if item:
		update_by_item()

func set_item_name_label(name):
	item_name_label.text = name

func update_by_item():
	set_item_name_label(item.name)
	inventory_item_icon.set_item(item)
	if item is WeaponDefinition:
		unit_combat_weapon_types.weapon_type = item.weapon_type
