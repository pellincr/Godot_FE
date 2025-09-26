extends Control
class_name UnitSelectedFooterUI

@onready var level_container = $VBoxContainer/BackPanel/MarginContainer/HBoxContainer/InventoryMarginContainer/UnitInfoInventoryContainer/MarginContainer/UnitInfoContainer/LevelContainer

@onready var move_container = $VBoxContainer/BackPanel/MarginContainer/HBoxContainer/InventoryMarginContainer/UnitInfoInventoryContainer/MarginContainer/UnitInfoContainer/MoveContainer
@onready var current_move_value = $VBoxContainer/BackPanel/MarginContainer/HBoxContainer/InventoryMarginContainer/UnitInfoInventoryContainer/MarginContainer/UnitInfoContainer/MoveContainer/CurrentMoveValue
@onready var total_move_value = $VBoxContainer/BackPanel/MarginContainer/HBoxContainer/InventoryMarginContainer/UnitInfoInventoryContainer/MarginContainer/UnitInfoContainer/MoveContainer/TotalMoveValue

@onready var health_container = $VBoxContainer/BackPanel/MarginContainer/HBoxContainer/HealthMarginContainer/HealthContainer
@onready var current_hp = $VBoxContainer/BackPanel/MarginContainer/HBoxContainer/HealthMarginContainer/HealthContainer/Health/HPValueContainer/CurrentHP
@onready var max_hp = $VBoxContainer/BackPanel/MarginContainer/HBoxContainer/HealthMarginContainer/HealthContainer/Health/HPValueContainer/MaxHP
@onready var health_bar = $VBoxContainer/BackPanel/MarginContainer/HBoxContainer/HealthMarginContainer/HealthContainer/HealthBar

@export var unit : CombatUnit

const ally_theme = preload("res://ui/combat/unit_selected_footer/UnitSelectedFooter_Ally.tres")
const enemy_theme = preload("res://ui/combat/unit_selected_footer/UnitSelectedFooter_Enemy.tres")
const generic_theme = preload("res://resources/themes/combat/default_ui_theme.tres")

func set_unit(u: CombatUnit):
	self.unit = u
	$VBoxContainer/CombatUnitPanel.set_unit(u)
	$VBoxContainer/BackPanel/MarginContainer/HBoxContainer/InventoryMarginContainer/UnitInfoInventoryContainer/MarginContainer2/UnitFooterInventoryContainer.set_inventory(u.unit.inventory)
	update()

func update():
	var _unit_type_info = UnitTypeDatabase.get_definition(unit.unit.unit_type_key)

	#Left Panel
	$VBoxContainer/BackPanel/MarginContainer/HBoxContainer/InventoryMarginContainer/UnitInfoInventoryContainer/MarginContainer/UnitInfoContainer/UnitTypeLabel.text = _unit_type_info.unit_type_name
	level_container.set_level_label(unit.unit.level)
	level_container.set_xp_label(unit.unit.experience)
	level_container.set_level_progress_value(unit.unit.experience)
	current_move_value.text = str(unit.unit.movement)
	total_move_value.text = str(unit.unit.movement)
	#HP Panel
	current_hp.text = str(unit.current_hp)
	max_hp.text = str(unit.stats.max_hp.evaluate())
	health_bar.max_value = unit.stats.max_hp.evaluate()
	health_bar.value = unit.current_hp
	
	
	#Stat Grid
	$VBoxContainer/BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Attack/Value.text = str(unit.unit.attack)
	$VBoxContainer/BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Hit/Value.text = str(unit.unit.hit)
	$VBoxContainer/BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Avoid/Value.text = str(unit.unit.avoid)
	$VBoxContainer/BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Speed/Value.text = str(unit.unit.attack_speed)
	$VBoxContainer/BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Res/Value.text = str(unit.unit.stats.resistance)
	$VBoxContainer/BackPanel/MarginContainer/HBoxContainer/StatsGridMargin/CenterContainer/StatsGrid/Def/Value.text = str(unit.unit.stats.defense)
	update_background()

func update_background():
	if unit.allegience == Constants.FACTION.PLAYERS:
		$VBoxContainer/BackPanel.theme = ally_theme
	elif unit.allegience == Constants.FACTION.ENEMIES:
		$VBoxContainer/BackPanel.theme = enemy_theme
	else:
		$VBoxContainer/BackPanel.theme = generic_theme
