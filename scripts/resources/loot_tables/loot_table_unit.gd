extends LootTable
class_name LootTableUnit
# A loot table is a datatype that processes arrays of lootTableEntries,
@export var entries: Array[LootTableEntryUnitType]

# Override the child function
func get_loot():
	return self.select_entry(entries).get_data()
