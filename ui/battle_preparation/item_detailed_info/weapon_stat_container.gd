extends HBoxContainer


@onready var damage_value_label = $VBoxContainer/DamageContainer/DamageValueLabel
@onready var hit_value_label = $VBoxContainer/HitContainer/HitValueLabel
@onready var critical_value_label = $VBoxContainer/CriticalContainer/CriticalValueLabel
@onready var range_value_label = $VBoxContainer/RangeContainer/RangeValueLabel
@onready var requirements_icon_container = $VBoxContainer/RequirementsContainer/RequirementsIconContainer

@onready var durability_value_label = $VBoxContainer2/DurabilityContainer/DurablityValueLabel
@onready var weight_value_label = $VBoxContainer2/WeightContainer/WeightValueLabel
@onready var effective_trait_icon_container = $VBoxContainer2/EffectiveContainer/EffectiveTraitIconContainer
@onready var scaling_value_label = $VBoxContainer2/ScalingContainer/ScalingValueLabel


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
		#fill_effective_trait_icons()
