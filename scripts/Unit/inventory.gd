extends Resource
class_name Inventory

#The Inventory data type store items for use with units

#The maximum size of the inventory
@export var capacity : int = 4

#The List of items 
@export var items: Array[ItemDefinition]

#indicates if the first item in the inventory is currently equipped
@export var equipped: bool

var inventory_owner = Unit ##IS THIS REDUNDANT?

var attack_range_map = {} # map<range : int, items:Array[index]> 

var support_range_map = {} # map<range : int, items:Array[index]> 

#
# Constructor
#
static func create(input_items:Array[ItemDefinition], unit:Unit = null) -> Inventory:
	var inv = Inventory.new()
	if(input_items.size() > inv.capacity):
		input_items.resize(inv.capacity)
	for input_item in input_items:
		if input_item:
			var item = input_item.duplicate()
			if input_item.equippable and !inv.equipped:
				inv.set_equipped(item)
			inv.give_item(item)
	return inv

#
# Update the weapon range map (THIS DOES NOT ACCOUNT FOR UNIT EQUIPPABILITY LIMITS)
#
func update_range_map():
	attack_range_map.clear()
	for item_index in items.size():
			if items[item_index] is WeaponDefinition:
				for attack_range in items[item_index].attack_range:
					if attack_range_map.has(attack_range):
						attack_range_map.get(attack_range).append(item_index)
					else:
						attack_range_map.put([item_index])

#
# Force sets the currently equipped item
#
func set_equipped(item : ItemDefinition):
	if items.has(item):
		var index = get_item_index(item)
		items.push_front(item)
		items.remove_at(index + 1)
		equipped = true



#
# Equips currently onwed item at specified index
#
func equip_at_index(index : int):
	var item = items[index]
	items.remove_at(index)
	items.push_front(item)
	equipped = true

#
# get the attack ranges of all items 
#
func get_available_attack_ranges()-> Array[int]:
	var ranges : Array[int]
	for item in items:
		if (item != null) :
			if item.equippable:
				if item is WeaponDefinition:
					if not item.attack_range.is_empty():
						if  item.item_target_faction.has(ItemConstants.AVAILABLE_TARGETS.ENEMY):
							for attack_range in item.attack_range:
								if not ranges.has(attack_range):
									ranges.append(attack_range)
	return ranges

#
# Returns the maximum attack range of the items contained in the inventory
#
func get_max_attack_range() -> int:
	if get_available_attack_ranges().max():
		return get_available_attack_ranges().max()
	else:
		return 0

#
# Returns the maximum attack range of the items contained in the inventory
#
func get_max_support_range() -> int:
	var max = 0
	var support_range_dictionary = get_available_support_ranges()
	for entry in support_range_dictionary:
		if support_range_dictionary[entry] is Array[int]:
			if support_range_dictionary[entry].max():
				if support_range_dictionary[entry].max() > max:
					max = support_range_dictionary[entry].max()
	return max

## CHANGE THIS TO MAP IN FUTURE
func get_available_support_ranges()-> Dictionary: #Dictionary<support_type : WeaponDefinition.SUPPORT_TYPES.HEAL , ranges: Array[int]>
	var range_map : Dictionary = {}
	range_map[WeaponDefinition.SUPPORT_TYPES.HEAL] = get_available_support_ranges_healing()
	return range_map

func get_available_support_ranges_healing()-> Array[int]:
	var ranges : Array[int]
	for item in items:
		if (item != null) :
			if item.equippable:
				if item is WeaponDefinition:
					if not item.attack_range.is_empty():
						if item.item_target_faction.has(ItemConstants.AVAILABLE_TARGETS.ALLY):
							if item.support_type == WeaponDefinition.SUPPORT_TYPES.HEAL:
								for attack_range in item.attack_range:
									if not ranges.has(attack_range):
										ranges.append(attack_range)
	return ranges


func get_available_weapons_at_attack_range(attack_range: int) -> Array[ItemDefinition]:
	var available_weapons : Array[ItemDefinition]
	for item in items:
		if (item != null) :
			if item.equippable:
				if item is WeaponDefinition:
					if not item.attack_range.is_empty():
						if(item.attack_ranges.has(attack_range)):
							available_weapons.append(item)
	return available_weapons

func is_full() -> bool:
	if (items.size() < capacity) :
		return false 
	else :
		return true

func is_empty() -> bool:
	if items.is_empty() :
		return true 
	return false

func use_at_index(index : int) -> ItemDefinition: 
	if index < capacity:
		var target_item :ItemDefinition = items[index]
		target_item.expend_use()
		# What is the state of the item, is it broken and does it have to be removed?
		if target_item.uses <= 0:
			if not target_item.expended and not target_item.unbreakable:
				items.remove_at(index)
				if index == 0:
					equipped = false
				return target_item
				#emit something here indicating a break so UI can display it
	return null

func set_item_at_index(index: int, item: ItemDefinition):
	if item != null:
		if index >= 0 and index < capacity:
			if index < items.size():
				items[index] = item
			else: 
				items.append(item)
		else : 
			items.append(item)
	else : 
		if index < capacity:
			items.remove_at(index)
#
# Gives an item to the inventory, at the end of the list
#
func give_item(item: ItemDefinition) -> bool:
	var item_gave = false
	if is_full() :
		return item_gave
	else:
		items.append(item)
		item_gave = true
	return item_gave


