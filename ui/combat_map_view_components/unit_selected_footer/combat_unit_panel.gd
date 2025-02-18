extends Control

@export var unit : CombatUnit

const ally_theme = preload("res://ui/combat_map_view_components/unit_selected_footer/CombatUnitPanelFriendly.tres")
const enemy_theme = preload("res://ui/combat_map_view_components/unit_selected_footer/CombatUnitPanelEnemy.tres")
const generic_theme = preload("res://resources/themes/combat/default_ui_theme.tres")

func set_unit(u: CombatUnit):
	self.unit = u
	update()

func update():
	$PanelContainer/MarginContainer/HBoxContainer/UnitIcon.texture = unit.unit.map_sprite
	$PanelContainer/MarginContainer/HBoxContainer/UnitName.text = unit.unit.unit_name
	show_icons()
	update_background()

func show_icons():
	##UnitTypeDatabase.unit_types[target.unit_class_key].class_type
	#("Infantry","Calvary", "Armored", "Monster", "Animal", "Flying""res://resources/definitions/unit_types/fighter.tres"
	var unit_types = UnitTypeDatabase.unit_types[unit.unit.unit_class_key].class_type
	$PanelContainer/MarginContainer/HBoxContainer/IconContainer/calvaryIcon.visible = unit_types.has("Calvary")
	$PanelContainer/MarginContainer/HBoxContainer/IconContainer/monsterIcon.visible = unit_types.has("Monster")
	$PanelContainer/MarginContainer/HBoxContainer/IconContainer/flyerIcon.visible = unit_types.has("Flying")
	$PanelContainer/MarginContainer/HBoxContainer/IconContainer/armorIcon.visible = unit_types.has("Armored")
	$PanelContainer/MarginContainer/HBoxContainer/IconContainer/animalIcon.visible = unit_types.has("Animal")

func update_background():
	if unit.allegience == Constants.FACTION.PLAYERS:
		$PanelContainer.theme = ally_theme
	elif unit.allegience == Constants.FACTION.ENEMIES:
		$PanelContainer.theme = enemy_theme
	else:
		$PanelContainer.theme = generic_theme
