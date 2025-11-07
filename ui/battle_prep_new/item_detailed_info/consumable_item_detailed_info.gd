extends PanelContainer



@onready var item_name_label: Label = $MarginContainer/MainContainer/ItemNameLabel
@onready var item_icon: TextureRect = $MarginContainer/MainContainer/ItemNameLabel/ItemIcon
@onready var item_worth_label: Label = $MarginContainer/MainContainer/ItemNameLabel/ItemIcon/ItemWorthLabel
@onready var item_description_label: Label = $MarginContainer/MainContainer/ItemDescriptionLabel
@onready var item_effect_value_label: Label = $MarginContainer/MainContainer/ItemEffectContainer/ItemEffectValueLabel
@onready var power_value_label: Label = $MarginContainer/MainContainer/ItemPowerContainer/PowerValueLabel
@onready var uses_value_label: Label = $MarginContainer/MainContainer/ItemUsesContainer/UsesValueLabel

@onready var item_stats_boost_container: VBoxContainer = $MarginContainer/MainContainer/ItemStatsBoostContainer
@onready var strength_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/StrengthStatValueLabel
@onready var magic_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/MagicStatValueLabel
@onready var skill_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/SkillStatValueLabel
@onready var speed_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/SpeedStatValueLabel
@onready var luck_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/LuckStatValueLabel
@onready var defense_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/DefenseStatValueLabel
@onready var resistance_stat_value_label: Label = $MarginContainer/MainContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/ResistanceStatValueLabel

@onready var item_growths_boost_container: VBoxContainer = $MarginContainer/MainContainer/ItemGrowthsBoostContainer
@onready var strength_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/StrengthGrowthValueLabel
@onready var magic_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/MagicGrowthValueLabel
@onready var skill_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/SkillGrowthValueLabel
@onready var speed_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/SpeedGrowthValueLabel
@onready var luck_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/LuckGrowthValueLabel
@onready var defense_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/DefenseGrowthValueLabel
@onready var resistance_growth_value_label: Label = $MarginContainer/MainContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/ResistanceGrowthValueLabel

var item : ConsumableItemDefinition

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
			text = "HEAL"
		ItemConstants.CONSUMABLE_USE_EFFECT.DAMAGE:
			text = "DAMAGE"
		ItemConstants.CONSUMABLE_USE_EFFECT.STAT_BOOST:
			text = "STAT BOOST"
		ItemConstants.CONSUMABLE_USE_EFFECT.STATUS_EFFECT:
			text = "STATUS_EFFECT"
		ItemConstants.CONSUMABLE_USE_EFFECT.KEY:
			text = "KEY"
	item_effect_value_label.text = text

func set_value_label(label,value):
	label.text = str(value)

func set_stat_boost_container(stats:UnitStat, growths:= false):
	var strength = stats.strength
	var magic = stats.magic
	var skill = stats.skill
	var speed = stats.speed
	var luck = stats.luck
	var defense = stats.defense
	var resistance = stats.resistance
	if !growths:
		set_value_label(strength_stat_value_label,strength)
		set_value_label(magic_stat_value_label,magic)
		set_value_label(skill_stat_value_label,skill)
		set_value_label(speed_stat_value_label,speed)
		set_value_label(luck_stat_value_label,luck)
		set_value_label(defense_stat_value_label,defense)
		set_value_label(resistance_stat_value_label,resistance)
	else:
		set_value_label(strength_growth_value_label,strength)
		set_value_label(magic_growth_value_label,magic)
		set_value_label(skill_growth_value_label,skill)
		set_value_label(speed_growth_value_label,speed)
		set_value_label(luck_growth_value_label,luck)
		set_value_label(defense_growth_value_label,defense)
		set_value_label(resistance_growth_value_label,resistance)


func update_by_item():
	set_name_label(item.name)
	set_icon(item.icon)
	set_value_label(item_worth_label,item.worth)
	set_item_description_label(item.description)
	set_item_effect_label(item.use_effect)
	set_value_label(power_value_label,item.power)
	set_value_label(uses_value_label,item.uses)
	if item.use_effect == ItemConstants.CONSUMABLE_USE_EFFECT.STAT_BOOST:
		if item.boost_stat:
			set_stat_boost_container(item.boost_stat)
		else:
			item_stats_boost_container.visible = false
		if item.boost_growth:
			set_stat_boost_container(item.boost_growth, true)
		else:
			item_growths_boost_container.visible = false
	else:
		item_stats_boost_container.visible = false
		item_growths_boost_container.visible = false
