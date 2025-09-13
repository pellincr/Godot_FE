extends Control
class_name TradeContainer

var unit_a : Unit
var unit_b : Unit
var tradeUnitInvA: TradeUnitInventory
var tradeUnitInvB: TradeUnitInventory 
var currently_selected_item : ItemDefinition
var currently_selected_item_owner : Unit
func _ready(): 
	tradeUnitInvA  = $HBoxContainer/TradeUnitInventorya
	tradeUnitInvB = $HBoxContainer/TradeUnitInventoryb
	tradeUnitInvA.connect("item_selected", item_selected)
	tradeUnitInvB.connect("item_selected", item_selected)


static func create(ua : Unit, ub :Unit) -> TradeContainer:
	var trade_container = TradeContainer.new()
	trade_container.set_unit_a(ua)
	trade_container.set_unit_b(ub)
	trade_container.update_trade_inventories()
	##unit_display.global_position = position * Vector2(32, 32)
	return trade_container

func update_trade_inventories():
	update_trade_inventory_a(unit_a)
	update_trade_inventory_b(unit_b)

func update_trade_inventory_a(ua: Unit):
	$HBoxContainer/TradeUnitInventorya.set_unit(ua)
	$HBoxContainer/TradeUnitInventorya.update_fields()

func update_trade_inventory_b(ub: Unit):
	$HBoxContainer/TradeUnitInventoryb.set_unit(ub)
	$HBoxContainer/TradeUnitInventoryb.update_fields()

func set_unit_a(ua: Unit):
	self.unit_a = ua

func set_unit_b(ub: Unit):
	self.unit_b = ub

func item_selected(index: int, item: ItemDefinition, item_owner: Unit):
	if currently_selected_item_owner:
		if currently_selected_item_owner == item_owner:
			if currently_selected_item != item:
				item_owner.inventory.swap_at_indexes(item_owner.inventory.get_item_index(item), item_owner.inventory.get_item_index(currently_selected_item))
		else:
			perform_trade(item_owner, item, currently_selected_item_owner, currently_selected_item)
		update_trade_inventories()
		currently_selected_item = null
		currently_selected_item_owner = null
	else: 
		currently_selected_item = item
		currently_selected_item_owner = item_owner

func perform_trade(unit_a:Unit, item_a:ItemDefinition, unit_b:Unit, item_b:ItemDefinition):
	#print("performing trade with : "+ item_a.name + " | " + item_b.name)
	var a_index = unit_a.inventory.get_item_index(item_a)
	var b_index = unit_b.inventory.get_item_index(item_b)
	if (a_index >= 0): 
		if (b_index >= 0):
			unit_a.inventory.replace_item_at_index(a_index, item_b)
			unit_b.inventory.replace_item_at_index(b_index, item_a)
		else: #a exists b does not
			unit_b.inventory.give_item(item_a)
			unit_a.inventory.discard_item(item_a)
	else:
		if (b_index >= 0): # item_a is null? 
			unit_a.inventory.give_item(item_b)
			unit_b.inventory.discard_item(item_b) 
		pass 
		
