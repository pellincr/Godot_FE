extends Control

@export var unit : CombatUnit

const ally_theme = preload("res://ui/combat/unit_selected_footer/UnitSelectedFooter_Ally.tres")
const enemy_theme = preload("res://ui/combat/unit_selected_footer/UnitSelectedFooter_Enemy.tres")
const generic_theme = preload("res://resources/themes/combat/default_ui_theme.tres")

@onready var mounted_icon = $PanelContainer/MarginContainer/HBoxContainer/IconContainer/mountedIcon
@onready var armor_icon = $PanelContainer/MarginContainer/HBoxContainer/IconContainer/armorIcon
@onready var undead_icon = $PanelContainer/MarginContainer/HBoxContainer/IconContainer/undeadIcon
@onready var flyer_icon = $PanelContainer/MarginContainer/HBoxContainer/IconContainer/flyerIcon

func set_unit(u: CombatUnit):
	self.unit = u
	update()

func update():
	$PanelContainer/MarginContainer/HBoxContainer/UnitIcon.texture = unit.unit.map_sprite
	$PanelContainer/MarginContainer/HBoxContainer/UnitName.text = unit.unit.name
	show_icons()
	update_background()

func show_icons():
	##UnitTypeDatabase.unit_types[target.unit_type_key].class_type
	#("Infantry","Calvary", "Armored", "Monster", "Animal", "Flying""res://resources/definitions/unit_types/fighter.tres"
	var unit_type = UnitTypeDatabase.get_definition(unit.unit.unit_type_key)
	var unit_types = unit_type.traits
	if not unit_types.is_empty():
		mounted_icon.visible = unit_types.has(unitConstants.TRAITS.MOUNTED)
		armor_icon.visible = unit_types.has(unitConstants.TRAITS.ARMORED)
		flyer_icon.visible = unit_types.has(unitConstants.TRAITS.FLIER)
		undead_icon.visible = unit_types.has(unitConstants.TRAITS.TERROR)
	else :
		mounted_icon.visible = false
		armor_icon.visible = false
		flyer_icon.visible = false
		undead_icon.visible = false

func update_background():
	if unit.allegience == Constants.FACTION.PLAYERS:
		$PanelContainer.theme = ally_theme
	elif unit.allegience == Constants.FACTION.ENEMIES:
		$PanelContainer.theme = enemy_theme
	else:
		$PanelContainer.theme = generic_theme
