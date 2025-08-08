extends HBoxContainer


@onready var damage_value_label = $VBoxContainer/DamageContainer/DamageValueLabel
@onready var hit_value_label = $VBoxContainer/HitContainer/HitValueLabel
@onready var critical_value_label = $VBoxContainer/CriticalContainer/CriticalValueLabel
@onready var range_value_label = $VBoxContainer/RangeContainer/RangeValueLabel

@onready var damage_type_icon = $VBoxContainer/DamageContainer/DamageTypeIcon

@onready var requirements_icon_container = $VBoxContainer/RequirementsContainer/RequirementsIconContainer


@onready var armored_icon = $VBoxContainer2/EffectiveContainer/EffectiveTraitIconContainer/ArmoredIcon
@onready var mounted_icon = $VBoxContainer2/EffectiveContainer/EffectiveTraitIconContainer/MountedIcon
@onready var flier_icon = $VBoxContainer2/EffectiveContainer/EffectiveTraitIconContainer/FlierIcon
@onready var undead_icon = $VBoxContainer2/EffectiveContainer/EffectiveTraitIconContainer/UndeadIcon


@onready var durability_value_label = $VBoxContainer2/DurabilityContainer/DurablityValueLabel
@onready var weight_value_label = $VBoxContainer2/WeightContainer/WeightValueLabel
@onready var effective_trait_icon_container = $VBoxContainer2/EffectiveContainer/EffectiveTraitIconContainer
@onready var scaling_value_label = $VBoxContainer2/ScalingContainer/ScalingValueLabel


var item : ItemDefinition


func set_damage_value(dmg):
	damage_value_label.text = str(dmg)

func set_scaling_value(scaler):
	match scaler:
		ItemConstants.SCALING_TYPE.STRENGTH:
			scaling_value_label.text = "Strength"
		ItemConstants.SCALING_TYPE.MAGIC:
			scaling_value_label.text = "Magic"
		ItemConstants.SCALING_TYPE.SKILL:
			scaling_value_label.text = "Skill"
		ItemConstants.SCALING_TYPE.CONSTITUTION:
			scaling_value_label.text = "Constitution"
		ItemConstants.SCALING_TYPE.NONE:
			scaling_value_label.text = "-"

func set_damage_type_icon(damage_type):
	var physical_icon = preload("res://resources/sprites/icons/damage_icons/physical_damage_icon.png")
	var magic_icon = preload("res://resources/sprites/icons/damage_icons/magic_damage_icon.png")
	match damage_type:
		ItemConstants.DAMAGE_TYPE.PHYSICAL:
			damage_type_icon.texture = physical_icon
		ItemConstants.DAMAGE_TYPE.MAGIC:
			damage_type_icon.texture = magic_icon

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

func set_effective_trait_visibility(effective_traits):
	if effective_traits.has(unitConstants.TRAITS.ARMORED):
		armored_icon.visible = true
	if effective_traits.has(unitConstants.TRAITS.MOUNTED):
		mounted_icon.visible = true
	if effective_traits.has(unitConstants.TRAITS.FLIER):
		flier_icon.visible = true
	if effective_traits.has(unitConstants.TRAITS.UNDEAD):
		undead_icon.visible = true


func update_by_item():
	if item is WeaponDefinition:
		set_damage_value(item.damage)
		set_damage_type_icon(item.item_damage_type)
		set_scaling_value(item.item_scaling_type)
		set_hit_value(item.hit)
		set_critical_label(item.critical_chance)
		set_weight_value(item.weight)
		set_durability_value(item.uses)
		set_range_value(item.attack_range)
		set_effective_trait_visibility(item.weapon_effectiveness)
