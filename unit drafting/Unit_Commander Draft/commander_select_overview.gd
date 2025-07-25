extends Control

@onready var weapon_trait_icon_container = $VBoxContainer/WeaponTraitIconContainer

func set_icon_visibility(unit):
	weapon_trait_icon_container.set_icon_visibility(unit)
