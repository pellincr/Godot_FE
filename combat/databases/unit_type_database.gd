extends Node

@export var unit_types: Dictionary[String, UnitTypeDefinition]

@export var commander_types : Dictionary[String, CommanderDefinition]

func get_definition(db_key: String) -> UnitTypeDefinition:
	var unit_def : UnitTypeDefinition = get_unit_definition(db_key)
	var commander_def : UnitTypeDefinition = get_commander_definition(db_key)
	if (unit_def != null && commander_def != null):
		print("Error : unit type appeared in both databases")
	elif (unit_def != null):
		return unit_def
	elif (commander_def != null):
		return commander_def
	print("Error : invalid db_key for unit type database")
	return null
		
func get_unit_definition(db_key: String) -> UnitTypeDefinition:
	if  unit_types.has(db_key):
		return  unit_types[db_key]
	return null

func get_commander_definition(db_key: String) -> UnitTypeDefinition:
	if  commander_types.has(db_key):
		return  commander_types[db_key]
	return null

func has(db_key)-> bool:
	return (unit_types.has(db_key) or commander_types.has(db_key))
	
func is_commander(db_key: String) -> bool: 
	return (commander_types.has(db_key))

func sort(a:UnitTypeDefinition, b:UnitTypeDefinition):
	# First check rarity,
	if a.usable_weapon_types.min() != b.usable_weapon_types.min():
		return a.usable_weapon_types.min() < b.usable_weapon_types.min()
	if a.tier != b.tier:
		return a.tier < b.tier
	# Check Name
	elif a.unit_type_name != b.unit_type_name:
		return a.unit_type_name < b.unit_type_name
