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


var unit : Unit



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

func set_value_labels(value: int, label_100:Label, label_10:Label, label_1:Label):
	if value > 99:
		label_100.self_modulate = "FFFFFF"
		label_10.self_modulate = "FFFFFF"
		label_1.self_modulate = "FFFFFF"
	elif value > 9:
		label_100.self_modulate = "828282"
		label_10.self_modulate = "FFFFFF"
		label_1.self_modulate = "FFFFFF"
	else:
		label_100.self_modulate = "828282"
		label_10.self_modulate = "828282"
		label_1.self_modulate = "FFFFFF"
	label_100.text = str((value/100)%10)
	label_10.text = str((value/10)%10)
	label_1.text = str((value/1)%10)


func update_by_unit():
	set_value_labels(unit.attack, damage_100_place_label, damage_10_place_label,damage_1_place_label)
	set_value_labels(unit.hit, hit_100_place_label, hit_10_place_label,hit_1_place_label)
	set_value_labels(unit.critical_hit, critical_100_place_label, critical_10_place_label,critical_1_place_label)
	set_value_labels(unit.avoid, avoid_100_place_label, avoid_10_place_label,avoid_1_place_label)
	set_value_labels(unit.attack_speed, attack_speed_100_place_label, attack_speed_10_place_label,attack_speed_1_place_label)
