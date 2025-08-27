extends Node
class_name CombatUnitItemManager

signal discard_selection_complete(give_item_required: bool)

@export var combat : Combat
var give_item_required

signal heal_unit(cu: CombatUnit, amount: int)
signal create_give_item_pop_up(item:ItemDefinition)
signal create_discard_container(cu:CombatUnit, item:ItemDefinition)
signal unit_inventory_updated(cu: CombatUnit)

const POP_UP_COMPONENT = preload("res://ui/shared/pop_up/combat_view_pop_up.tscn")
const DISCARD_ITEM_COMPONENT = preload("res://ui/combat/discard_item_inventory/discard_item_inventory.tscn")
const TRADE_CONTAINER = preload("res://ui/combat/unit_trade/trade_container.tscn")

const DISCARD_ACTION_INVENTORY = preload("res://ui/combat/discard_action_inventory_new/discard_action_inventory.tscn")

func give_combat_unit_item(cu:CombatUnit, item:ItemDefinition):
	print ("Entered give_combat_unit_item")
	if cu != null and item != null:
		# Create signal for pop-up
		create_give_item_pop_up.emit(item)
		#check if unit inventory has space
		if cu.unit.inventory.is_full():
			create_discard_container.emit(cu, item)
			await discard_selection_complete
			if give_item_required:
				cu.unit.inventory.give_item(item)
		else:
			cu.unit.inventory.give_item(item)

func trade(cu1: CombatUnit, cu2:CombatUnit):
	pass

func give_item_discard_result_complete(cu: CombatUnit, item : ItemDefinition):
	if cu.unit.inventory.has_item(item):
		discard_item(cu,item)
		give_item_required = true
	else:
		give_item_required = false
	discard_selection_complete.emit()

func generate_combat_unit_inventory_data(cu:CombatUnit) -> Array[UnitInventorySlotData]:
	var _arr : Array[UnitInventorySlotData] = []
	for item in cu.unit.inventory.get_items():
		var slot_data = UnitInventorySlotData.new()
		slot_data = generate_combat_unit_inventory_data_for_item(cu, item)
		_arr.append(slot_data)
	_arr[0].can_arrange = false
	_arr[1].can_arrange = false
	return _arr

func generate_combat_unit_inventory_data_for_item(cu:CombatUnit, item:ItemDefinition) -> UnitInventorySlotData:
	var item_data = UnitInventorySlotData.new()
	if item != null:
		item_data.can_arrange = true
		item_data.valid = true
		item_data.item = item
		if item is WeaponDefinition:
			if item == cu.get_equipped():
				item_data.equipped = true
			elif cu.unit.can_equip(item):
				item_data.can_use = true
		elif item is ConsumableItemDefinition:
			item_data.can_use = true
				# DO VETTING OF CONSUMABLES HERE
	return item_data

func use_item(user: CombatUnit, item: ItemDefinition):
	if item is ConsumableItemDefinition:
		match item.use_effect:
			ItemConstants.CONSUMABLE_USE_EFFECT.HEAL:
				heal_unit.emit(user, item.power)
			ItemConstants.CONSUMABLE_USE_EFFECT.STAT_BOOST:
				user.unit.unit_character.stats = CustomUtilityLibrary.add_unit_stat(user.unit.unit_character.stats, item.boost_stat)
				user.stats.populate_unit_stats(user.unit)
			ItemConstants.CONSUMABLE_USE_EFFECT.STATUS_EFFECT:
				pass
		user.unit.inventory.use_item(item)

func discard_item(owner: CombatUnit, item: ItemDefinition):
	owner.unit.inventory.discard_item(item)

func discard_item_at_index(owner: CombatUnit, index: int):
	owner.unit.inventory.discard_at_index(index)
