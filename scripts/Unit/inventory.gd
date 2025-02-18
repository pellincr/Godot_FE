extends Resource
class_name Inventory
var capacity : int = 4
#first item in the array is always equipped
var items: Array[ItemDefinition]
var equipped: ItemDefinition
var inventory_owner = Unit

func set_equipped(item : ItemDefinition):
	if (item.equippable) :
		if items.has(item):
			items.push_front(item)
			equipped = item
			items.remove_at(items.rfind(item))

func get_available_attack_ranges()-> Array[int]:
	var ranges : Array[int]
	for item in items:
		if (item != null) :
			if item.equippable:
				if item is WeaponDefinition:
					if not item.attack_range.is_empty():
						for attack_range in item.attack_range:
							if not ranges.has(attack_range):
								ranges.append(attack_range)
	return ranges

func get_available_support_ranges()-> Array[int]:
	var ranges : Array[int]
	for item in items:
		if (item != null) :
			if item.equippable:
				if item is WeaponDefinition:
					if not item.attack_range.is_empty():
						if item.item_target_faction == WeaponDefinition.AVAILABLE_TARGETS.ALLY:
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
	for item in items:
		if item == null :
			return true
	return false

func is_empty() -> bool:
	if items.is_empty() :
		return true 
	return false

func use_at_index(index : int): 
	if index < capacity:
		items[index].use

func give_item(item: ItemDefinition) -> bool:
	var item_gave = false
	if is_full() :
		return item_gave
	else:
		items.append(item)
		item_gave = true
	return item_gave

func get_weapons() -> Array[WeaponDefinition]:
	var weapon_array : Array[WeaponDefinition]
	for item in items:
		if item is WeaponDefinition: 
			weapon_array.append(item)
	return weapon_array

func get_stalves():
	pass

func has(item: ItemDefinition) -> bool:
	for i in items:
		if i.db_key == item.db_key:
			return true
	return false
	
func get_item_index(item: ItemDefinition)-> int:
	for index in items.size():
		if items[index] == item:
			return index
	return -1

static func create(input_items:Array[ItemDefinition], unit:Unit = null) -> Inventory:
	var inv = Inventory.new()
	if(input_items.size() > inv.capacity):
		input_items.resize(inv.capacity)
	for input_item in input_items:
		if input_item:
			var item = input_item.duplicate()
			#if input_item.equippable and inv.equipped == null:
				#inv.equipped = item
			inv.give_item(item)
	return inv

func discard_at_index(index : int):
	items.remove_at(index)

func discard_item(target_item: ItemDefinition):
	items.erase(target_item)

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

func replace_item_at_index(index:int, item: ItemDefinition):
	items.insert(index,item)
	items.remove_at(index + 1)

func get_item(index:int) -> ItemDefinition:
	if index < items.size():
		return items[index]
	return null
