extends LootTableItemEntry
class_name LootTableEntryItemExpanded

@export_group("Expanded Options Information")
# Rarity whitelist, leave empty for all rarities
@export var item_rarity_whitelist : Array[Rarity]
# Item type whitelist, leave empty for all types
@export var item_type_whitelist : Array[ItemConstants.ITEM_TYPE]
# Weapon Type blacklist, only in use when item type can be weapon
@export var item_blacklist : Array[ItemDefinition]
# Weapon Type whitelist, only in use when item type can be weapon
@export var weapon_type_whitelist : Array[ItemConstants.WEAPON_TYPE]
@export_group("Weapon Options Detailed")
# Weapon damage type whitelist, only in use when item type can be weapon
@export var weapon_damage_type_whitelist : Array[Constants.DAMAGE_TYPE]



## Create a Method that gets the item
func get_data():
	if item != null:
		return item
	# Do detailed item selection
	var valid_items = []
	for item_key in ItemDatabase.items.keys():
		var target_item : ItemDefinition = ItemDatabase.items[item_key]
		if not item_blacklist.has(target_item):
			if item_type_whitelist.has(target_item.item_type) or item_type_whitelist.is_empty():
				if target_item.rarity != null:
					if item_rarity_whitelist.has(target_item.rarity) or item_rarity_whitelist.is_empty():
						if target_item is WeaponDefinition:
							if weapon_type_whitelist.has(target_item.weapon_type) or weapon_type_whitelist.is_empty():
								if weapon_damage_type_whitelist.has(target_item.item_damage_type) or weapon_damage_type_whitelist.is_empty():
									valid_items.append(item_key)
						else:
							valid_items.append(item_key)
	var r_key = valid_items.pick_random()
	return ItemDatabase.items[r_key]
