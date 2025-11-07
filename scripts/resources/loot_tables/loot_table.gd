extends Resource
class_name LootTable
# A loot table is a datatype that processes arrays of lootTableEntries,


# We do the math to select the entry and then call get data
func get_loot():
	pass
	#return self.select_entry().get_data()

# Chooses one of the entries from the loot table
func select_entry(entries : Array) -> LootTableEntry:
	var max : float = 0
	# combine the entry weights
	for entry : LootTableEntry in entries:
		max += entry.probability
	# make a roll within the maximum entry weights
	var roll = randf_range(0, max)
	#TODO PULL FROM PARTICULAR RAND
	# iterate down through the entry list to see which entry was selected
	for entry : LootTableEntry in entries:
		roll = roll - entry.probability
		if roll <= 0:
			return entry
	return null
