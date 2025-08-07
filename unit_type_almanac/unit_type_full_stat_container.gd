extends VBoxContainer


@onready var health_base_value_label = $HealthContainer/ValueContainer/BaseValueLabel
@onready var health_max_value_label = $HealthContainer/ValueContainer/MaxValueLabel
@onready var health_growth_value_label = $HealthContainer/ValueContainer/GrowthValueLabel

@onready var strength_base_value_label = $StrengthContainer/ValueContainer/BaseValueLabel
@onready var strength_max_value_label = $StrengthContainer/ValueContainer/MaxValueLabel
@onready var strength_growth_value_label = $StrengthContainer/ValueContainer/GrowthValueLabel

@onready var magic_base_value_label = $MagicContainer/ValueContainer/BaseValueLabel
@onready var magic_max_value_label = $MagicContainer/ValueContainer/MaxValueLabel
@onready var magic_growth_value_label = $MagicContainer/ValueContainer/GrowthValueLabel

@onready var skill_base_value_label = $SkillContainer/ValueContainer/BaseValueLabel
@onready var skill_max_value_label = $SkillContainer/ValueContainer/MaxValueLabel
@onready var skill_growth_value_label = $SkillContainer/ValueContainer/GrowthValueLabel

@onready var speed_base_value_label = $SpeedContainer/ValueContainer/BaseValueLabel
@onready var speed_max_value_label = $SpeedContainer/ValueContainer/MaxValueLabel
@onready var speed_growth_value_label = $SpeedContainer/ValueContainer/GrowthValueLabel

@onready var luck_base_value_label = $LuckContainer/ValueContainer/BaseValueLabel
@onready var luck_max_value_label = $LuckContainer/ValueContainer/MaxValueLabel
@onready var luck_growth_value_label = $LuckContainer/ValueContainer/GrowthValueLabel

@onready var defense_base_value_label = $DefenseContainer/ValueContainer/BaseValueLabel
@onready var defense_max_value_label = $DefenseContainer/ValueContainer/MaxValueLabel
@onready var defense_growth_value_label = $DefenseContainer/ValueContainer/GrowthValueLabel

@onready var resistance_base_value_label = $ResistanceContainer/ValueContainer/BaseValueLabel
@onready var resistance_max_value_label = $ResistanceContainer/ValueContainer/MaxValueLabel
@onready var resistance_growth_value_label = $ResistanceContainer/ValueContainer/GrowthValueLabel

var unit_type : UnitTypeDefinition

# Called when the node enters the scene tree for the first time.
func _ready():
	if unit_type:
		update_by_unit_type()



func set_value_label(label, value):
	label.text = str(value)

func set_value_label_percent(label,value):
	label.text = str(value) + "%"

func update_by_unit_type():
	set_value_label(health_base_value_label,unit_type.base_stats.hp)
	set_value_label(health_max_value_label,unit_type.maxuimum_stats.hp)
	set_value_label_percent(health_growth_value_label,unit_type.growth_stats.hp)
	
	set_value_label(strength_base_value_label,unit_type.base_stats.strength)
	set_value_label(strength_max_value_label,unit_type.maxuimum_stats.strength)
	set_value_label_percent(strength_growth_value_label,unit_type.growth_stats.strength)
	
	set_value_label(magic_base_value_label,unit_type.base_stats.magic)
	set_value_label(magic_max_value_label,unit_type.maxuimum_stats.magic)
	set_value_label_percent(magic_growth_value_label,unit_type.growth_stats.magic)
	
	set_value_label(skill_base_value_label,unit_type.base_stats.skill)
	set_value_label(skill_max_value_label,unit_type.maxuimum_stats.skill)
	set_value_label_percent(skill_growth_value_label,unit_type.growth_stats.skill)
	
	set_value_label(speed_base_value_label,unit_type.base_stats.speed)
	set_value_label(speed_max_value_label,unit_type.maxuimum_stats.speed)
	set_value_label_percent(speed_growth_value_label,unit_type.growth_stats.speed)
	
	set_value_label(luck_base_value_label,unit_type.base_stats.luck)
	set_value_label(luck_max_value_label,unit_type.maxuimum_stats.luck)
	set_value_label_percent(luck_growth_value_label,unit_type.growth_stats.luck)
	
	set_value_label(defense_base_value_label,unit_type.base_stats.defense)
	set_value_label(defense_max_value_label,unit_type.maxuimum_stats.defense)
	set_value_label_percent(defense_growth_value_label,unit_type.growth_stats.defense)
	
	set_value_label(resistance_base_value_label,unit_type.base_stats.resistance)
	set_value_label(resistance_max_value_label,unit_type.maxuimum_stats.resistance)
	set_value_label_percent(resistance_growth_value_label,unit_type.growth_stats.resistance)
