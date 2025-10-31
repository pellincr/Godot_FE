extends Resource
class_name UnitTypeDefaultItemTables

#Storing full item references here may be a waste of space in run time, if we want to save space change them to db_strings
@export_group("Generated Unit Item Tables")
@export var weapon_default : Array[LootTableItemEntry]

# Treasure items, will always be droppable if they are randomed
@export var treasure_default : Array[LootTableItemEntry]
