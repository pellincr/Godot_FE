extends PanelContainer


@onready var item_name_label: Label = $MarginContainer/VBoxContainer/ItemNameLabel
@onready var item_icon: TextureRect = $MarginContainer/VBoxContainer/ItemNameLabel/ItemIcon
@onready var item_description_label: Label = $MarginContainer/VBoxContainer/ItemDescriptionLabel
@onready var item_rarity: Label = $MarginContainer/VBoxContainer/ItemTypeContainer/ItemRarity
@onready var item_type: Label = $MarginContainer/VBoxContainer/ItemTypeContainer/ItemType
@onready var price_label: Label = $MarginContainer/VBoxContainer/ItemNameLabel/ItemIcon/PriceLabel


@onready var item_stats_boost_container: VBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer
@onready var health_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/HealthContainer
@onready var health_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/HealthContainer/HealthStatValueLabel
@onready var damage_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/DamageContainer
@onready var damage_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/DamageContainer/DamageStatValueLabel
@onready var hit_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/HitContainer
@onready var hit_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/HitContainer/HitStatValueLabel
@onready var avoid_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/AvoidContainer
@onready var avoid_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/AvoidContainer/AvoidStatValueLabel
@onready var attack_speed_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/AttackSpeedContainer
@onready var attack_speed_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/AttackSpeedContainer/AttackSpeedStatValueLabel
@onready var crit_chance_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/CritChanceContainer
@onready var crit_chance_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/CritChanceContainer/CritChanceStatValueLabel
@onready var crit_mult_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/CritMultContainer
@onready var crit_mult_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/CritMultContainer/CritMultStatValueLabel
@onready var crit_avoid_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/CritAvoidContainer
@onready var crit_avoid_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/CritAvoidContainer/CritAvoidStatValueLabel
@onready var strength_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/StrengthContainer
@onready var strength_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/StrengthContainer/StrengthStatValueLabel
@onready var magic_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/MagicContainer
@onready var magic_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/MagicContainer/MagicStatValueLabel
@onready var skill_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/SkillContainer
@onready var skill_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/SkillContainer/SkillStatValueLabel
@onready var speed_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/SpeedContainer
@onready var speed_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/SpeedContainer/SpeedStatValueLabel
@onready var luck_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/LuckContainer
@onready var luck_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/LuckContainer/LuckStatValueLabel
@onready var defense_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/DefenseContainer
@onready var defense_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/DefenseContainer/DefenseStatValueLabel
@onready var resistance_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/ResistanceContainer
@onready var resistance_stat_value_label: Label = $MarginContainer/VBoxContainer/ItemStatsBoostContainer/ItemStatsBoostContainer/ResistanceContainer/ResistanceStatValueLabel


@onready var item_growths_boost_container: VBoxContainer = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer
@onready var health_growth_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/HealthGrowthContainer
@onready var health_growth_value_label: Label = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/HealthGrowthContainer/HealthGrowthValueLabel
@onready var strength_growth_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/StrengthGrowthContainer
@onready var strength_growth_value_label: Label = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/StrengthGrowthContainer/StrengthGrowthValueLabel
@onready var magic_growth_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/MagicGrowthContainer
@onready var magic_growth_value_label: Label = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/MagicGrowthContainer/MagicGrowthValueLabel
@onready var skill_growth_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/SkillGrowthContainer
@onready var skill_growth_value_label: Label = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/SkillGrowthContainer/SkillGrowthValueLabel
@onready var speed_growth_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/SpeedGrowthContainer
@onready var speed_growth_value_label: Label = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/SpeedGrowthContainer/SpeedGrowthValueLabel
@onready var luck_growth_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/LuckGrowthContainer
@onready var luck_growth_value_label: Label = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/LuckGrowthContainer/LuckGrowthValueLabel
@onready var defense_growth_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/DefenseGrowthContainer
@onready var defense_growth_value_label: Label = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/DefenseGrowthContainer/DefenseGrowthValueLabel
@onready var resistance_growth_container: HBoxContainer = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/ResistanceGrowthContainer
@onready var resistance_growth_value_label: Label = $MarginContainer/VBoxContainer/ItemGrowthsBoostContainer/ItemGrowthsBoostContainer/ResistanceGrowthContainer/ResistanceGrowthValueLabel

@onready var special_effects_container: VBoxContainer = $MarginContainer/VBoxContainer/SpecialEffectsContainer


var item : ItemDefinition


func _ready() -> void:
	#item = ItemDatabase.items.get("jester_mask")
	if item:
		update_by_item()

func set_item_name_label(n):
	item_name_label.text = n

func set_item_icon(texture):
	item_icon.texture = texture

func set_price_label(value):
	price_label.text = str(value) + "G" 

func set_item_description_label(desc):
	item_description_label.text = desc

func set_value_label(label,value):
	label.text = str(value)

