extends PanelContainer



@onready var item_name_label: Label = $MarginContainer/MainContainer/ItemNameLabel
@onready var item_icon: TextureRect = $MarginContainer/MainContainer/ItemNameLabel/ItemIcon
@onready var item_worth_label: Label = $MarginContainer/MainContainer/ItemNameLabel/ItemIcon/ItemWorthLabel
@onready var item_description_label: Label = $MarginContainer/MainContainer/ItemDescriptionLabel
@onready var item_effect_value_label: Label = $MarginContainer/MainContainer/ItemEffectContainer/ItemEffectValueLabel
@onready var power_value_label: Label = $MarginContainer/MainContainer/ItemPowerContainer/PowerValueLabel
@onready var uses_value_label: Label = $MarginContainer/MainContainer/ItemUsesContainer/UsesValueLabel

@onready var item_stats_boost_container: VBoxContainer = $MarginContainer/MainContainer/ItemStatsBoostContainer

@onready var health_stat_container: HBoxContainer = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/HealthStatContainer
@onready var health_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/HealthStatContainer/HealthStatValueLabel
@onready var strength_stat_container: HBoxContainer = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/StrengthStatContainer
@onready var strength_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/StrengthStatContainer/StrengthStatValueLabel
@onready var magic_stat_container: HBoxContainer = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/MagicStatContainer
@onready var magic_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/MagicStatContainer/MagicStatValueLabel
@onready var skill_stat_container: HBoxContainer = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/SkillStatContainer
@onready var skill_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/SkillStatContainer/SkillStatValueLabel
@onready var speed_stat_container: HBoxContainer = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/SpeedStatContainer
@onready var speed_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/SpeedStatContainer/SpeedStatValueLabel
@onready var luck_stat_container: HBoxContainer = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/LuckStatContainer
@onready var luck_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/LuckStatContainer/LuckStatValueLabel
@onready var defense_stat_container: HBoxContainer = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/DefenseStatContainer
@onready var defense_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/DefenseStatContainer/DefenseStatValueLabel
@onready var resistance_stat_container: HBoxContainer = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/ResistanceStatContainer
@onready var resistance_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostBoostContainer/ResistanceStatContainer/ResistanceStatValueLabel

@onready var item_growths_boost_container: VBoxContainer = $MarginContainer/MainContainer/ItemGrowthsBoostContainer

@onready var health_growth_container: HBoxContainer = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/HealthGrowthContainer
@onready var health_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/HealthGrowthContainer/HealthGrowthValueLabel
@onready var strength_growth_container: HBoxContainer = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/StrengthGrowthContainer
@onready var strength_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/StrengthGrowthContainer/StrengthGrowthValueLabel
@onready var magic_growth_container: HBoxContainer = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/MagicGrowthContainer
@onready var magic_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/MagicGrowthContainer/MagicGrowthValueLabel
@onready var skill_growth_container: HBoxContainer = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/SkillGrowthContainer
@onready var skill_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/SkillGrowthContainer/SkillGrowthValueLabel
@onready var speed_growth_container: HBoxContainer = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/SpeedGrowthContainer
@onready var speed_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/SpeedGrowthContainer/SpeedGrowthValueLabel
@onready var luck_growth_container: HBoxContainer = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/LuckGrowthContainer
@onready var luck_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/LuckGrowthContainer/LuckGrowthValueLabel
@onready var defense_growth_container: HBoxContainer = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/DefenseGrowthContainer
@onready var defense_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/DefenseGrowthContainer/DefenseGrowthValueLabel
@onready var resistance_growth_container: HBoxContainer = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/ResistanceGrowthContainer
@onready var resistance_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/ResistanceGrowthContainer/ResistanceGrowthValueLabel


@onready var item_type: Label = $MarginContainer/MainContainer/ItemTypeContainer/ItemType
@onready var item_type_header: Label = $MarginContainer/MainContainer/ItemTypeContainer/ItemTypeHeader


var item : ItemDefinition

func _ready() -> void:
	#item = ItemDatabase.items.get("bastion_crab")
	if item:
		update_by_item()

func set_name_label(n):
	item_name_label.text = n

func set_icon(texture):
	item_icon.texture = texture

func set_item_description_label(description_text):
	item_description_label.text = description_text

func set_item_effect_label(effect:ItemConstants.CONSUMABLE_USE_EFFECT):
	var text = ""
	match effect:
		ItemConstants.CONSUMABLE_USE_EFFECT.HEAL:
			text = "Healing Consumable"
		ItemConstants.CONSUMABLE_USE_EFFECT.DAMAGE:
			text = "Damage Consumable"
		ItemConstants.CONSUMABLE_USE_EFFECT.STAT_BOOST:
			text = "Stat Booster"
		ItemConstants.CONSUMABLE_USE_EFFECT.STATUS_EFFECT:
			text = "STATUS_EFFECT"
		ItemConstants.CONSUMABLE_USE_EFFECT.KEY:
			text = "Key"
	item_type.text = text

