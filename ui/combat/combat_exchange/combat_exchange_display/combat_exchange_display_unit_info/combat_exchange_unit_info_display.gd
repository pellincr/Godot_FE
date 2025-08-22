extends Control
class_name CombatExchangeUnitInfoDisplay

const ALLY_THEME = preload("res://resources/themes/combat/ally_ui_theme.tres")
const ENEMY_THEME = preload("res://resources/themes/combat/enemy_ui_theme.tres")
const GENERIC_THEME = preload("res://resources/themes/combat/default_ui_theme.tres")


enum wpn_triange {
	NONE, 
	WIN,
	LOSS
}
const down_arrow_char = "↓"
const up_arrow_char = "↑"

var tween_complete :bool = true
var tween_active : bool = false

var unit: CombatUnit
var hit_chance: int
var damage : int
var critical_chance : int 
var weapon_effective: bool = false
var weapon: ItemDefinition
var wpn_triangle_state : wpn_triange = wpn_triange.NONE

func set_all(cu : CombatUnit, hc: int, dmg: int, crit_chance: int, wpn_eff: bool, wts: int ):
	self.unit = cu
	self.hit_chance =hc
	self.damage = dmg
	self.critical_chance = crit_chance
	self.weapon_effective = wpn_eff
	self.weapon = cu.get_equipped()
	self.wpn_triangle_state = wts
	update()

func update_hp_bar():
	$Unit/MarginContainer/VBoxContainer/HealthBar.set_initial_value(unit.current_hp)
	$Unit/MarginContainer/VBoxContainer/HealthBar.set_max_value(unit.stats.max_hp.evaluate())

func hp_bar_tween(value:int): 
	$Unit/MarginContainer/VBoxContainer/HealthBar.set_desired_value(value)
	$Unit/MarginContainer/VBoxContainer/HealthBar.activate_tween()
	await $Unit/MarginContainer/VBoxContainer/HealthBar.finished

func update():
	update_hp_bar()
	update_weapon()
	update_unit_fields()
	update_wpn_triangle_indicators()
	update_comb_exchange_fields()

func update_unit_fields():
	$Unit/MarginContainer/VBoxContainer/HBoxContainer/UnitName.text = unit.unit.name
	$Unit/UnitIcon.texture = unit.unit.icon
	$Unit/MarginContainer/VBoxContainer/StatsGrid/AttackSpeedValue.text = str(unit.stats.attack_speed.evaluate())

func update_weapon():
	if weapon:
		$Unit/MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = weapon.icon
	else: 
			$Unit/MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = null

func update_comb_exchange_fields():
	$Unit/MarginContainer/VBoxContainer/StatsGrid/HitValue.text = str(hit_chance)
	$Unit/MarginContainer/VBoxContainer/StatsGrid/AttackValue.text = str(damage)
	$Unit/MarginContainer/VBoxContainer/StatsGrid/CriticalValue.text = str(critical_chance)
	
	
func update_wpn_triangle_indicators():
	$Unit/MarginContainer/VBoxContainer/HBoxContainer/TextureRect/wpn_triangle_win.visible = false
	$Unit/MarginContainer/VBoxContainer/HBoxContainer/TextureRect/wpn_triangle_loss.visible = false
	if wpn_triangle_state == wpn_triange.WIN :
		$Unit/MarginContainer/VBoxContainer/HBoxContainer/TextureRect/wpn_triangle_win.visible = true
	if wpn_triangle_state == wpn_triange.LOSS :
		$Unit/MarginContainer/VBoxContainer/HBoxContainer/TextureRect/wpn_triangle_loss.visible = true

func _process(delta):
	if weapon_effective: 
		if tween_complete:
				tween_complete = false 
				effectiveness_tween()

func effectiveness_tween():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property($Unit/MarginContainer/VBoxContainer/HBoxContainer/TextureRect, "modulate", Color.GREEN, .5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property($Unit/MarginContainer/VBoxContainer/HBoxContainer/TextureRect, "modulate", Color.WHITE, .5).set_trans(Tween.TRANS_SINE).set_delay(.5)
	await tween.finished
	tween_complete = true

func update_background():
	if unit.allegience == Constants.FACTION.PLAYERS:
		$Unit.theme = ALLY_THEME
	elif unit.allegience == Constants.FACTION.ENEMIES:
		$Unit.theme = ENEMY_THEME
	else:
		$Unit.theme = GENERIC_THEME
