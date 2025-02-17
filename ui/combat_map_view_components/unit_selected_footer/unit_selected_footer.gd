extends Control
class_name UnitSelectedFooterUI

@export var unit : CombatUnit

const ally_theme = preload("res://ui/combat_map_view_components/unit_selected_footer/UnitSelectedFooter_Ally.tres")
const enemy_theme = preload("res://ui/combat_map_view_components/unit_selected_footer/UnitSelectedFooter_Enemy.tres")
const generic_theme = preload("res://resources/themes/combat/default_ui_theme.tres")

func set_unit(u: CombatUnit):
	self.unit = u
	$CombatUnitPanel.set_unit(u)
	$BackPanel/MarginContainer/HBoxContainer/InventoryMarginContainer/UnitInfoInventoryContainer/UnitFooterInventoryContainer.set_inventory(u.unit.inventory)
	update()

func update():
	var _unit_type_info : UnitTypeDefinition= UnitTypeDatabase.unit_types[unit.unit.unit_class_key]
	#Left Panel
	$BackPanel/MarginContainer/HBoxContainer/InventoryMarginContainer/UnitInfoInventoryContainer/MarginContainer/UnitInfoContainer/UnitTypeLabel.text = _unit_type_info.unit_type_name
	$BackPanel/MarginContainer/HBoxContainer/InventoryMarginContainer/UnitInfoInventoryContainer/MarginContainer/UnitInfoContainer/LevelContainer/LevelLabel.text = "LV " + str(unit.unit.level)
	$BackPanel/MarginContainer/HBoxContainer/InventoryMarginContainer/UnitInfoInventoryContainer/MarginContainer/UnitInfoContainer/MoveContainer/MoveValue.text = str(unit.unit.movement)
	#HP Panel
	$BackPanel/MarginContainer/HBoxContainer/HealthMarginContainer/Health/HPValueContainer/CurrentHP.text = str(unit.unit.hp)
	$BackPanel/MarginContainer/HBoxContainer/HealthMarginContainer/Health/HPValueContainer/MaxHP.text = str(unit.unit.max_hp)
	#Stat Grid
	$BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Attack/Value.text = str(unit.unit.attack)
	$BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Hit/Value.text = str(unit.unit.hit)
	$BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Avoid/Value.text = str(unit.unit.avoid)
	$BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Speed/Value.text = str(unit.unit.attack_speed)
	$BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Res/Value.text = str(unit.unit.magic_defense)
	$BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Def/Value.text = str(unit.unit.defense)
	update_background()

func update_background():
	if unit.allegience == Constants.FACTION.PLAYERS:
		$BackPanel.theme = ally_theme
	elif unit.allegience == Constants.FACTION.ENEMIES:
		$BackPanel.theme = enemy_theme
	else:
		$BackPanel.theme = generic_theme
