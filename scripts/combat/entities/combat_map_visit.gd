extends CombatMapEntity
class_name CombatMapVisitEvent

@export var contents: Array[ItemDefinition]

func _init():
	#self.sprite = chest_texture
	self.targetable = false
	self.interaction_type = CombatMapEntity.interaction_types.SELF
	
	
func interact(cu:CombatUnit):
	pass
