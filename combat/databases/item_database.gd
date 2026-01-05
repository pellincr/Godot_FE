extends Node

@export var items: Dictionary[String, ItemDefinition]

@export var commander_weapons : Dictionary[String, ItemDefinition]

func is_commander_weapon(db_key: String) -> bool: 
	return (commander_weapons.has(db_key))
