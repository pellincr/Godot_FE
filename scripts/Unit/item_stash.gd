extends Resource
class_name ItemStash

var data : Array[ItemDefinition]

func _init(size: int = 1) -> void:
	data.resize(size)

func resize(size : int):
	data.resize(size)

func get_item(index: int) -> ItemDefinition:
	if index < data.size():
		return data[index]
	else:
		return null

func get_items() -> Array[ItemDefinition]:
	var items : Array[ItemDefinition] = []
	for item in data:
		if item != null:
			items.append(item)
	return items

func set_item(index:int, item: ItemDefinition):
	if index < data.size():
		data[index] = item

func pop(index : int) -> ItemDefinition:
	var item : ItemDefinition
	if index < data.size():
		item = data[index]
		remove(index)
		return item
	else :
		push_error("itemStash out of bounds error on pop")
		return null

func pop_item(item:ItemDefinition) -> ItemDefinition:
	var index = data.find(item)
	if index >= 0 :
		return pop(index)
	else : 
		push_error("could not find item in stash")
		return null

func find(item:ItemDefinition) -> int:
	return data.find(item)

func has_item_type(item:ItemDefinition) ->  bool:
	var key = item.db_key
	for stash_item in data:
		if stash_item.db_key == key: 
			return true
	return false

func remove(index : int):
	if index < data.size():
		data[index] = null
		compact()
	else:
		push_error("itemStash out of bounds error on removal")

func full() -> bool:
	if data[-1] == null:
		return false
	else:
		return true

func is_empty() -> bool:
	if data[0] == null:
		return true
	return false

# Re-orders data so all non-null items are first, nulls are last.
# Preserves the array size.
func compact():
	var size := data.size()
	data = data.filter(func(i): return i != null)
	data.resize(size)

func add_item(item: ItemDefinition):
	var index =  data.find(null)
	if index >= 0 :
		data[index] = item
	else :
		push_error("Attempted to add item to full itemStash")

func swap(index_a: int, index_b:int) -> bool:
	if index_a != index_b:
		if index_a < data.size() and index_b < data.size():
			var a = data[index_a]
			var b = data[index_b]
			data[index_b] = a
			data[index_a] = b
			return true
	return false
