extends Control


@onready var damage_value_label = $MarginContainer/VBoxContainer/HBoxContainer/LabelVaues/DamageValueLabel
@onready var scaling_value_label = $MarginContainer/VBoxContainer/HBoxContainer/LabelVaues/ScalingValueLabel
@onready var hit_value_label = $MarginContainer/VBoxContainer/HBoxContainer/LabelVaues/HitValueLabel
@onready var critical_value_label = $MarginContainer/VBoxContainer/HBoxContainer/LabelVaues/CriticalValueLabel
@onready var weight_value_label = $MarginContainer/VBoxContainer/HBoxContainer/LabelVaues/WeightValueLabel
@onready var durability_value_label = $MarginContainer/VBoxContainer/HBoxContainer/LabelVaues/DurabilityValueLabel
@onready var range_value_label = $MarginContainer/VBoxContainer/HBoxContainer/LabelVaues/RangeValueLabel
@onready var special_value_label = $MarginContainer/VBoxContainer/HBoxContainer/LabelVaues/SpecialValueLabel

var weapon : WeaponDefinition



func update_all():
	set_damage_value_label(weapon.damage)
	set_scaling_value_label(weapon.item_scaling_type)
	set_hit_value_label(weapon.hit)
	set_critical_value_label(weapon.critical_chance)
	set_weight_value_label(weapon.weight)
	set_durability_value_label(weapon.uses)
	set_range_value_label(weapon.attack_range)
	set_special_value_label() #UNKOWN CURRENTLY


func set_damage_value_label(dmg):
	damage_value_label.text = str(dmg)

func set_scaling_value_label(scaling):
	var text: String = ""
	match(scaling):
		0:
			text = "Physical"
		1:
			text = "Magic"
	scaling_value_label.text = text
	
func set_hit_value_label(hit):
	hit_value_label.text = str(hit)

func set_critical_value_label(crit):
	critical_value_label.text = str(crit)

func set_weight_value_label(wgt):
	weight_value_label.text = str(wgt)

func set_durability_value_label(uses):
	durability_value_label.text = str(uses)

func set_range_value_label(range):
	var front_value = range[0]
	var back_value = range[-1]
	if front_value == back_value:
		range_value_label.text = str(front_value)
	else:
		range_value_label.text = str(front_value) + "-" + str(back_value)

func set_special_value_label():
	special_value_label.text = ""

func randomize_weapon() -> WeaponDefinition:
	var all_item_types = ItemDatabase.items.keys()
	var all_weapon_types = []
	for item in all_item_types:
		if ItemDatabase.items.get(item) is WeaponDefinition:
			all_weapon_types.append(ItemDatabase.items.get(item))
	return all_weapon_types.pick_random()
