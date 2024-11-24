extends Control

class_name UnitStatusUI

const ally_theme = preload("res://resources/themes/combat/ally_ui_theme.tres")
const enemy_theme = preload("res://resources/themes/combat/enemy_ui_theme.tres")
const generic_theme = preload("res://resources/themes/combat/default_ui_theme.tres")

var unit : CombatUnit

func set_unit(input_unit:CombatUnit):
	self.unit = input_unit
	update_fields()

func set_unit_icon(value: Texture2D) : 
	$UnitIcon.texture = value

func set_unit_name(value: String) : 
	$UnitName.text = value
	
func set_unit_health_bar_values(max: int, current:int) : 
	$HealthBar/Bar.max_value = max
	$HealthBar/Bar.value = current
	$HealthBar/Value.text = convert_int_to_bar_format(max, current)

func set_unit_xp_bar_values(max: int, current:int) : 
	$XpBar/Bar.max_value = max
	$XpBar/Bar.value = current
	$XpBar/Value.text = convert_int_to_bar_format(max, current)

func set_unit_level_label(value: int):
	$XpBar/UnitLevelLabel.text = "LV " + str(value)

func convert_int_to_bar_format(max:int, current: int) -> String:
	return str(current) + " / " + str(max) 

func update_stats_grid(attack: int, hit:int, attack_speed:int, avoid:int): 	
	update_attack_value(attack)
	update_hit_value(hit)
	update_attack_speed_value(attack_speed)
	update_avoid_value(avoid)
	
func update_attack_value(value: int): 
	$StatsGrid/AttackValue.text = str(value)

func update_hit_value(value: int): 
	$StatsGrid/HitValue.text = str(value)
	
func update_attack_speed_value(value: int): 
	$StatsGrid/AttackSpeedValue.text = str(value)

func update_avoid_value(value: int): 
	$StatsGrid/AvoidValue.text = str(value)
	
func update_unit_name(value: String): 
	$UnitName.text = value

func update_background():
	if unit.allegience == Constants.FACTION.PLAYERS:
		$BackgroundContainer.theme = ally_theme
	elif unit.allegience == Constants.FACTION.ENEMIES:
		$BackgroundContainer.theme = enemy_theme
	else:
		$BackgroundContainer.theme = generic_theme

func update_fields():
	update_unit_name(unit.unit.unit_name)
	set_unit_icon(unit.unit.icon)
	set_unit_health_bar_values(unit.unit.max_hp, unit.unit.hp)
	set_unit_xp_bar_values(100, unit.unit.experience)
	set_unit_level_label(unit.unit.level)
	update_stats_grid(unit.unit.attack, unit.unit.hit,unit.unit.attack_speed, unit.unit.avoid)
	update_background()
	
