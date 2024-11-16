extends Resource
class_name Inventory
var capacity : int = 4
#first item in the array is always equipped
var items: Array[ItemDefinition]
var equipped: ItemDefinition

func set_equipped(item : ItemDefinition):
	if (item.equippable) :
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

static func create(input_items:Array[ItemDefinition]) -> Inventory:
	var inv = Inventory.new()
	if(input_items.size() > inv.capacity):
		input_items.resize(inv.capacity)
	for input_item in input_items:
		if input_item:
			var item = input_item.duplicate()
			if input_item.equippable and inv.equipped == null:
				inv.equipped = item
			inv.give_item(item)
	return inv