#
# Returns a list of WeaponDefinitions contained in the inventory
# 
func get_weapons() -> Array[WeaponDefinition]:
	var weapon_array : Array[WeaponDefinition]
	for item in items:
		if item is WeaponDefinition: 
			weapon_array.append(item)
	return weapon_array

#
# checks if a version of the target item is inside 
#
func has(target_item: ItemDefinition) -> bool:
	for inventory_slot in items:
		if inventory_slot != null:
			if inventory_slot.db_key == target_item.db_key:
				return true
	return false


#
# returns the index of a specific item resource
#
func get_item_index(item: ItemDefinition)-> int:
	for index in items.size():
		if items[index] == item:
			return index
	return -1


#
# remove an item at a specific index of the list, returns false if error
#
func discard_at_index(index : int) -> bool:
	if(index < items.size() - 1):
		items.remove_at(index)
		return true
	else: 
		return false

#
# removes an item if it exists within the inventory
#
func discard_item(target_item: ItemDefinition):
	items.erase(target_item)

#
# Swaps two items with indexes
#
func swap_at_indexes(index_a:int , index_b : int):
	if (index_a >=0): 
		if  (index_b >=0): 
			var placeHolder : ItemDefinition = items[index_a]
			items.insert(index_a, items[index_b])
			items.remove_at(index_a + 1)
			items.insert(index_b, placeHolder)
			items.remove_at(index_b + 1)
		else : 
			var placeHolder : ItemDefinition = items[index_a]	
			items.remove_at(index_a)
			items.append(placeHolder)
	else : 
		if (index_b >=0): 
			var placeHolder : ItemDefinition = items[index_b]
			items.remove_at(index_b)
			items.append(placeHolder)

#
# Replaces an item at a specified index with another item
#
func replace_item_at_index(target_index:int, replacement_item: ItemDefinition):
	items.insert(target_index,replacement_item)
	items.remove_at(target_index + 1)

#
# gets the item at inventory index
#
func get_item(index:int) -> ItemDefinition:
	if index < items.size():
		return items[index]
	return null

#
# gets the item that is currently equipped
#
func get_equipped_item() -> ItemDefinition:
	if equipped == true:
		if items.front() != null: 
			return items.front()
	return null

#
# returns a weaponDefinition if the current item equpped is a weapon
#
func get_equipped_weapon() -> WeaponDefinition:
	var wpn = get_equipped_item()
	if wpn is WeaponDefinition:
		return wpn
	return null

func unequip():
	equipped = false

#Moves the item to the second spot
func arrange(item: ItemDefinition):
	var index :int = get_item_index(item)
	if index > 1:
		swap_at_indexes(index, 1)

#Move item in front spot to the back
func send_back():
	swap_at_indexes(0, items.size()-1)
#
# Returns all weapons in inventory that contain input attack ranges
#
func get_weapons_with_range(ranges: Array[int]) -> Array[WeaponDefinition]:
	var weaponList : Array[WeaponDefinition] = []
	for range in ranges:
		if attack_range_map.has(range):
			var attack_range_weapons_index : Array[int] = attack_range_map.get(range)
			for index in attack_range_weapons_index:
				if weaponList.find(get_item(index)) == -1:
					weaponList.append(get_item(index))
	return weaponList

func get_items() -> Array[ItemDefinition]:
	var _item_arr : Array[ItemDefinition] = [null, null, null, null]
	for i in range(items.size()):
		_item_arr[i] = items[i]
	return _item_arr

func use_item(item: ItemDefinition) -> ItemDefinition:
	if has(item):
		return use_at_index(get_item_index(item))
	return null

func has_item(item: ItemDefinition):
	return items.has(item)

func has_item_with_db_key(db_key : String):
	for item in items:
		if item.db_key == db_key:
			return true
	return false

func has_item_with_any_db_key(db_keys : Array[String]):
	for db_key in db_keys:
		for item in items:
			if item.db_key == db_key:
				return true
	return false

func total_item_held_bonus_stats() -> CombatUnitStat:
	var _net_stat = CombatUnitStat.new()
	for item in items:
		if item != null:
			if item.inventory_bonus_stats != null:
				_net_stat = CustomUtilityLibrary.add_combat_unit_stat(_net_stat, item.inventory_bonus_stats)
	return _net_stat
	
func total_item_held_bonus_growths() -> UnitStat:
	var _net_stat = UnitStat.new()
	for item in items:
		if item != null:
			if item.inventory_growth_bonus_stats != null:
				_net_stat = CustomUtilityLibrary.add_unit_stat(_net_stat, item.inventory_growth_bonus_stats)
	return _net_stat

func get_all_specials_from_inventory_and_equipped() ->  Array[SpecialEffect]:
	var _specials : Array[SpecialEffect] = []
	# DO Equipped first
	if equipped:
		_specials.append_array(get_equipped_weapon().equipped_specials)
	for item in items:
		_specials.append_array(item.held_specials)
	return _specials
	
func get_all_stats_from_held_items() -> CombatUnitStat:
	var net_stat : CombatUnitStat = CombatUnitStat.new()
	for item in get_items():
		if item != null:
			if item.inventory_bonus_stats != null:
				net_stat = CustomUtilityLibrary.add_combat_unit_stat(net_stat,item.inventory_bonus_stats)
	return net_stat

func get_all_growths_from_held_items() -> UnitStat:
	var net_stat : UnitStat = UnitStat.new()
	for item in get_items():
		if item != null:
			if item.inventory_growth_bonus_stats != null:
				net_stat = CustomUtilityLibrary.add_unit_stat(net_stat,item.inventory_growth_bonus_stats)
	return net_stat
