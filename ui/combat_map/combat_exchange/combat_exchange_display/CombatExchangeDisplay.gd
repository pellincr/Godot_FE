extends Control
class_name CombatExchangeDisplay

var unitL: Unit
var unitR: Unit

func create(u1 : Unit, u2:Unit, hc1:int, hc2:int, dmg1:int, dmg2:int, cc1:int, cc2:int, we1: bool, we2:bool, wt:Unit):
	var instance = CombatExchangeDisplay.new()
	instance.set_all(u1, u2, hc1, hc2, dmg1, dmg2, cc1, cc2, we1, we2, wt)

#var wpn_triangle_state : wpn_triange = wpn_triange.NONE
func set_all(u1 : Unit, u2:Unit, hc1:int, hc2:int, dmg1:int, dmg2:int, cc1:int, cc2:int, we1: bool, we2:bool, wt:Unit):
	self.unitL = u1
	self.unitR = u2
	if wt == u1: 
		$BackgroundBlur/HBoxContainer/UnitDisplayL.set_all(u1, hc1, dmg1,cc1,we1,1)
		$BackgroundBlur/HBoxContainer/UnitDisplayR.set_all(u2, hc2, dmg2,cc2,we2,2)
	elif wt == u2: 
		$BackgroundBlur/HBoxContainer/UnitDisplayL.set_all(u1, hc1, dmg1,cc1,we1,2)
		$BackgroundBlur/HBoxContainer/UnitDisplayR.set_all(u2, hc2, dmg2,cc2,we2,1)
	else : 
		$BackgroundBlur/HBoxContainer/UnitDisplayL.set_all(u1, hc1, dmg1,cc1,we1,0)
		$BackgroundBlur/HBoxContainer/UnitDisplayR.set_all(u2, hc2, dmg2,cc2,we2,0)

func update_unit_hp(unit: Unit, val:int):
	if (unit == unitL):
		await $BackgroundBlur/HBoxContainer/UnitDisplayL.hp_bar_tween(val)
	if(unit == unitR):
		await $BackgroundBlur/HBoxContainer/UnitDisplayR.hp_bar_tween(val)
