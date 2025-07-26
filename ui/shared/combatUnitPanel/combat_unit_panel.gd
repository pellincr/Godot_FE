extends Control

@export var unit : CombatUnit

const ally_theme = preload("res://ui/combat/unit_selected_footer/UnitSelectedFooter_Ally.tres")
const enemy_theme = preload("res://ui/combat/unit_selected_footer/UnitSelectedFooter_Enemy.tres")
const generic_theme = preload("res://resources/themes/combat/default_ui_theme.tres")

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
	var unit_types = UnitTypeDatabase.unit_types[unit.unit.unit_type_key].traits
	$PanelContainer/MarginContainer/HBoxContainer/IconContainer/calvaryIcon.visible = unit_types.has(unitConstants.TRAITS.MOUNTED)
	$PanelContainer/MarginContainer/HBoxContainer/IconContainer/armorIcon.visible = unit_types.has(unitConstants.TRAITS.ARMORED)

func update_background():
	if unit.allegience == Constants.FACTION.PLAYERS:
		$PanelContainer.theme = ally_theme
	elif unit.allegience == Constants.FACTION.ENEMIES:
		$PanelContainer.theme = enemy_theme
	else:
		$PanelContainer.theme = generic_theme
