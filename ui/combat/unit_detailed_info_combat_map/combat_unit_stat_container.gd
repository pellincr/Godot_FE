extends VBoxContainer


@onready var damage_100_place_label = $HBoxContainer/CombatStatValueContainer/DamageValueContainer/Damage100ValueLabel
@onready var damage_10_place_label = $HBoxContainer/CombatStatValueContainer/DamageValueContainer/Damage10ValueLabel
@onready var damage_1_place_label = $HBoxContainer/CombatStatValueContainer/DamageValueContainer/Damage1ValueLabel

@onready var hit_100_place_label = $HBoxContainer/CombatStatValueContainer/HitValueContainer/Hit100ValueLabel
@onready var hit_10_place_label = $HBoxContainer/CombatStatValueContainer/HitValueContainer/Hit10ValueLabel
@onready var hit_1_place_label = $HBoxContainer/CombatStatValueContainer/HitValueContainer/Hit1ValueLabel

@onready var critical_100_place_label = $HBoxContainer/CombatStatValueContainer/CriticalValueContainer/Critical100ValueLabel
@onready var critical_10_place_label = $HBoxContainer/CombatStatValueContainer/CriticalValueContainer/Critical10ValueLabel
@onready var critical_1_place_label = $HBoxContainer/CombatStatValueContainer/CriticalValueContainer/Critical1ValueLabel

@onready var avoid_100_place_label = $HBoxContainer/CombatStatValueContainer/AvoidValueContainer/Avoid100ValueLabel
@onready var avoid_10_place_label = $HBoxContainer/CombatStatValueContainer/AvoidValueContainer/Avoid10ValueLabel
@onready var avoid_1_place_label = $HBoxContainer/CombatStatValueContainer/AvoidValueContainer/Avoid1ValueLabel

@onready var attack_speed_100_place_label = $HBoxContainer/CombatStatValueContainer/AttackSpeedValueContainer/AttackSpeed100ValueLabel
@onready var attack_speed_10_place_label = $HBoxContainer/CombatStatValueContainer/AttackSpeedValueContainer/AttackSpeed10ValueLabel
@onready var attack_speed_1_place_label = $HBoxContainer/CombatStatValueContainer/AttackSpeedValueContainer/AttackSpeed1ValueLabel


var unit : CombatUnit



# Called when the node enters the scene tree for the first time.
func _ready():
	if unit != null:
		update_by_unit()


func set_value_label(label:Label, value):
	label.text = str(value)
	if value == 0:
		label.self_modulate = "828282"
	else:
		label.self_modulate = "FFFFFF"


func update_by_unit():
	
	set_value_label(damage_100_place_label, (unit.get_damage()/100)%10)
	set_value_label(damage_10_place_label, (unit.get_damage()/10)%10)
	set_value_label(damage_1_place_label, (unit.get_damage()/1)%10)
	
	set_value_label(hit_100_place_label, (unit.get_hit()/100)%10)
	set_value_label(hit_10_place_label, (unit.get_hit()/10)%10)
	set_value_label(hit_1_place_label, (unit.get_hit()/1)%10)
	
	set_value_label(critical_100_place_label, (unit.get_critical_chance()/100)%10)
	set_value_label(critical_10_place_label, (unit.get_critical_chance()/10)%10)
	set_value_label(critical_1_place_label, (unit.get_critical_chance()/1)%10)
	
	set_value_label(avoid_100_place_label, (unit.get_avoid()/100)%10)
	set_value_label(avoid_10_place_label, (unit.get_avoid()/10)%10)
	set_value_label(avoid_1_place_label, (unit.get_avoid()/1)%10)
	
	set_value_label(attack_speed_100_place_label, (unit.get_attack_speed()/100)%10)
	set_value_label(attack_speed_10_place_label, (unit.get_attack_speed()/10)%10)
	set_value_label(attack_speed_1_place_label, (unit.get_attack_speed()/1)%10)
