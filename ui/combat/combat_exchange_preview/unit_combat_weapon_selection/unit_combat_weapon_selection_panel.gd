extends PanelContainer

const UNIT_COMBAT_WEAPON_SELECTION_PANEL_ALLY_THEME = preload("res://ui/combat/combat_exchange_preview/unit_combat_weapon_selection/unit_combat_weapon_selection_panel_ally_theme.tres")
const UNIT_COMBAT_WEAPON_SELECTION_PANEL_ENEMY_THEME = preload("res://ui/combat/combat_exchange_preview/unit_combat_weapon_selection/unit_combat_weapon_selection_panel_enemy_theme.tres")

@onready var unit_icon = $Panel/MarginContainer/VBoxContainer/UnitContainer/UnitIcon
@onready var unit_name = $Panel/MarginContainer/VBoxContainer/UnitContainer/UnitName
@onready var unit_type_trait_container = $Panel/MarginContainer/VBoxContainer/UnitContainer/UnitTypeTraitContainer

@onready var toggle_left_icon = $Panel/MarginContainer/VBoxContainer/WeaponSelectionContainer/ToggleLeftIcon
@onready var toggle_right_icon = $Panel/MarginContainer/VBoxContainer/WeaponSelectionContainer/ToggleRightIcon

@onready var unit_combat_weapon = $Panel/MarginContainer/VBoxContainer/WeaponSelectionContainer/HBoxContainer/UnitCombatWeapon
@onready var unit_compat_weapon_special_containter = $Panel/MarginContainer/VBoxContainer/UnitCompatWeaponSpecialContainter
@onready var advantage_arrow: AnimatedSprite2D = $Panel/MarginContainer/VBoxContainer/WeaponSelectionContainer/HBoxContainer/AdvantageArrow
@onready var disadvantage_arrow: AnimatedSprite2D = $Panel/MarginContainer/VBoxContainer/WeaponSelectionContainer/HBoxContainer/DisadvantageArrow

@onready var unit_specials = $Panel/MarginContainer/VBoxContainer/CombatUnitSpecialContainter
@onready var panel: Panel = $Panel

@export var wpn_triangle_state : String
@export var effective_damage : bool
@export var unit : CombatUnit
@export var entity : CombatEntity
@export var weapon_swap_enabled : bool 

func set_all(combatUnit: CombatUnit, weapon_swap:bool, wpn_triangle_state:String = "", ef_dmg :bool = false):
	self.unit = combatUnit
	self.weapon_swap_enabled = weapon_swap
	self.wpn_triangle_state = wpn_triangle_state
	self.effective_damage = ef_dmg
	update()

func set_toggle_button_visibility(vis):
	toggle_left_icon.visible = vis
	toggle_right_icon.visible = vis

func set_unit_icon(icon):
	unit_icon.texture = icon

func set_unit_name(name):
	unit_name.text = name

func set_advantage_icons():
	advantage_arrow.visible = false
	disadvantage_arrow.visible = false
	if wpn_triangle_state == "ADVANTAGE":
		advantage_arrow.visible = true
	if wpn_triangle_state == "DISADVANTAGE":
		disadvantage_arrow.visible = true

func update_theme():
	if unit:
		if unit.allegience == Constants.FACTION.PLAYERS:
			panel.theme = UNIT_COMBAT_WEAPON_SELECTION_PANEL_ALLY_THEME
		elif  unit.allegience == Constants.FACTION.ENEMIES:
			panel.theme = UNIT_COMBAT_WEAPON_SELECTION_PANEL_ENEMY_THEME

func update():
	set_unit_icon(unit.unit.icon)
	set_unit_name(unit.unit.name)
	set_specials()
	unit_type_trait_container.set_icon_visibility(unit.unit)
	unit_combat_weapon.item = unit.get_equipped()
	unit_combat_weapon.effective = effective_damage
	unit_combat_weapon.update_by_item()
	set_toggle_button_visibility(weapon_swap_enabled)
	set_advantage_icons()
	update_theme()

func set_all_ent(centity: CombatEntity, weapon_swap:bool):
	self.entity = centity
	self.weapon_swap_enabled = weapon_swap
	update_entity()

func update_entity():
	set_unit_icon(entity.display.sprite)
	set_unit_name(entity.name)
	unit_type_trait_container.set_all_icons_invisible()
	unit_combat_weapon.item = null
	unit_combat_weapon.update_by_item()
	set_toggle_button_visibility(weapon_swap_enabled)
	update_theme()

func set_specials():
	if unit:
		unit_specials.update_special_container(unit.unit.inventory.get_all_specials_from_inventory_and_equipped())
		
