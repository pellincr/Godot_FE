extends Resource
class_name LootTable

@export var entries : Array[LootTableEntry] 

func get_loot() -> ItemDefinition:
	return self.pick_item(self.calculate_loot()).duplicate()

func calculate_loot() -> LootTableEntry:
	var max : float = 0
	for entry : LootTableEntry in entries:
		max += entry.probability
	var roll = randf_range(0, max)
	for entry : LootTableEntry in entries:
		roll = roll - entry.probability
		if roll <= 0:
			return entry
	return null


#
#@export var item_rarity_whitelist : Array[String]
#@export var item_type_whitelist : Array[ItemDefinition.ITEM_TYPE]
#@export var weapon_type_whitelist : Array[ItemConstants.WEAPON_TYPE] #ONLY USED IF WHITELIST HAS WEAPON
#
func pick_item(entry : LootTableEntry) -> ItemDefinition:
	if entry.item_db_key.length() > 0:
		return ItemDatabase.items[entry.item_db_key]
	var valid_items = []
	for item_key in ItemDatabase.items.keys():
		var target_item : ItemDefinition = ItemDatabase.items[item_key]
		if entry.item_type_whitelist.has(target_item.item_type) or entry.item_type_whitelist.is_empty():
			if target_item.rarity != null:
				if entry.item_rarity_whitelist.has(target_item.rarity.rarity_name) or entry.item_rarity_whitelist.is_empty():
					if target_item is WeaponDefinition:
						if entry.weapon_type_whitelist.has(target_item.weapon_type) or entry.weapon_type_whitelist.is_empty():
							valid_items.append(item_key)
					else:
						valid_items.append(item_key)
	var r_key = valid_items.pick_random()
	return ItemDatabase.items[r_key]
