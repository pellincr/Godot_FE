extends PanelContainer

@onready var unit_icon = $Panel/MarginContainer/VBoxContainer/UnitContainer/UnitIcon
@onready var unit_name = $Panel/MarginContainer/VBoxContainer/UnitContainer/UnitName
@onready var unit_type_trait_container = $Panel/MarginContainer/VBoxContainer/UnitContainer/UnitTypeTraitContainer

@onready var toggle_left_icon = $Panel/MarginContainer/VBoxContainer/WeaponSelectionContainer/ToggleLeftIcon
@onready var toggle_right_icon = $Panel/MarginContainer/VBoxContainer/WeaponSelectionContainer/ToggleRightIcon

@onready var unit_combat_weapon = $Panel/MarginContainer/VBoxContainer/WeaponSelectionContainer/UnitCombatWeapon
@onready var unit_compat_weapon_special_containter = $Panel/MarginContainer/VBoxContainer/UnitCompatWeaponSpecialContainter

@export var unit : Unit

func set_unit(u: Unit):
	self.unit = u
	update()

func set_toggle_button_visibility(vis):
	toggle_left_icon.visible = vis
	toggle_right_icon.visible = vis

func set_unit_icon(icon):
	unit_icon.texture = icon

func set_unit_name(name):
	unit_name.text = name

func update():
	set_unit_icon(unit.icon)
	set_unit_name(unit.name)
	unit_type_trait_container.set_icon_visibility(unit)
	unit_combat_weapon.item = unit.inventory.get_equipped_weapon()
	unit_combat_weapon.update_by_item()
