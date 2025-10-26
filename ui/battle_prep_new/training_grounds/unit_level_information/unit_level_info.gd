extends VBoxContainer

@onready var unit_type_icon: TextureRect = $UpperPanelContainer/MarginContainer/HBoxContainer/UnitTypeIcon
@onready var unit_type_label: Label = $UpperPanelContainer/MarginContainer/HBoxContainer/UnitBasicInfoContainer/UnitTypeLabel

@onready var level_value_label: Label = $UpperPanelContainer/MarginContainer/HBoxContainer/UnitBasicInfoContainer/UpperContainer/LevelContainer/LevelValueLabel
@onready var experience_value_label: Label = $UpperPanelContainer/MarginContainer/HBoxContainer/UnitBasicInfoContainer/UpperContainer/ExperienceContainer/ExperienceValueLabel
@onready var hp_value_label: Label = $UpperPanelContainer/MarginContainer/HBoxContainer/UnitBasicInfoContainer/BottomContainer/HPContainer/HPValueLabel
@onready var strength_value_label: Label = $LowerPanelContainer/MarginContainer/GridContainer/StrengthContainer/StrengthValueLabel
@onready var magic_value_label: Label = $LowerPanelContainer/MarginContainer/GridContainer/MagicContainer/MagicValueLabel
@onready var skill_value_label: Label = $LowerPanelContainer/MarginContainer/GridContainer/SkillContainer/SkillValueLabel
@onready var speed_value_label: Label = $LowerPanelContainer/MarginContainer/GridContainer/SpeedContainer/SpeedValueLabel
@onready var luck_value_label: Label = $LowerPanelContainer/MarginContainer/GridContainer/LuckContainer/LuckValueLabel
@onready var defense_value_label: Label = $LowerPanelContainer/MarginContainer/GridContainer/DefenseContainer/DefenseValueLabel
@onready var resistance_value_label: Label = $LowerPanelContainer/MarginContainer/GridContainer/ResistanceContainer/ResistanceValueLabel


var unit:Unit

func _ready() -> void:
	if unit:
		update_by_unit()


func update_unit_type_icon(texture):
	unit_type_icon.texture = texture

func update_unit_type_label(unit_type):
	unit_type_label.text = unit_type

func update_hp_value_label(current_hp, max_hp):
	hp_value_label.text = str(current_hp) + "/" + str(max_hp)

func update_value_label(value_label, value):
	value_label.text = str(value)


func update_by_unit():
	update_unit_type_icon(unit.icon)
	var unit_type : UnitTypeDefinition = UnitTypeDatabase.get_definition(unit.unit_type_key)
	update_unit_type_label(unit_type.unit_type_name)
	update_hp_value_label(unit.hp,unit.stats.hp)
	update_value_label(level_value_label,unit.level)
	update_value_label(experience_value_label,unit.experience)
	update_value_label(strength_value_label,unit.stats.strength)
	update_value_label(magic_value_label,unit.stats.magic)
	update_value_label(skill_value_label,unit.stats.skill)
	update_value_label(speed_value_label,unit.stats.speed)
	update_value_label(luck_value_label,unit.stats.luck)
	update_value_label(defense_value_label,unit.stats.defense)
	update_value_label(resistance_value_label,unit.stats.resistance)
