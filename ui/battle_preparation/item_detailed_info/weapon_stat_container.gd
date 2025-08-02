extends VBoxContainer


@onready var damage_value_label = $DamageContainer/DamageValueLabel
@onready var scaling_value_label = $ScalingContainer/ScalingValueLabel
@onready var hit_value_label = $HitContainer/HitValueLabel
@onready var critical_value_label = $CriticalContainer/CriticalValueLabel
@onready var weight_value_label = $WeightContainer/WeightValueLabel
@onready var durability_value_label = $DurabilityContainer/DurablityValueLabel
@onready var range_value_label = $RangeContainer/RangeValueLabel
@onready var special_value_label = $SpecialContainer/SpecialValueLabel
@onready var effective_trait_icon_container = $EffectiveContainer/TraitIconContainer

var item : ItemDefinition


func set_damage_value(dmg):
	damage_value_label.text = str(dmg)

func set_scaling_value(scaler):
	scaling_value_label.text = scaler #Unsure how this will be updated when weapons are updated

func set_hit_value(hit):
	hit_value_label.text = str(hit)

func set_critical_label(crit):
	critical_value_label.text = str(crit)

func set_weight_value(wgt):
	weight_value_label.text = str(wgt)

func set_durability_value(uses):
	durability_value_label.text = str(uses)

func set_range_value(range):
	var min = range[0]
	var max = range[-1]
	if min != max:
		range_value_label.text = str(min) + "/" + str(max)
	else:
		range_value_label.text = str(min)

func set_special_value(spec):
	special_value_label.text = spec

func fill_effective_trait_icons():
	pass

func update_by_item():
	if item is WeaponDefinition:
		set_damage_value(item.damage)
		#set_scaling_value(item.item_scaling_type)
		set_hit_value(item.hit)
		set_critical_label(item.critical_chance)
		set_weight_value(item.weight)
		set_durability_value(item.uses)
		set_range_value(item.attack_range)
		#set_special_value()
		#fill_effective_trait_icons()
