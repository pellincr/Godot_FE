extends LootTable
class_name LootTableItem
# A loot table is a datatype that processes arrays of lootTableEntries,
@export var entries: Array[LootTableItemEntry]

# Override the child function
func get_loot():
	return self.select_entry(entries).get_data()
