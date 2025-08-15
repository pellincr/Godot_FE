extends VBoxContainer


@onready var damage_value = $HBoxContainer/DamageValue
@onready var physical_damage_type = $HBoxContainer/PhysicalDamageType
@onready var magical_damage_type = $HBoxContainer/MagicalDamageType

@onready var attack_direction_arrow = $AttackDirectionArrow

func set_damage_value_label(dmg):
	damage_value.text = str(dmg)

func hide_all_damage_type_icons():
	physical_damage_type.visible = false
	magical_damage_type.visible = false

func set_damage_type_icon_visibility(dmg_type):
	hide_all_damage_type_icons()
	match dmg_type:
		ItemConstants.DAMAGE_TYPE.PHYSICAL:
			physical_damage_type.visible = true
		ItemConstants.DAMAGE_TYPE.MAGIC:
			magical_damage_type.visible = true

func flip_attack_direction_arrow():
	attack_direction_arrow.flip_h = true
