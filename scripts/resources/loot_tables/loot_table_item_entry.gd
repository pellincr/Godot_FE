extends LootTableEntry
class_name LootTableItemEntry

# Target Item, Leave null for all items
@export var item: ItemDefinition = null

func get_data():
	return item
