extends LootTableEntry
class_name LootTableEntryUnitType

# Target Item, Leave null for all items
@export var unit: UnitTypeDefinition

func get_data():
	return unit.db_key