func set_stat_boost_container(stats:CombatUnitStat):
	var max_health = stats.hp
	var damage = stats.damage
	var hit = stats.hit
	var avoid = stats.avoid
	var attack_speed = stats.attack_speed
	var crit_chance = stats.critical_chance
	var crit_mult = stats.critical_multiplier
	var crit_avoid = stats.critical_avoid
	var strength = stats.strength
	var magic = stats.magic
	var skill = stats.skill
	var speed = stats.speed
	var luck = stats.luck
	var defense = stats.defense
	var resistance = stats.resistance
	if max_health != 0:
		set_value_label(health_stat_value_label,max_health)
	else:
		health_container.visible = false
	if damage != 0:
		set_value_label(damage_stat_value_label,damage)
	else:
		damage_container.visible = false
	if hit != 0:
		set_value_label(hit_stat_value_label,hit)
	else:
		hit_container.visible = false
	if avoid != 0:
		set_value_label(avoid_stat_value_label,avoid)
	else:
		avoid_container.visible = false
	if attack_speed != 0:
		set_value_label(attack_speed_stat_value_label,attack_speed)
	else:
		attack_speed_container.visible = false
	if attack_speed != 0:
		set_value_label(attack_speed_stat_value_label,attack_speed)
	else:
		attack_speed_container.visible = false
	if crit_chance != 0:
		set_value_label(crit_chance_stat_value_label,crit_chance)
	else:
		crit_chance_container.visible = false
	if crit_mult != 0:
		set_value_label(crit_mult_stat_value_label,crit_mult)
	else:
		crit_mult_container.visible = false
	if crit_avoid != 0:
		set_value_label(crit_avoid_stat_value_label,crit_avoid)
	else:
		crit_avoid_container.visible = false
	if strength != 0:
		set_value_label(strength_stat_value_label,strength)
	else:
		strength_container.visible = false
	if magic != 0:
		set_value_label(magic_stat_value_label,magic)
	else:
		magic_container.visible = false
	if skill != 0:
		set_value_label(skill_stat_value_label,skill)
	else:
		skill_container.visible = false
	if speed != 0:
		set_value_label(speed_stat_value_label,speed)
	else:
		speed_container.visible = false
	if luck != 0:
		set_value_label(luck_stat_value_label,luck)
	else:
		luck_container.visible = false
	if defense != 0:
		set_value_label(defense_stat_value_label,defense)
	else:
		defense_container.visible = false
	if resistance != 0:
		set_value_label(resistance_stat_value_label,resistance)
	else:
		resistance_container.visible = false


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
		set_value_label(health_growth_value_label,health)
	else:
		health_growth_value_label.visible = false
	if strength != 0:
		set_value_label(strength_growth_value_label,strength)
	else:
		strength_growth_container.visible = false
	if magic != 0:
		set_value_label(magic_growth_value_label,magic)
	else:
		magic_growth_container.visible = false
	if skill != 0:
		set_value_label(skill_growth_value_label,skill)
	else:
		skill_growth_container.visible = false
	if speed != 0:
		set_value_label(speed_growth_value_label,speed)
	else:
		speed_growth_container.visible = false
	if luck != 0:
		set_value_label(luck_growth_value_label,luck)
	else:
		luck_growth_container.visible = false
	if defense != 0:
		set_value_label(defense_growth_value_label,defense)
	else:
		defense_growth_container.visible = false
	if resistance != 0:
		set_value_label(resistance_growth_value_label,resistance)
	else:
		resistance_growth_container.visible = false

func update_special_container(held_specials:Array[SpecialEffect]):
	for held_special in held_specials:
		var spec_text = held_special.to_string()
		var label = Label.new()
		label.text = spec_text
		special_effects_container.add_child(label)


func update_by_item():
	set_item_name_label(item.name)
	set_item_icon(item.icon)
	set_item_description_label(item.description)
	set_item_type_header(item)
	set_item_rarity_header(item.rarity)
	set_price_label(item.worth)
	if item.inventory_bonus_stats:
		item_stats_boost_container.visible = true
		set_stat_boost_container(item.inventory_bonus_stats)
	if item.inventory_growth_bonus_stats:
		item_growths_boost_container.visible = true
		set_growths_boost_container(item.inventory_growth_bonus_stats)
	if item.held_specials:
		update_special_container(item.held_specials)
		special_effects_container.visible = true
		

func set_item_rarity_header(rarity : Rarity):
	item_rarity.text = rarity.rarity_name
	item_rarity.self_modulate = rarity.ui_color

func set_item_type_header(item: ItemDefinition):
	match item.item_type:
		ItemConstants.ITEM_TYPE.WEAPON:
			item_type.text = "Weapon"
		ItemConstants.ITEM_TYPE.STAFF:
			item_type.text = "Staff"
		ItemConstants.ITEM_TYPE.USEABLE_ITEM:
			item_type.text = "Consumable"
		ItemConstants.ITEM_TYPE.EQUIPMENT:
			item_type.text = "Equipment"
		ItemConstants.ITEM_TYPE.TREASURE:
			item_type.text = "Treasure"
