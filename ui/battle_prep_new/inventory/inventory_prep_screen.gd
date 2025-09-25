extends HBoxContainer

class_name InventoryPrepScreen

signal return_to_menu()

var playerOverworldData : PlayerOverworldData

enum INVENTORY_STATE{
	UNIT_SELECT,
	MANAGE_ITEMS,
	PICK_TRADE_UNIT,
	TRADE
}

var current_state := INVENTORY_STATE.UNIT_SELECT
var sub_menu_open = false
var selected_unit : Unit
var trade_unit : Unit
var trade_item1 : ItemDefinition
var trade_item2 : ItemDefinition


func _ready() -> void:
	update_by_state()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		match current_state:
			INVENTORY_STATE.UNIT_SELECT:
				if !sub_menu_open:
					return_to_menu.emit()
			INVENTORY_STATE.MANAGE_ITEMS:
				current_state = INVENTORY_STATE.UNIT_SELECT
				sub_menu_open = false
				update_by_state()
			INVENTORY_STATE.PICK_TRADE_UNIT:
				current_state = INVENTORY_STATE.UNIT_SELECT
				sub_menu_open = false
				update_by_state()
			INVENTORY_STATE.TRADE:
				current_state = INVENTORY_STATE.PICK_TRADE_UNIT
				update_by_state()

func set_po_data(po_data):
	playerOverworldData = po_data


func update_by_state():
	clear_screen()
	var army_container_scene = preload("res://ui/battle_prep_new/army_container/ArmyContainer.tscn")
	var unit_detailed_view_simple_scene = preload("res://ui/battle_prep_new/unit_detailed_view_simple/unit_detailed_view_simple.tscn")
	var convoy_scene = preload("res://ui/battle_prep_new/convoy/convoy_container/convoy_container.tscn")
	match current_state:
		INVENTORY_STATE.UNIT_SELECT:
			var army_container = army_container_scene.instantiate()
			army_container.set_po_data(playerOverworldData)
			add_child(army_container)
			army_container.fill_army_scroll_container()
			army_container.unit_panel_pressed.connect(_on_unit_panel_pressed.bind(army_container))
		INVENTORY_STATE.MANAGE_ITEMS:
			var unit_detailed_view_simple = unit_detailed_view_simple_scene.instantiate()
			var convoy = convoy_scene.instantiate()
			unit_detailed_view_simple.unit = selected_unit
			add_child(unit_detailed_view_simple)
			unit_detailed_view_simple.set_invetory_state(InventoryContainer.INVENTORY_STATE.CONVOY)
			unit_detailed_view_simple.send_item_to_convoy.connect(_on_send_item_to_convoy.bind(convoy))
			convoy.set_po_data(playerOverworldData)
			add_child(convoy)
			convoy.fill_convoy_scroll_container()
			convoy.item_panel_pressed.connect(_on_item_panel_pressed.bind(unit_detailed_view_simple,convoy))
		INVENTORY_STATE.PICK_TRADE_UNIT:
			var unit_detailed_view_simple = unit_detailed_view_simple_scene.instantiate()
			unit_detailed_view_simple.unit = selected_unit
			add_child(unit_detailed_view_simple)
			var army_container = army_container_scene.instantiate()
			army_container.set_po_data(playerOverworldData)
			add_child(army_container)
			army_container.fill_army_scroll_container()
			army_container.remove_unit_panel(selected_unit)
			army_container.unit_panel_pressed.connect(_on_trade_unit_panel_pressed)
			army_container.grab_first_army_panel_focus()
		INVENTORY_STATE.TRADE:
			var unit_detailed_view_simple = unit_detailed_view_simple_scene.instantiate()
			unit_detailed_view_simple.unit = selected_unit
			add_child(unit_detailed_view_simple)
			unit_detailed_view_simple.set_trade_item.connect(_on_set_trade_item_1)
			unit_detailed_view_simple.set_invetory_state(InventoryContainer.INVENTORY_STATE.TRADE)
			unit_detailed_view_simple.grab_first_inventory_slot_focus()
			var trade_unit_detailed_view_simple = unit_detailed_view_simple_scene.instantiate()
			trade_unit_detailed_view_simple.unit = trade_unit
			add_child(trade_unit_detailed_view_simple)
			trade_unit_detailed_view_simple.set_trade_item.connect(_on_set_trade_item_2)
			trade_unit_detailed_view_simple.set_invetory_state(InventoryContainer.INVENTORY_STATE.TRADE)


func clear_screen():
	for child in get_children():
		child.queue_free()

func _on_unit_panel_pressed(unit:Unit,army_container):
	sub_menu_open = true
	selected_unit = unit
	var inventory_option_selection = preload("res://ui/battle_prep_new/inventory/inventory_option_selection.tscn").instantiate()
	inventory_option_selection.menu_closed.connect(_on_inventory_option_selection_menu_closed.bind(army_container))
	inventory_option_selection.inventory_option_state_selected.connect(_on_inventory_option_state_selected.bind(unit))
	inventory_option_selection.store_all.connect(_on_store_all)
	army_container.add_child(inventory_option_selection)
	army_container.move_child(inventory_option_selection,1)
	army_container.disable_army_container_focus()
	inventory_option_selection.manage_items_button_grab_focus()

func _on_trade_unit_panel_pressed(unit:Unit):
	trade_unit = unit
	current_state = INVENTORY_STATE.TRADE
	update_by_state()

func _on_inventory_option_state_selected(state:INVENTORY_STATE,unit:Unit):
	current_state = state
	update_by_state()

func _on_inventory_option_selection_menu_closed(army_container):
	army_container.enable_army_container_focus()
	sub_menu_open = false
	army_container.clear_detailed_view()
	army_container.grab_first_army_panel_focus()

func _on_item_panel_pressed(item,unit_detailed_view,convoy):
	if !selected_unit.inventory.is_full():
		selected_unit.inventory.give_item(item)
		playerOverworldData.convoy.erase(item)
		unit_detailed_view.update_by_unit()
		convoy.focused = false
		convoy.reset_convoy_container()

func _on_send_item_to_convoy(item,convoy):
	playerOverworldData.convoy.append(item)
	convoy.focused = false
	convoy.reset_convoy_container()

func _on_set_trade_item_1(item,unit):
	trade_item1 = item
	if trade_item2:
		swap_trade_items()

func _on_set_trade_item_2(item,unit):
	trade_item2 = item
	if trade_item1:
		swap_trade_items()



func swap_trade_items():
	var inventory_1 = selected_unit.inventory
	var inventory_2 = trade_unit.inventory
	# get the indexes
	var item_1_index = inventory_1.get_item_index(trade_item1)
	var item_2_index = inventory_2.get_item_index(trade_item2)
	inventory_1.set_item_at_index(item_1_index, trade_item2)
	inventory_2.set_item_at_index(item_2_index, trade_item1)
	trade_item1 = null
	trade_item2 = null
	#focused_detailed_view.update_by_unit()
	#current_trade_detailed_view.update_by_unit()
	#clear_sub_container()
	update_by_state()

func _on_store_all():
	var inventory_items = selected_unit.inventory.items
	var equipped_item = selected_unit.inventory.get_equipped_item()
	selected_unit.inventory.discard_item(equipped_item)
	playerOverworldData.convoy.append(equipped_item)
	for item in inventory_items:
		selected_unit.inventory.discard_item(item)
		playerOverworldData.convoy.append(item)
	update_by_state()
