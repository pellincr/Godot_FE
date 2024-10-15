extends Node

class_name Unit


var stats
	 


static func create_definition(definition: CombatantDefinition) -> Unit:
	var instance = Unit.new()
	instance.unit_type = definition.name
	instance.type = definition.item_t
	instance.damage_type = definition.item_dmg_t
	instance.max_uses = definition.uses
	instance.uses = definition.uses
	instance.attack_range = definition.attack_ranges
	instance.class_locked = definition.class_locked
	instance.locked_class_name = definition.locked_class_name
	instance.damage = definition.damage
	instance.hit = definition.hit
	instance.critical_chance = definition.critical_chance
	instance.weight = definition.weight
	instance.icon = definition.icon
	return instance
	
static func create_custom(definition: CombatantDefinition, )
