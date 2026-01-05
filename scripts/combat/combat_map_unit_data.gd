extends Resource

class_name CombatMapUnitData

const random_group_list: Array[String] = [
	"A",
	"B",
	"C",
	"D",
	"MOUNTED",
	"FLIER",
	"ARMOR"
	]

@export var starting_enemy_group : EnemyGroup
var map_unit_data_table : Dictionary

@export_group("Randomized Unit Tables")
@export_subgroup("Generic Unit Tables")
@export var a : LootTableUnit = null
@export var b : LootTableUnit = null
@export var c : LootTableUnit  = null
@export var d : LootTableUnit = null

@export_subgroup("Unique Unit Tables")
@export var mounted : LootTableUnit = null
@export var flier : LootTableUnit = null
@export var armor : LootTableUnit = null
# add a space for overriding default unit inventories

func populate_map():
	map_unit_data_table.set("A", a)
	map_unit_data_table.set("B", b)
	map_unit_data_table.set("C", c)
	map_unit_data_table.set("D", d)
	
	map_unit_data_table.set("MOUNTED", mounted)
	map_unit_data_table.set("FLIER", flier)
	map_unit_data_table.set("ARMOR", armor)
