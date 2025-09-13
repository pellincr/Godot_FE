extends Control
class_name CombatEntityDisplay

var sprite : Texture2D

func set_reference_entity_sprite(texture: Texture2D) :
	sprite = texture
	$Sprite.texture = texture
