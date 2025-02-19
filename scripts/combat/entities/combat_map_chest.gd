extends CombatMapEntity
class_name CombatMapChestEntity

@export var chest_texture :Texture2D = preload("res://resources/sprites/entities/chest_sprite.tres")
@export var required_item : Array[ItemDefinition] = [preload("res://resources/definitions/items/consumables/skeleton_key.tres")] 
@export var contents: Array[ItemDefinition]

func _init():
	self.sprite = chest_texture
	self.targetable = false
	self.interaction_type = CombatMapEntity.interaction_types.SELF
	
	
func interact(cu:CombatUnit):
	for chest_item in contents:
		cu.unit.inventory.give_item(chest_item)
