extends Control
class_name CombatMapEntityDisplay

var reference_entity : CombatMapEntity

static func create(cme : CombatMapEntity) -> CombatMapEntityDisplay:
	var instance = CombatMapEntityDisplay.new()
	await instance.ready
	instance.set_reference_entity(cme)
	return instance

func set_reference_entity_sprite(texture: Texture2D) :
	$Sprite.texture = texture

func set_reference_entity(entity: CombatMapEntity) :
	self.reference_entity = entity
	set_reference_entity_sprite(entity.sprite)
