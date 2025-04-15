extends CombatMapEntity
class_name CombatMapDoorEntity

@export var required_item : Array[ItemDefinition] = [preload("res://resources/definitions/items/consumables/skeleton_key.tres")]
#Create an entity group?
@export var entity_position_group : Array[Vector2i]
#@export var mov_blocks : Array[UnitTypeDefinition.unit_movement_classes] = [UnitTypeDefinition.unit_movement_classes.Generic,UnitTypeDefinition.unit_movement_classes.Mobile,
#UnitTypeDefinition.unit_movement_classes.Heavy, UnitTypeDefinition.unit_movement_classes.Mounted,UnitTypeDefinition.unit_movement_classes.Flying]
const effective_terrain : Terrain = preload("res://resources/definitions/terrians/door_terrain.tres")
@export var door_texture : Texture2D = preload("res://resources/sprites/entities/door_sprite.tres")

func _init():
	self.sprite = door_texture
	self.targetable = false
	self.interaction_type = CombatMapEntity.interaction_types.ADJACENT
	self.terrain = effective_terrain

func interact(cu:CombatUnit):
	pass
