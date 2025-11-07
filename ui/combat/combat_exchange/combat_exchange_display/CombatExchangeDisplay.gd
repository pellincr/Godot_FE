extends Control
class_name CombatExchangeDisplay

var unitL: CombatUnit
var unitR: CombatUnit

@onready var unit_display_l: CombatExchangeUnitInfoDisplay = $BackgroundBlur/HBoxContainer/UnitDisplayL
@onready var unit_display_r: CombatExchangeUnitInfoDisplay = $BackgroundBlur/HBoxContainer/UnitDisplayR

func create(u1 : CombatUnit, u2:CombatUnit, hc1:int, hc2:int, dmg1:int, dmg2:int, cc1:int, cc2:int, we1: bool, we2:bool, wt:Unit):
	var instance = CombatExchangeDisplay.new()
	instance.set_all(u1, u2, hc1, hc2, dmg1, dmg2, cc1, cc2, we1, we2, wt)

#var wpn_triangle_state : wpn_triange = wpn_triange.NONE
func set_all(u1 : CombatUnit, u2:CombatUnit, hc1:int, hc2:int, dmg1:int, dmg2:int, cc1:int, cc2:int, we1: bool, we2:bool, wt:Unit):
	self.unitL = u1
	self.unitR = u2
	if wt == u1.unit: 
		unit_display_l.set_all(u1, hc1, dmg1,cc1,we1,1)
		unit_display_r.set_all(u2, hc2, dmg2,cc2,we2,2)
	elif wt == u2.unit: 
		unit_display_l.set_all(u1, hc1, dmg1,cc1,we1,2)
		unit_display_r.set_all(u2, hc2, dmg2,cc2,we2,1)
	else : 
		unit_display_l.set_all(u1, hc1, dmg1,cc1,we1,0)
		unit_display_r.set_all(u2, hc2, dmg2,cc2,we2,0)

func update_unit_hp(unit: CombatUnit, val:int):
	if (unit == unitL):
		await unit_display_l.hp_bar_tween(val)
	if(unit == unitR):
		await unit_display_r.hp_bar_tween(val)
