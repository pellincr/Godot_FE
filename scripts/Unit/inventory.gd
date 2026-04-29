extends Resource
class_name Inventory

const BASE_CAPACITY := 1
#The Inventory data type store items for use with units

#The maximum size of the inventory
@export var stash_capacity : int = BASE_CAPACITY

## The current item in the main hand slot
@export var main_hand: ItemDefinition = null
## Is the item in the main hand slot active?
@export var main_hand_equipped : bool = false ##does this indicate active -- yes
@export var main_hand_suppressed : bool = false

@export var off_hand: ItemDefinition = null
@export var off_hand_equipped : bool = false
@export var off_hand_suppressed : bool = false

#The List of items in the bag
@export var stash: ItemStash

var attack_range_map = {} # map<range : int, items:Array[index]>  ##This can be used to show if equipment changes, should be used if all items can be used 

var support_range_map = {} # map<range : int, items:Array[index]> 

#
# Constructor
#
static func create(main_hand : ItemDefinition = null, off_hand: ItemDefinition = null, stash_contents:Array[ItemDefinition] = [], stash_capacity :int = 1) -> Inventory:
	var inv = Inventory.new()
	
	inv.stash._init(stash_capacity)
	for item in stash_contents:
		inv.stash.add_item(item)
		
	inv.main_hand = main_hand
	inv.off_hand = off_hand 
	return inv

func set_main_hand(item: ItemDefinition):
	main_hand = item

func set_off_hand(item: ItemDefinition):
	off_hand = item

func check_main_hand_active() -> bool:
	if main_hand:
		if main_hand_equipped:
			if !main_hand_suppressed:
				return true
	return false

func check_off_hand_active() -> bool:
	if main_hand:
		if main_hand_equipped:
			if !main_hand_suppressed:
				return true
	return false

func use_main_hand():
	if main_hand:
		if main_hand_equipped:
			if !main_hand_suppressed:
				main_hand.expend_use()

func equip_main_hand():
	if main_hand != null:
		if main_hand.equippable:
			main_hand_equipped = true
			main_hand_suppressed = false

func get_main_hand()-> ItemDefinition:
	if main_hand != null:
		if main_hand_equipped:
			return main_hand
	return null

func unequip_main_hand():
	main_hand_equipped = false

func pop_main_hand() -> ItemDefinition:
	var item = main_hand
	main_hand = null
	unequip_main_hand()
	return item

func expend_use_main_hand():
	if main_hand != null:
		main_hand.expend_use()

func swap_main_hand_with_stash_index(stash_index: int = 0):
	var item = stash.pop(stash_index)
	var _equipped_item = main_hand
	if item != null:
		main_hand = item
		stash.set_item(stash_index, _equipped_item)

func swap_main_hand_with_stash_item(item: ItemDefinition):
	if main_hand != null:
		var hand_item = pop_main_hand()
		var stash_index = stash.find(item)
		if stash_index >= 0:
			main_hand = stash.get_item(stash_index)
			stash.set_item(stash_index, hand_item)
		else:
			push_error("Out of bounds error")
	else:
		var stash_item = stash.pop_item(item)
		if stash_item != null:
			main_hand = stash_item

func use_off_hand():
	if check_off_hand_active():
		off_hand.expend_use()

func equip_off_hand():
	if off_hand != null:
		if off_hand.equippable:
			off_hand_equipped = true
			off_hand_suppressed = false

func get_off_hand()-> ItemDefinition:
	if off_hand != null:
		if off_hand_equipped:
			return off_hand
	return null

func unequip_off_hand():
	main_hand_equipped = false
	main_hand

func pop_off_hand() -> ItemDefinition:
	var item = off_hand
	off_hand = null
	unequip_off_hand()
	return item

func expend_use_off_hand():
	if off_hand != null:
		off_hand.expend_use()

func swap_off_hand_with_stash_index(stash_index: int = 0):
	var item = stash.pop(stash_index)
	var _target_item = off_hand
	if item != null:
		off_hand = item
		stash.set_item(stash_index, _target_item)

