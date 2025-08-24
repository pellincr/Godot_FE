extends Control


@onready var weapon_trait_icon_container = $VBoxContainer/WeaponTraitIconContainer

@onready var weapon_name = $VBoxContainer/WeaponContainer/WeaponName
@onready var weapon_ability = $VBoxContainer/WeaponContainer/HBoxContainer/WeaponAbility
@onready var weapon_image = $VBoxContainer/WeaponContainer/HBoxContainer/WeaponImage

var weapon : WeaponDefinition

func _ready():
	if weapon:
		update_by_weapon()

func set_icon_visibility(unit):
	weapon_trait_icon_container.unit = unit
	weapon_trait_icon_container.set_icon_visibility()

func set_weapon_name(name):
	weapon_name.text = name

func set_weapon_image(texture):
	weapon_image.texture = texture

func set_weapon_ability(ability):
	weapon_ability.text = ability

func update_by_weapon():
	set_weapon_image(weapon.icon)
	set_weapon_name(weapon.name)
