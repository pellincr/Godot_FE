extends Control

class_name EquippableItemInformation

var current_equipped_stat: unitInUseStat 
var hover_stat : unitInUseStat

"""
func set_unit(input : Unit):
	self.unit = input

func set_bases():
	set_damage_base()
	set_hit_base()
	set_crit_base()
	set_avoid_base()

func do_projections(weapon: WeaponDefinition):
	do_damage_projection(weapon)
	do_hit_projection(weapon)
	do_crit_projection(weapon)
	do_avoid_projection(weapon)
	
func set_damage_base():
	damage = unit.attack
	damage_projection = damage
	$Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/LeftValueContainer/DamageValue.text = str(damage)
	set_field_color(damage,damage_projection, $Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/LeftValueContainer/DamageValue)
	
	
func do_damage_projection(weapon: WeaponDefinition):
	damage = unit.attack 
	damage_projection = unit.calculate_attack(weapon)
	$Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/LeftValueContainer/DamageValue.text = str(damage_projection)
	set_field_color(damage,damage_projection, $Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/LeftValueContainer/DamageValue)


func do_hit_projection(weapon: WeaponDefinition):
	hit = unit.hit 
	hit_projection = unit.calculate_hit(weapon)
	$Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/LeftValueContainer/HitValue.text = str(hit_projection)
	set_field_color(hit,hit_projection, $Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/LeftValueContainer/HitValue)

func set_hit_base():
	hit = unit.hit
	hit_projection = hit
	$Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/LeftValueContainer/HitValue.text = str(hit)
	set_field_color(hit,hit_projection, $Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/LeftValueContainer/HitValue)

func do_crit_projection(weapon: WeaponDefinition):
	crit = unit.critical_hit
	crit_projection = unit.calculate_critical_hit(weapon)
	$Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/RightValueContainer/CritValue.text = str(crit_projection)
	set_field_color(crit,crit_projection, $Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/RightValueContainer/CritValue)
	
func set_crit_base():
	crit = unit.critical_hit
	crit_projection = crit
	$Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/RightValueContainer/CritValue.text = str(crit)
	set_field_color(crit,crit_projection, $Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/RightValueContainer/CritValue)


func do_avoid_projection(weapon: WeaponDefinition):
	avoid = unit.avoid
	avoid_projection = unit.calculate_avoid(weapon)
	$Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/RightValueContainer/AvoidValue.text = str(avoid_projection)
	set_field_color(avoid,avoid_projection, $Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/RightValueContainer/AvoidValue)
	
func set_avoid_base():
	avoid = unit.avoid
	avoid_projection = avoid
	$Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/RightValueContainer/AvoidValue.text = str(avoid)
	set_field_color(avoid,avoid_projection, $Panel/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/RightValueContainer/AvoidValue)
	


func update_values(weapon:WeaponDefinition):
	if unit:
		if weapon and weapon != unit.inventory.get_equipped_weapon():
			do_projections(weapon)
		else :
			set_bases()

func set_field_color(current: int, projection: int, label: Label):
	if(current < projection):
		label.add_theme_color_override("font_color", Color.GREEN)
	elif (current > projection):
		label.add_theme_color_override("font_color", Color.RED)
	else:
		label.add_theme_color_override("font_color", Color.WHITE)

"""
