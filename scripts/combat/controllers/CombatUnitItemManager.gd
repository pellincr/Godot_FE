extends Node
class_name CombatUnitItemManager

signal discard_selection_complete

var current_node : Node = null
var discard_index : int

const POP_UP_COMPONENT = preload("res://ui/shared/pop_up/combat_view_pop_up.tscn")
const DISCARD_ITEM_COMPONENT = preload("res://ui/combat/discard_item_inventory/discard_item_inventory.tscn")
const TRADE_CONTAINER = preload("res://ui/combat/unit_trade/trade_container.tscn")

func give_combat_unit_item(cu:CombatUnit, item:ItemDefinition):
	print ("Entered give_combat_unit_item")
	if cu != null and item != null:
		var _pop_up = POP_UP_COMPONENT.instantiate()
		await _pop_up
		$"../../CanvasLayer/UI".add_child(_pop_up)
		_pop_up.visible = false
		_pop_up.set_item(item)
		_pop_up.visible = true
		await get_tree().create_timer(1).timeout
		_pop_up.queue_free()
	#check if unit inventory has space
	if cu.unit.inventory.is_full():
		#make a temp array,
		var _temp_item_array :Array[ItemDefinition]
		_temp_item_array.append_array(cu.unit.inventory.items)
		_temp_item_array.append(item)
		var _discard_container = DISCARD_ITEM_COMPONENT.instantiate()
		await _discard_container
		$"../../CanvasLayer/UI".add_child(_discard_container)
		_discard_container.visible = false
		_discard_container.populate_menu(_temp_item_array)
		_discard_container.connect("item_selection_complete",_discard_item_inventory_item_selected)
		_discard_container.visible = true
		#pass the discarded item and then add the recieved item
		await discard_selection_complete
		_discard_container.queue_free()
		var dicard_successful = cu.unit.inventory.discard_at_index(discard_index)
		discard_index = -1
		if dicard_successful:
			cu.unit.inventory.give_item(item)
	else:
		cu.unit.inventory.give_item(item)
	
func free_current_node():
	current_node.queue_free()

func trade(cu1: CombatUnit, cu2:CombatUnit):
	var tc : TradeContainer = TRADE_CONTAINER.instantiate()
	await tc
	tc.visible = false
	tc.set_unit_a(cu1.unit)
	tc.set_unit_b(cu2.unit)
	tc.update_trade_inventories()
	$"../../CanvasLayer/UI".add_child(tc)
	tc.visible = true
	current_node = tc

func _discard_item_inventory_item_selected(index : int):
	discard_index = index
	discard_selection_complete.emit()
	
