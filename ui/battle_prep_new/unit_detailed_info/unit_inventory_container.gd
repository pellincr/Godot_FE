extends HBoxContainer

class_name InventoryContainer

signal item_equipped(item)
signal item_used(item)
signal set_trade_item(item)
signal sell_item(item)
signal item_focused(item)
signal send_to_convoy(item)

@onready var inventory_container_slot_1: Panel = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/InventoryContainerSlot
@onready var inventory_container_slot_2: Panel = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/InventoryContainerSlot2
@onready var inventory_container_slot_3: Panel = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/InventoryContainerSlot3
@onready var inventory_container_slot_4: Panel = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/InventoryContainerSlot4
@onready var inventory_container_slot_5: Panel = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/InventoryContainerSlot5

@onready var inventory_slot_array = [inventory_container_slot_1,inventory_container_slot_2,inventory_container_slot_3,inventory_container_slot_4,inventory_container_slot_5]

@onready var equipping_item = true

const equipped_icon = preload("res://ui/battle_prep_new/unit_detailed_info/E.png")

var unit :Unit
var block_item_use : bool = false

enum INVENTORY_STATE{
	NONE,
	SELL,
	CONVOY,
	TRADE
}

var current_state := INVENTORY_STATE.NONE

func _ready():
	if unit != null:
		update_by_unit()

func get_inventory_slots():
	return inventory_slot_array

func set_current_state(state:InventoryContainer.INVENTORY_STATE):
	current_state = state

func set_slot_theme(slot,theme):
	slot.theme = theme

func clear_slot(inventory_slot):
	inventory_slot.set_item_name_label("")
	inventory_slot.set_item_uses(-1)
	inventory_slot.set_invetory_item_icon(null)
	inventory_slot.update_item_type_icon(null)
	inventory_slot.item = null

func set_inventory_slot(item:ItemDefinition, slot):
	slot.item = item
	slot.update_by_item()

func update_by_unit():
	for slot_index in inventory_slot_array.size():
		if slot_index < unit.inventory.items.size():
			set_inventory_slot(unit.inventory.items[slot_index], inventory_slot_array[slot_index])
			if unit.inventory.equipped:
				var equipped_slot: InventoryContainerSlot = inventory_slot_array[0] 
				equipped_slot.set_equipped(true)
		else:
			clear_slot(inventory_slot_array[slot_index])

func clear_equipped_symbol(): #NOT WORKING
	for slot in inventory_slot_array:
		var children = slot.get_children()
		for child :InventoryContainerSlot in children:
			child.clear_equipped()
"""
func set_inventory_for_trade_true():
	for slot in inventory_slot_array:
		slot.set_for_trade = true

func set_inventory_for_trade_false():
	for slot in inventory_slot_array:
		slot.set_for_trade = false

func set_inventory_for_sale_true():
	for slot in inventory_slot_array:
		slot.set_for_sale = true
"""

func _on_item_equipped(item):
	unit.set_equipped(item)
	clear_equipped_symbol()
	update_by_unit()
	item_equipped.emit(item)

func _on_item_focused(item):
	item_focused.emit(item)

