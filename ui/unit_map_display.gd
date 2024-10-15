extends Control
class_name UnitMapDisplay

var hp
var max_hp

var unit_icon: Texture2D


func update_health(current_hp: int) :
	hp = current_hp

static func create(definition: ItemDefinition) -> UnitMapDisplay:
	var instance = UnitMapDisplay.new()
	instance.item_name = definition.name
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
