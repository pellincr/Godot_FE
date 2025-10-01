extends Node

@export var items: Dictionary

@export var commander_weapons : Dictionary

func is_commander_weapon(db_key: String) -> bool: 
	return (commander_weapons.has(db_key))
