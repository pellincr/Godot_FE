extends VBoxContainer

class_name Shop

signal return_to_menu()

@onready var gold_counter: GoldCounter = $GoldCounter

@onready var main_container: HBoxContainer = $MainContainer

var playerOverworldData : PlayerOverworldData


enum SHOP_STATE{
	LOCATION_SELECT,
	SHOP_MENU
}

var army_container_scene = preload("res://ui/battle_prep_new/army_container/ArmyContainer.tscn")

var current_state = SHOP_STATE.LOCATION_SELECT
var selected_buy_location = null

func _ready() -> void:
	update_by_shop_state()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		if current_state == SHOP_STATE.LOCATION_SELECT:
			return_to_menu.emit()
			queue_free()
			selected_buy_location = null
		elif current_state == SHOP_STATE.SHOP_MENU:
			current_state = SHOP_STATE.LOCATION_SELECT
			update_by_shop_state()

func set_po_data(po_data):
	playerOverworldData = po_data

func update_by_shop_state():
	clear_shop_screen()
	gold_counter.set_gold_count(playerOverworldData.gold)
	match current_state:
		SHOP_STATE.LOCATION_SELECT:
			var army_container = army_container_scene.instantiate()
			army_container.set_po_data(playerOverworldData)
			main_container.add_child(army_container)
			army_container.fill_army_scroll_container(true)
			army_container.unit_panel_pressed.connect(_on_unit_panel_pressed)
			army_container.convoy_panel_pressed.connect(_on_convoy_panel_pressed)
		SHOP_STATE.SHOP_MENU:
			var shop_container = preload("res://ui/battle_prep_new/shop/shop_container/shop_container.tscn").instantiate()
			if selected_buy_location is Unit:
				var unit_detailed_view_simple = preload("res://ui/battle_prep_new/unit_detailed_view_simple/unit_detailed_view_simple.tscn").instantiate()
				unit_detailed_view_simple.unit = selected_buy_location
				main_container.add_child(unit_detailed_view_simple)
				unit_detailed_view_simple.set_invetory_state(InventoryContainer.INVENTORY_STATE.SELL)
				unit_detailed_view_simple.sell_item.connect(_on_item_sold)
				shop_container.item_bought.connect(_on_item_bought_to_unit.bind(unit_detailed_view_simple))
			else:
				var convoy_container = preload("res://ui/battle_prep_new/convoy/convoy_container/convoy_container.tscn").instantiate()
				convoy_container.set_po_data(playerOverworldData)
				main_container.add_child(convoy_container)
				convoy_container.focused = true
				convoy_container.fill_convoy_scroll_container()
				convoy_container.item_panel_pressed.connect(_on_item_panel_pressed.bind(convoy_container))
				shop_container.item_bought.connect(_on_item_bought_to_convoy.bind(convoy_container))
			main_container.add_child(shop_container)
			shop_container.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
			


func clear_shop_screen():
	for child in main_container.get_children():
		child.queue_free()

func clear_detailed_view():
	if main_container.get_child_count() > 1:
		main_container.get_child(1).queue_free()

func _on_unit_panel_pressed(unit:Unit):
	current_state = SHOP_STATE.SHOP_MENU
	selected_buy_location = unit
	update_by_shop_state()

func _on_convoy_panel_pressed():
	current_state = SHOP_STATE.SHOP_MENU
	update_by_shop_state()

func _on_item_bought_to_unit(item:ItemDefinition,unit_detailed_view):
	var inventory :Inventory = selected_buy_location.inventory
	if !inventory.is_full() and playerOverworldData.gold >= item.worth:
		inventory.give_item(item)
		unit_detailed_view.update_by_unit()
		playerOverworldData.gold -= item.worth
		gold_counter.set_gold_count(playerOverworldData.gold)

func _on_item_bought_to_convoy(item:ItemDefinition,convoy_container):
	if playerOverworldData.gold >= item.worth:
		playerOverworldData.convoy.append(item)
		playerOverworldData.gold -= item.worth
		gold_counter.set_gold_count(playerOverworldData.gold)
		convoy_container.reset_convoy_container()



func _on_item_sold(item:ItemDefinition):
	playerOverworldData.gold += item.worth/2
	gold_counter.set_gold_count(playerOverworldData.gold)

func _on_item_panel_pressed(item:ItemDefinition, convoy_container):
	_on_item_sold(item)
	playerOverworldData.convoy.erase(item)
	convoy_container.focused = false
	convoy_container.reset_convoy_container()
