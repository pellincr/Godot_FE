extends HBoxContainer

var item : ItemDefinition
#Left Container
@onready var damage_value_label = $LeftContainer/CombatStatsContainer/DamageContainer/DamageValueLabel
@onready var damage_type_icon = $LeftContainer/CombatStatsContainer/DamageContainer/DamageTypeIcon
@onready var attack_x_value_label = $LeftContainer/CombatStatsContainer/AttackXContainer/AttackXValueLabel
@onready var hit_value_label = $LeftContainer/CombatStatsContainer/HitContainer/HitValueLabel
@onready var critical_value_label = $LeftContainer/CombatStatsContainer/CriticalContainer/CriticalValueLabel
@onready var critical_x_value_label = $LeftContainer/CombatStatsContainer/CritXContainer/CriticalXValueLabel
@onready var range_value_label = $LeftContainer/CombatStatsContainer/RangeContainer/RangeValueLabel

@onready var special_value_label_1 = $LeftContainer/SpecialAndBonusContainer/SpecialAndBonusValueContainer/SpecialValueLabel1
@onready var special_value_label_2 = $LeftContainer/SpecialAndBonusContainer/SpecialAndBonusValueContainer/SpecialValueLabel2
@onready var special_value_label_3 = $LeftContainer/SpecialAndBonusContainer/SpecialAndBonusValueContainer/SpecialValueLabel3
@onready var special_value_label_4 = $LeftContainer/SpecialAndBonusContainer/SpecialAndBonusValueContainer/SpecialValueLabel4
@onready var special_value_label_5 = $LeftContainer/SpecialAndBonusContainer/SpecialAndBonusValueContainer/SpecialValueLabel5
@onready var special_value_labels = [special_value_label_1,special_value_label_2,special_value_label_3,special_value_label_4,special_value_label_5]

func set_damage_value(dmg):
	damage_value_label.text = str(dmg)

func set_damage_type_icon(damage_type):
	var physical_icon = preload("res://resources/sprites/icons/damage_icons/physical_damage_icon.png")
	var magic_icon = preload("res://resources/sprites/icons/damage_icons/magic_damage_icon.png")
	var true_icon = preload("res://resources/sprites/icons/damage_icons/true_damage_icon.png")
	match damage_type:
		ItemConstants.DAMAGE_TYPE.PHYSICAL:
			damage_type_icon.texture = physical_icon
		ItemConstants.DAMAGE_TYPE.MAGIC:
			damage_type_icon.texture = magic_icon
		ItemConstants.DAMAGE_TYPE.PURE:
			damage_type_icon.texture = true_icon

func set_attack_x_value(attack_x):
	attack_x_value_label.text = str(attack_x)

func set_hit_value(hit):
	hit_value_label.text = str(hit)

func set_critical_label(crit):
	critical_value_label.text = str(crit)

func set_critical_x_value(crit_x):
	critical_x_value_label.text = str(crit_x)

func set_range_value(range):
	var min = range[0]
	var max = range[-1]
	if min != max:
		range_value_label.text = str(min) + "/" + str(max)
	else:
		range_value_label.text = str(min)

func turn_stat_to_string(header:String,stat:int):
	if stat != 0:
		return header + str(stat) + "\n"
	else:
		return ""

func set_bonus_value(special_label :Label, weapon_bonus_stats:UnitStat):
	var hp_bonus = turn_stat_to_string("HP: ",weapon_bonus_stats.hp)
	var strength_bonus = turn_stat_to_string("STR: ",weapon_bonus_stats.strength)
	var magic_bonus = turn_stat_to_string("MGC: ",weapon_bonus_stats.magic)
	var skill_bonus = turn_stat_to_string("SKILL: ",weapon_bonus_stats.skill)
	var speed_bonus = turn_stat_to_string("SPD: ",weapon_bonus_stats.speed)
	var luck_bonus = turn_stat_to_string("LUCK: ",weapon_bonus_stats.luck)
	var defense_bonus = turn_stat_to_string("DEF: ", weapon_bonus_stats.defense)
	var resistance_bonus = turn_stat_to_string("RES: ",weapon_bonus_stats.resistance)
	var combined_string = hp_bonus + strength_bonus + magic_bonus +  skill_bonus +  speed_bonus + luck_bonus + defense_bonus + resistance_bonus
	if combined_string != "":
		special_label.text = "BONUS STATS:\n" + combined_string
	else:
		special_label.text = ""