func swap_off_hand_with_stash_item(item: ItemDefinition):
	if off_hand != null:
		var hand_item = pop_off_hand()
		var stash_index = stash.find(item)
		if stash_index >= 0:
			off_hand = stash.get_item(stash_index)
			stash.set_item(stash_index, hand_item)
		else:
			push_error("Out of bounds error")
	else:
		var stash_item = stash.pop_item(item)
		if stash_item != null:
			off_hand = stash_item

func stash_add(item: ItemDefinition):
	stash.add_item(item)

func stash_remove_item(item:ItemDefinition) -> bool:
	var index = stash.find(item)
	if index >= 0:
		stash.remove(index)
		return true
	else :
		return false 

func stash_remove(index:int):
	stash.remove(index)

func get_stash() -> Array[ItemDefinition]:
	return stash.get_items()

func full() -> bool:
	if main_hand:
		if off_hand:
			if stash.full():
				return true
	return false

func get_equipped() -> Array[ItemDefinition]:
	var equipped : Array[ItemDefinition] = []
	if main_hand != null:
		if main_hand_equipped:
			equipped.append(main_hand)
	if off_hand != null:
		if off_hand_equipped:
			equipped.append(off_hand)
	return equipped

func update_supressed_flags():
	if main_hand_equipped:
		if main_hand is WeaponDefinition:
			if main_hand.equip_slot == WeaponDefinition.EQUIP_SLOT.TWO_HANDED:
				off_hand_suppressed = true
	
	# is it two handed?
#
# get the attack ranges of active item
#
func get_available_attack_ranges()-> Array[int]:
	var ranges : Array[int] = []
	if main_hand != null:
		if main_hand.equippable:
			if main_hand is WeaponDefinition:
				if main_hand.use_type == WeaponDefinition.USE_TYPE.ATTACK:
					if not main_hand.attack_range.is_empty():
						if  main_hand.item_target_faction.has(ItemConstants.AVAILABLE_TARGETS.ENEMY):
							ranges.append_array(main_hand.attack_range)
	return ranges

func get_max_available_attack_range() -> int:
	var ranges = get_available_attack_ranges()
	if !ranges.is_empty():
		return ranges.max()
	return 0

#
# get the support ranges of all items --> change to "staff"
#
func get_available_action_ranges()-> Array[int]:
	var ranges : Array[int] = []
	if main_hand != null:
		if main_hand.equippable:
			if main_hand is WeaponDefinition:
				if main_hand.use_type == WeaponDefinition.USE_TYPE.ACTION:
					if not main_hand.attack_range.is_empty():
						if  main_hand.item_target_faction.has(ItemConstants.AVAILABLE_TARGETS.ALLY):
							ranges.append_array(main_hand.attack_range)
	return ranges

#
# Returns a list of weapons structured by item with the most range first
#
func get_items_by_range() -> Array[ItemDefinition]:
	update_range_map()
	var _item_arr :Array[ItemDefinition]
	var _key_arr: Array = attack_range_map.keys();
	for x in _key_arr.size():
		var key = _key_arr[-x-1]
		if attack_range_map.has(key):
			for item in attack_range_map[key]:
				if not _item_arr.has(item):
					_item_arr.append(item)
	return _item_arr

#
# Returns the maximum attack range of the items contained in the inventory
#
func get_max_action_range() -> int:
	var ranges = get_available_action_ranges()
	if !ranges.is_empty():
		return ranges.max()
	return 0

func get_available_weapons_at_attack_range(attack_range: int) -> Array[ItemDefinition]:
	var available_weapons : Array[ItemDefinition]
	for item in items:
		if (item != null) :
			if item.equippable: #is this necessary?
				if item is WeaponDefinition:
					if not item.attack_range.is_empty():
						if(item.attack_ranges.has(attack_range)):
							available_weapons.append(item)
	return available_weapons

