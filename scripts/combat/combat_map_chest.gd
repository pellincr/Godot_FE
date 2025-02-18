extends CombatMapEntity
class_name CombatMapChestEntity
@export var required_item: Array[ItemDefinition]
@export var contents: Array[ItemDefinition]

func interact(cu:CombatUnit):
	for chest_item in contents:
		cu.unit.inventory.give_item(chest_item)