func set_special_value(special_label, weapon_special: WeaponDefinition.WEAPON_SPECIALS):
	var str = ""
	match weapon_special:
		WeaponDefinition.WEAPON_SPECIALS.WEAPON_TRIANGLE_ADVANTAGE_EFFECTIVE:
			str = "Weapon Adv. Eff."
		WeaponDefinition.WEAPON_SPECIALS.CRITICAL_DISABLED:
			str = "Crits Disabled"
		WeaponDefinition.WEAPON_SPECIALS.VAMPYRIC:
			str = "Vampyric"
		WeaponDefinition.WEAPON_SPECIALS.NEGATES_FOE_DEFENSE:
			str = "True Damage"
		WeaponDefinition.WEAPON_SPECIALS.NEGATES_FOE_DEFENSE_ON_CRITICAL:
			str = "Critical True Damage"
		WeaponDefinition.WEAPON_SPECIALS.HEAL_10_PERCENT_ON_TURN_BEGIN:
			str = "10% Hp Regen"
		WeaponDefinition.WEAPON_SPECIALS.CANNOT_RETALIATE:
			str = "Cannot retailate"
		WeaponDefinition.WEAPON_SPECIALS.DEVIL_REVERSAL:
			str = "Devil Reversal"
	special_label.text = str

func set_special_values(bonus_stats:UnitStat, specials:Array[WeaponDefinition.WEAPON_SPECIALS]):
	for special_index in special_value_labels.size():
		if special_index < specials.size():
			set_special_value(special_value_labels[special_index],specials[special_index])
		elif bonus_stats:
			set_bonus_value(special_value_labels[special_index],bonus_stats)
			bonus_stats = null
		else:
			special_value_labels[special_index].text = ""

#Right Container
@onready var scaling_value_label = $RightContainer/ScalingContainer/ScalingValueLabel
@onready var scaling_x_value_label = $RightContainer/ScalingXContainer/ScalingXValueLabel
@onready var durability_value_label = $RightContainer/DurabilityContainer/DurabilityValueLabel
@onready var weight_value_label = $RightContainer/WeightContainer/WeightValueLabel
@onready var requirements_container = $RightContainer/RequirementsContainer

@onready var effective_trait_icon_container = $RightContainer/EffectiveContainer/EffectiveTraitIconContainer
@onready var armored_icon = $RightContainer/EffectiveContainer/EffectiveTraitIconContainer/ArmoredIcon
@onready var mounted_icon = $RightContainer/EffectiveContainer/EffectiveTraitIconContainer/MountedIcon
@onready var flier_icon = $RightContainer/EffectiveContainer/EffectiveTraitIconContainer/FlierIcon
@onready var undead_icon = $RightContainer/EffectiveContainer/EffectiveTraitIconContainer/UndeadIcon



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

func set_scaling_x_value(mult : float):
	scaling_x_value_label.text = str(mult)

func set_durability_value(uses):
	durability_value_label.text = str(uses)

func set_weight_value(wgt):
	weight_value_label.text = str(wgt)

func set_requirements_container(requirement: itemConstants.MASTERY_REQUIREMENT):
	var str = ""
	var label = Label.new()
	match requirement:
		itemConstants.MASTERY_REQUIREMENT.E:
			str = "E"
		itemConstants.MASTERY_REQUIREMENT.D:
			str = "D"
		itemConstants.MASTERY_REQUIREMENT.C:
			str = "C"
		itemConstants.MASTERY_REQUIREMENT.B:
			str = "B"
		itemConstants.MASTERY_REQUIREMENT.A:
			str = "A"
		itemConstants.MASTERY_REQUIREMENT.S:
			str = "S"
	label.text = str
	requirements_container.add_child(label)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

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
		#Left Container
		set_damage_value(item.damage)
		set_damage_type_icon(item.item_damage_type)
		set_attack_x_value(item.attacks_per_combat_turn)
		set_hit_value(item.hit)
		set_critical_label(item.critical_chance)
		set_critical_x_value(item.critical_multiplier)
		set_range_value(item.attack_range)
		set_special_values(item.bonus_stat, item.specials)
		#Right Container
		set_scaling_value(item.item_scaling_type)
		set_scaling_x_value(1)#TO BE UPDATED WHEN WEAPON IS UPDATED
		set_durability_value(item.uses)
		set_weight_value(item.weight)
		set_requirements_container(item.required_mastery)
		set_effective_trait_visibility(item.weapon_effectiveness)
		