#
# Returns a list of WeaponDefinitions contained in the inventory
# 
func get_weapons() -> Array[WeaponDefinition]:
	var _item_array : Array[ItemDefinition]
	var _valid_weapons : Array[WeaponDefinition]
	_item_array.append(main_hand)
	_item_array.append(off_hand)
	_item_array.append_array(get_stash())
	for item in _item_array:
		if is_main_handable(item):
			_valid_weapons.append(item)
	return _valid_weapons

func is_main_handable(item: ItemDefinition) -> bool:
	if item != null:
		if item is WeaponDefinition:
			if item.EQUIP_SLOT == WeaponDefinition.EQUIP_SLOT.MAIN_HAND || item.EQUIP_SLOT == WeaponDefinition.EQUIP_SLOT.VERSATILE || item.EQUIP_SLOT == WeaponDefinition.EQUIP_SLOT.TWO_HANDED:
				return true
	return false

#
# checks if a version of the target item is inside 
#
func has(target_item: ItemDefinition) -> bool:
	if main_hand.db_key == target_item.db_key or off_hand.db_key == target_item.db_key:
		return true
	var _stash = stash.get_items()
	for item in _stash:
		if item.db_key == target_item.db_key:
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
func discard_item(target_item: ItemDefinition) -> bool:
	if target_item == main_hand:
		main_hand = null
		return true
	elif target_item == off_hand:
		off_hand = null
		return true
	else :
		return stash_remove_item(target_item)


#
# gets the item that is currently equipped
#
func get_active_equipped_items() -> Array[ItemDefinition]:
	var _equipped : Array[ItemDefinition] = []
	if main_hand != null and main_hand_equipped:
		if main_hand_suppressed != true:
			_equipped.append(main_hand)
	if off_hand != null and off_hand_equipped:
		if off_hand_suppressed != true:
			_equipped.append(off_hand)
	return _equipped

# gets the item that is currently equipped
#
func get_equipped_items() -> Array[ItemDefinition]:
	var _equipped : Array[ItemDefinition] = []
	if main_hand != null and main_hand_equipped:
		_equipped.append(main_hand)
	if off_hand != null and off_hand_equipped:
		_equipped.append(off_hand)
	return _equipped

#
# Returns all weapons in inventory that contain input attack ranges, used for AI calculations and equipping?
#
func get_weapons_with_range(ranges: Array[int]) -> Array[WeaponDefinition]:
	var weaponList : Array[WeaponDefinition] = []
	var _available_weapons : Array[ItemDefinition] = []
	if get_main_hand() != null:
		_available_weapons.append(get_main_hand())
	if get_off_hand() != null:
		_available_weapons.append(get_off_hand())
	_available_weapons.append_array(stash.get_weapons())
	for range in ranges:
		for item in _available_weapons:
			if item is WeaponDefinition:
				if item.is_main_hand_equippable():
					if item.attack_range.has(range):
						if !weaponList.has(item):
							weaponList.append(item)
	return weaponList

func has_item(item: ItemDefinition):
	if main_hand != null and main_hand == item:
		return true
	elif off_hand != null and off_hand == item:
		return true
	else : 
		return stash.has(item)

func has_item_with_db_key(db_key : String):
	if main_hand != null:
		if main_hand.db_key == db_key:
			return true
	if off_hand != null:
		if off_hand.db_key == db_key:
			return true
	else :
		return stash.has_item_with_db_key(db_key)

func has_item_with_any_db_key(db_keys : Array[String]):
	for db_key in db_keys:
		if has_item_with_db_key(db_key):
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

func get_special_from_main_hand() -> Array[SpecialEffect]:
	var _specials : Array[SpecialEffect] = []
	if check_main_hand_active():
		_specials.append_array(main_hand.held_specials)
	return _specials

func get_special_from_off_hand() -> Array[SpecialEffect]:
	var _specials : Array[SpecialEffect] = []
	if check_off_hand_active():
		_specials.append_array(off_hand.held_specials)
	return _specials

func get_specials_from_equipped() -> Array[SpecialEffect]:
	var _specials : Array[SpecialEffect] = []
	return _specials

func get_all_specials_from_inventory_and_equipped() ->  Array[SpecialEffect]:
	var _specials : Array[SpecialEffect] = []
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
