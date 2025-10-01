extends Control


@onready var weapon_trait_icon_container = $VBoxContainer/WeaponTraitIconContainer

@onready var weapon_name = $VBoxContainer/WeaponContainer/WeaponName
@onready var weapon_ability = $VBoxContainer/WeaponContainer/HBoxContainer/WeaponAbility
@onready var weapon_image = $VBoxContainer/WeaponContainer/HBoxContainer/WeaponImage

@onready var special_value_label_1 = $VBoxContainer/WeaponContainer/HBoxContainer/SpecialAndBonusValueContainer/SpecialValueLabel1
@onready var special_value_label_2 = $VBoxContainer/WeaponContainer/HBoxContainer/SpecialAndBonusValueContainer/SpecialValueLabel2
@onready var special_value_label_3 = $VBoxContainer/WeaponContainer/HBoxContainer/SpecialAndBonusValueContainer/SpecialValueLabel3
@onready var special_value_label_4 = $VBoxContainer/WeaponContainer/HBoxContainer/SpecialAndBonusValueContainer/SpecialValueLabel4
@onready var special_value_label_5 = $VBoxContainer/WeaponContainer/HBoxContainer/SpecialAndBonusValueContainer/SpecialValueLabel5
@onready var special_value_labels = [special_value_label_1,special_value_label_2,special_value_label_3,special_value_label_4,special_value_label_5]

var weapon : WeaponDefinition

func _ready():
	if weapon:
		update_by_weapon()

func set_icon_visibility(unit):
	weapon_trait_icon_container.unit = unit
	weapon_trait_icon_container.set_icon_visibility()

func set_weapon_name(name):
	weapon_name.text = name

func set_weapon_image(texture):
	weapon_image.texture = texture

func set_weapon_ability(ability):
	weapon_ability.text = ability

func update_by_weapon():
	set_weapon_image(weapon.icon)
	set_weapon_name(weapon.name)
	set_special_values(weapon.bonus_stat, weapon.specials)


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
			str = "Cannot Retaliate"
		WeaponDefinition.WEAPON_SPECIALS.DEVIL_REVERSAL:
			str = "Devil Reversal"
	special_label.text = str

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

func set_special_values(bonus_stats:UnitStat, specials:Array[WeaponDefinition.WEAPON_SPECIALS]):
	for special_index in special_value_labels.size():
		if special_index < specials.size():
			set_special_value(special_value_labels[special_index],specials[special_index])
		elif bonus_stats:
			set_bonus_value(special_value_labels[special_index],bonus_stats)
			bonus_stats = null
		else:
			special_value_labels[special_index].text = ""


func turn_stat_to_string(header:String,stat:int):
	if stat != 0:
		return header + str(stat) + "\n"
	else:
		return ""
