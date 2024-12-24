extends Control
class_name TradeUnitInventory

signal item_selected(item: ItemDefinition, unit: Unit)

var selected_item : ItemDefinition
var unit: Unit
var unit_icon: Texture
var unit_name: String
#var inventory: Array[ItemDefinition]

static func create(target_unit: Unit) -> TradeUnitInventory: 
	var tui = TradeUnitInventory.new()
	tui.set_unit(target_unit)
	return tui

func set_unit(target_unit: Unit):
	self.unit = target_unit
	self.unit_icon = target_unit.icon
	self.unit_name = target_unit.unit_name

func update_fields():
	update_icon()
	update_name()
	update_inventory_list()

func get_inventory_container_children() -> Array[Node]:
	return $PanelContainer/MarginContainer/VBoxContainer/Inventory.get_children()

func update_name():
	$PanelContainer/MarginContainer/VBoxContainer/HeaderPanel/UnitName.text = unit_name

func update_icon():
	$PanelContainer/MarginContainer/VBoxContainer/HeaderPanel/UnitIcon.texture = unit_icon

func set_icon(icon: Texture):
	self.unit_icon = icon

func set_unit_name(name: String):
	self.unit_name = name

func update_inventory_list():
	var children = get_inventory_container_children()
	for i in range(children.size()):
		if children[i] is UnitInventorySlot:
			var item_btn = children[i].get_button() as Button
			item_btn.disabled = false
			clear_action_button_connections(item_btn)
			var item_list = unit.inventory.items
			if not item_list.is_empty():
				if item_list.size() > i:
					var item = item_list[i]
					var equipped = false
					if i == 0: 
						equipped = true
					children[i].set_all(item, equipped)
					children[i].visible = true
					item_btn.pressed.connect(func(): set_selected_item(i, item))
				else : 
					children[i].set_all(null)
					children[i].visible = true
					clear_action_button_connections(item_btn)
					item_btn.pressed.connect(func(): set_selected_item(i, null))

func clear_action_button_connections(action: Button):
	var connections = action.pressed.get_connections()
	for connection in connections:
		action.pressed.disconnect(connection.callable)

func set_selected_item(item_index: int, item: ItemDefinition):
	#self.selected_item = item
	item_selected.emit(item_index, item, unit)
