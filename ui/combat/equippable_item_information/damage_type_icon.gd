extends TextureRect
class_name DamageTypeIcon

const MAGIC_DAMAGE_ICON = preload("res://resources/sprites/icons/damage_icons/magic_damage_icon.png")
const PHYSICAL_DAMAGE_ICON = preload("res://resources/sprites/icons/damage_icons/physical_damage_icon.png")
const TRUE_DAMAGE_ICON = preload("res://resources/sprites/icons/damage_icons/true_damage_icon.png")

@export var damage_type : Constants.DAMAGE_TYPE = Constants.DAMAGE_TYPE.NONE

func _ready() -> void:
	update_display()

func set_damage_type(source: Constants.DAMAGE_TYPE):
	self.damage_type = source
	update_display()

func update_display():
	match self.damage_type:
		Constants.DAMAGE_TYPE.PHYSICAL:
			self.texture = PHYSICAL_DAMAGE_ICON
		Constants.DAMAGE_TYPE.MAGIC:
			self.texture = MAGIC_DAMAGE_ICON
		Constants.DAMAGE_TYPE.TRUE:
			self.texture = TRUE_DAMAGE_ICON
		Constants.DAMAGE_TYPE.NONE:
			self.texture = null
