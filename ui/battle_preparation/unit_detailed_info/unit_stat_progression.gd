extends VBoxContainer

#Strength
@onready var strength_value_label = $StrengthContainer/HBoxContainer/StrengthValueLabel
@onready var strength_growth_label = $StrengthContainer/HBoxContainer/StrengthGrowthLabel
@onready var strength_progress = $StrengthContainer/StrengthProgress
#Magic
@onready var magic_value_label = $MagicContainer/HBoxContainer/MagicValueLabel
@onready var magic_growth_label = $MagicContainer/HBoxContainer/MagicGrowthLabel
@onready var magic_progress = $MagicContainer/MagicProgress
#Skill
@onready var skill_value_label = $SkillContainer/HBoxContainer/SkillValueLabel
@onready var skill_growth_label = $SkillContainer/HBoxContainer/SkillGrowthLabel
@onready var skill_progress = $SkillContainer/SkillProgress
#Speed
@onready var speed_value_label = $SpeedContainer/HBoxContainer/SpeedValueLabel
@onready var speed_growth_label = $SpeedContainer/HBoxContainer/SpeedGrowthLabel
@onready var speed_progress = $SpeedContainer/SpeedProgress
#Luck
@onready var luck_value_label = $LuckContainer/HBoxContainer/LuckValueLabel
@onready var luck_growth_label = $LuckContainer/HBoxContainer/LuckGrowthLabel
@onready var luck_progress = $LuckContainer/LuckProgress
#Defense
@onready var defense_value_label = $DefenseContainer/HBoxContainer/DefenseValueLabel
@onready var defense_growth_label = $DefenseContainer/HBoxContainer/DefenseGrowthLabel
@onready var defense_progress = $DefenseContainer/DefenseProgress
#Resistance
@onready var resistance_value_label = $ResistanceContainer/HBoxContainer/ResistanceValueLabel
@onready var resistance_growth_label = $ResistanceContainer/HBoxContainer/ResistanceGrowthLabel
@onready var resistance_progress = $ResistanceContainer/ResistanceProgress
#Move
@onready var move_value_label = $MoveContainer/MoveValueLabel
#Constitution
@onready var constituiton_value_label = $ConstitutionContainer/ConstitutionValueLabel


var unit : Unit


# Called when the node enters the scene tree for the first time.
func _ready():
	if unit != null:
		update_by_unit()


func set_label_with_number(value_label : Label, val, percent = false):
	if !percent:
		value_label.text = str(val)
	else:
		value_label.text = str(val) + "%"

func set_progress_bar(progress_bar : ProgressBar, current_value, maximum_value):
	progress_bar.max_value = maximum_value
	progress_bar.value = current_value


func update_by_unit():
	var unit_type : UnitTypeDefinition
	if UnitTypeDatabase.unit_types.keys().has(unit.unit_type_key):
		unit_type = UnitTypeDatabase.unit_types.get(unit.unit_type_key)
	else:
		unit_type = CommanderDatabase.commander_types.get(unit.unit_type_key)
	
	set_label_with_number(strength_value_label,unit.stats.strength)
	set_label_with_number(strength_growth_label,unit.growths.strength, true)
	set_progress_bar(strength_progress,unit.stats.strength, unit_type.maxuimum_stats.strength)
	
	set_label_with_number(magic_value_label,unit.stats.magic)
	set_label_with_number(magic_growth_label,unit.growths.magic, true)
	set_progress_bar(magic_progress,unit.stats.magic, unit_type.maxuimum_stats.magic)
	
	set_label_with_number(skill_value_label,unit.stats.skill)
	set_label_with_number(skill_growth_label,unit.growths.skill, true)
	set_progress_bar(skill_progress,unit.stats.skill, unit_type.maxuimum_stats.skill)
	
	set_label_with_number(speed_value_label,unit.stats.speed)
	set_label_with_number(speed_growth_label,unit.growths.speed, true)
	set_progress_bar(speed_progress,unit.stats.speed, unit_type.maxuimum_stats.speed)
	
	set_label_with_number(luck_value_label,unit.stats.luck)
	set_label_with_number(luck_growth_label,unit.growths.luck, true)
	set_progress_bar(luck_progress,unit.stats.luck, unit_type.maxuimum_stats.luck)
	
	set_label_with_number(defense_value_label,unit.stats.defense)
	set_label_with_number(defense_growth_label,unit.growths.defense, true)
	set_progress_bar(defense_progress,unit.stats.defense, unit_type.maxuimum_stats.defense)
	
	set_label_with_number(resistance_value_label,unit.stats.resistance)
	set_label_with_number(resistance_growth_label,unit.growths.resistance, true)
	set_progress_bar(resistance_progress,unit.stats.resistance, unit_type.maxuimum_stats.resistance)
	
	set_label_with_number(move_value_label,unit.stats.movement)
	
	set_label_with_number(constituiton_value_label,unit.stats.constitution)
