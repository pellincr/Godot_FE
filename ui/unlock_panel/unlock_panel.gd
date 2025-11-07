extends PanelContainer

class_name UnlockPanel


@onready var icon = $MarginContainer/VBoxContainer/Icon
@onready var unlocked_entity_name = $MarginContainer/VBoxContainer/UnlockedEntityName

@onready var animated_sprite_2d = $MarginContainer/AnimatedSprite2D
@onready var animated_sprite_2d_2 = $MarginContainer/AnimatedSprite2D2
@onready var animated_sprite_2d_3 = $MarginContainer/AnimatedSprite2D3
@onready var animated_sprite_2d_4 = $MarginContainer/AnimatedSprite2D4

var unlocked_entity = null

func _ready():
	#unlocked_entity = UnitTypeDatabase.commander_types["mage_knight"]
	if unlocked_entity:
		update_by_unlocked_entity()


func set_icon(texture):
	icon.texture = texture

func set_unlocked_entity_id(id):
	unlocked_entity_name.text = id

func update_by_unlocked_entity():
	set_icon(unlocked_entity.icon)
	if unlocked_entity is UnitTypeDefinition:
		set_unlocked_entity_id(unlocked_entity.unit_type_name)
	animated_sprite_2d.play("unlock")
	animated_sprite_2d_2.play("unlock")
	animated_sprite_2d_3.play("unlock")
	animated_sprite_2d_4.play("unlock")