func set_value_label(label,value):
	label.text = str(value)

func set_value_label_percent(label,value):
	label.text = str(value) + "%"

func set_growths_boost_container(growths:UnitStat):
	var health = growths.hp
	var strength = growths.strength
	var magic = growths.magic
	var skill = growths.skill
	var speed = growths.speed
	var luck = growths.luck
	var defense = growths.defense
	var resistance = growths.resistance
	if health != 0:
		set_value_label_percent(health_growth_value_label,health)
	else:
		health_growth_container.visible = false
	if strength != 0:
		set_value_label_percent(strength_growth_value_label,strength)
	else:
		strength_growth_container.visible = false
	if magic != 0:
		set_value_label_percent(magic_growth_value_label,magic)
	else:
		magic_growth_container.visible = false
	if skill != 0:
		set_value_label_percent(skill_growth_value_label,skill)
	else:
		skill_growth_container.visible = false
	if speed != 0:
		set_value_label_percent(speed_growth_value_label,speed)
	else:
		speed_growth_container.visible = false
	if luck != 0:
		set_value_label_percent(luck_growth_value_label,luck)
	else:
		luck_growth_container.visible = false
	if defense != 0:
		set_value_label_percent(defense_growth_value_label,defense)
	else:
		defense_growth_container.visible = false
	if resistance != 0:
		set_value_label_percent(resistance_growth_value_label,resistance)
	else:
		resistance_growth_container.visible = false

func set_stats_boost_container(stats:UnitStat):
	var health = stats.hp
	var strength = stats.strength
	var magic = stats.magic
	var skill = stats.skill
	var speed = stats.speed
	var luck = stats.luck
	var defense = stats.defense
	var resistance = stats.resistance
	var constitution = stats.constitution
	var move = stats.movement
	if health != 0:
		set_value_label(health_stat_value_label,health)
	else:
		health_stat_container.visible = false
	if strength != 0:
		set_value_label(strength_stat_value_label,strength)
	else:
		strength_stat_container.visible = false
	if magic != 0:
		set_value_label(magic_stat_value_label,magic)
	else:
		magic_stat_container.visible = false
	if skill != 0:
		set_value_label(skill_stat_value_label,skill)
	else:
		skill_stat_container.visible = false
	if speed != 0:
		set_value_label(speed_stat_value_label,speed)
	else:
		speed_stat_container.visible = false
	if luck != 0:
		set_value_label(luck_stat_value_label,luck)
	else:
		luck_stat_container.visible = false
	if defense != 0:
		set_value_label(defense_stat_value_label,defense)
	else:
		defense_stat_container.visible = false
	if resistance != 0:
		set_value_label(resistance_stat_value_label,resistance)
	else:
		resistance_stat_container.visible = false

func update_by_item():
	set_name_label(item.name)
	set_icon(item.icon)
	set_value_label(item_worth_label,item.calculate_price())
	set_item_description_label(item.description)
	set_item_effect_label(item.use_effect)
	set_value_label(power_value_label,item.power)
	set_value_label(uses_value_label,item.uses)
	set_item_type_header(item)
	set_item_rarity_header(item.rarity)
	if item.use_effect == ItemConstants.CONSUMABLE_USE_EFFECT.STAT_BOOST:
		if item.boost_stat:
			set_stats_boost_container(item.boost_stat)
		else:
			item_stats_boost_container.visible = false
		if item.boost_growth:
			set_growths_boost_container(item.boost_growth)
		else:
			item_growths_boost_container.visible = false
	else:
		item_stats_boost_container.visible = false
		item_growths_boost_container.visible = false


func set_item_type_header(item: ItemDefinition):
	match item.item_type:
		ItemConstants.ITEM_TYPE.WEAPON:
			item_type_header.text = "Weapon"
		ItemConstants.ITEM_TYPE.STAFF:
			item_type_header.text = "Staff"
		ItemConstants.ITEM_TYPE.USEABLE_ITEM:
			item_type_header.text = "Consumable"
		ItemConstants.ITEM_TYPE.EQUIPMENT:
			item_type_header.text = "Equipment"
		ItemConstants.ITEM_TYPE.TREASURE:
			item_type_header.text = "Treasure"

func set_item_rarity_header(rarity : Rarity):
	item_type_header.text = rarity.rarity_name
	item_type_header.self_modulate = rarity.ui_color
