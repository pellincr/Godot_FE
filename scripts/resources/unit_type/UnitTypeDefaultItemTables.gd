extends Resource
class_name UnitTypeDefaultItemTables

#Storing full item references here may be a waste of space in run time, if we want to save space change them to db_strings
@export_group("Generated Unit Item Tables")
@export var weapon_default : LootTableItem

# Treasure items, will always be droppable if they are randomed, is placed in the second slot of the unit's inventory
@export var treasure_default : LootTableItem