func _on_inventory_slot_pressed(item):
	if block_item_use:
		return
	match current_state:
		INVENTORY_STATE.NONE:
			if item:
				if item is WeaponDefinition:
					unit.set_equipped(item)
					clear_equipped_symbol()
					update_by_unit()
					item_equipped.emit(item)
					play_equipped_item_sound(item)
				else:
					disable_inventory_focus()
					var item_use_option = preload("res://ui/battle_prep_new/item_use_option.tscn").instantiate()
					add_child(item_use_option)
					item_use_option.item_confirmed.connect(_on_item_confirmed)
					item_use_option.cancelled.connect(_on_item_confirmed)
					item_use_option.item = item
					item_use_option.unit = unit
		INVENTORY_STATE.SELL:
			#emit the signal so that the players gold can be increased
			#sell_item.emit(item)
			#remove the item from the inventory
			#unit.inventory.discard_item(item)
			#update the inventory to match the item has now been discarded
			#update_by_unit()
			disable_inventory_focus()
			var sell_confirm_menu = preload("res://ui/battle_prep_new/shop/sell_confirm/sell_confirm.tscn").instantiate()
			add_child(sell_confirm_menu)
			sell_confirm_menu.sell_item.connect(_on_sell_confirm.bind(item))
			sell_confirm_menu.menu_closed.connect(_on_confirm_close)
		INVENTORY_STATE.CONVOY:
			send_to_convoy.emit(item)
			unit.inventory.discard_item(item)
			#update the inventory to match the item has now been discarded
			update_by_unit()
			AudioManager.play_sound_effect("store_item")
		INVENTORY_STATE.TRADE:
			set_trade_item.emit(item)
			AudioManager.play_sound_effect("menu_confirm")
			for inventory_slot in inventory_slot_array:
				if inventory_slot.item == item:
					inventory_slot.theme = preload("res://ui/battle_prep_new/inventory_not_focused_trade_ready.tres")
				else:
					inventory_slot.theme = preload("res://ui/battle_prep_new/inventory_not_focused.tres")

func _on_item_confirmed(item):
	enable_inventory_focus()
	update_by_unit()
	item_used.emit(item)


func grab_first_slot_focus():
	inventory_container_slot_1.grab_focus()

func _on_sell_confirm(item):
	enable_inventory_focus()
	#emit the signal so that the players gold can be increased
	sell_item.emit(item)
	#remove the item from the inventory
	unit.inventory.discard_item(item)
	#update the inventory to match the item has now been discarded
	update_by_unit()
	inventory_container_slot_1.grab_focus()

func _on_confirm_close():
	inventory_container_slot_1.grab_focus()

func play_equipped_item_sound(item : ItemDefinition):
	var selected_sound_effect = "menu_confirm"
	if item is WeaponDefinition:
		if item.weapon_type == ItemConstants.WEAPON_TYPE.SWORD:
			selected_sound_effect = "sword_equip"
		elif item.weapon_type == ItemConstants.WEAPON_TYPE.AXE:
			selected_sound_effect = "axe_equip"
		elif item.weapon_type == ItemConstants.WEAPON_TYPE.LANCE:
			selected_sound_effect = "lance_equip"
		elif item.weapon_type == ItemConstants.WEAPON_TYPE.DAGGER:
			selected_sound_effect = "dagger_equip"
		elif item.weapon_type == ItemConstants.WEAPON_TYPE.FIST:
			selected_sound_effect = "fist_equip"
		elif item.weapon_type == ItemConstants.WEAPON_TYPE.STAFF:
			selected_sound_effect = "staff_equip"
		elif item.weapon_type == ItemConstants.WEAPON_TYPE.BOW:
			selected_sound_effect = "bow_equip"
		elif item.weapon_type == ItemConstants.WEAPON_TYPE.SHIELD:
			selected_sound_effect = "shield_equip"
		elif item.item_damage_type == ItemConstants.DAMAGE_TYPE.MAGIC:
			selected_sound_effect = "magic_equip"
	AudioManager.play_sound_effect(selected_sound_effect)


"""
func _on_item_set_for_trade(item):
	set_trade_item.emit(item)


func _on_inventory_container_slot_use_item(item):
	if item:
		var item_use_option = preload("res://ui/battle_prep_new/item_use_option.tscn").instantiate()
		add_child(item_use_option)
		item_use_option.item_confirmed.connect(_on_item_confirmed)
		item_use_option.item = item
		item_use_option.unit = unit



func _on_inventory_container_slot_sell_item(item):
	sell_item.emit(item)
"""
func disable_inventory_focus():
	for slot in inventory_slot_array:
		slot.focus_mode = FOCUS_NONE

func enable_inventory_focus():
	for slot in inventory_slot_array:
		slot.focus_mode = FOCUS_ALL
