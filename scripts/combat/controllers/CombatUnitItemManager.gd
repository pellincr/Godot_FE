extends Node
class_name CombatUnitItemManager

signal discard_selection_complete

@export var combat : Combat
var current_node

signal heal(cu: CombatUnit, amount: int)
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

func generate_combat_unit_inventory_data(cu:CombatUnit) -> Array[UnitInventorySlotData]:
	var _arr : Array[UnitInventorySlotData] = []
	for item in cu.unit.inventory.get_items():
		var slot_data = UnitInventorySlotData.new()
		if item != null:
			slot_data.can_arrange = true
			slot_data.valid = true
			slot_data.item = item
			if item is WeaponDefinition:
				if item == cu.get_equipped():
					slot_data.equipped = true
				elif cu.unit.can_equip(item):
					slot_data.can_use = true
			elif item is ConsumableItemDefinition:
				slot_data.can_use = true
					# DO VETTING OF CONSUMABLES HERE
				if item.use_effect.size()  == 1:
					if item.use_effect.has(itemConstants.ITEM_USE_EFFECT.HEAL) and cu.unit.hp == cu.unit.stats.hp:
						slot_data.can_use = false
		_arr.append(slot_data)
	_arr[0].can_arrange = false
	_arr[1].can_arrange = false
	return _arr

func use_item(user: CombatUnit, item: ItemDefinition):
	if item is ConsumableItemDefinition:
		if not item.use_effect.is_empty():
			for combat_effect : CombatEffect in item.use_effect:
				if combat_effect.effect == itemConstants.ITEM_USE_EFFECT.HEAL:
					
					#await heal(combat_effect.effect_weight)
					pass
				if combat_effect.effect == itemConstants.ITEM_USE_EFFECT.STAT_BONUS:
					if combat_effect.duration == -1 : #THIS IS A PERMANENT STAT UP
						user.unit.unit_character.stats = CustomUtilityLibrary.add_unit_stat(user.unit.unit_character.stats, combat_effect.stats) #add this to the chracter def for perm stat up
						user.stats.populate_unit_stats(user.unit)
					elif combat_effect.duration >= 0: #This is for temporary stats in the combat
						# add this to the combat unit stat, set the source to the item
						pass
		user.unit.inventory.use_item(item)
