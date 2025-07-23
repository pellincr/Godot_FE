extends Control

var unit: Unit = null


@onready var stat_header_container = $HBoxContainer/StatHeaderContainer
@onready var overall_growth_grade_label = $HBoxContainer/GrowthsValueContainer/OverallGrowthGradeLabel
@onready var difference_value_container = $HBoxContainer/DifferenceValueContainer
@onready var overall_difference_total_label = $HBoxContainer/DifferenceValueContainer/Overall

@onready var move_value_label = $HBoxContainer/GrowthsValueContainer/ValueContainer/MoveValue
@onready var constitution_value_label = $HBoxContainer/GrowthsValueContainer/ValueContainer/ConstitutionValue

@onready var health_growth_label = $HBoxContainer/GrowthsValueContainer/VBoxContainer/Health
@onready var strength_growth_label = $HBoxContainer/GrowthsValueContainer/VBoxContainer/Strength
@onready var magic_growth_label = $HBoxContainer/GrowthsValueContainer/VBoxContainer/Magic
@onready var skill_growth_label = $HBoxContainer/GrowthsValueContainer/VBoxContainer/Skill
@onready var speed_growth_label = $HBoxContainer/GrowthsValueContainer/VBoxContainer/Speed
@onready var luck_growth_label = $HBoxContainer/GrowthsValueContainer/VBoxContainer/Luck
@onready var defense_growth_label = $HBoxContainer/GrowthsValueContainer/VBoxContainer/Defense
@onready var resistance_growth_label = $HBoxContainer/GrowthsValueContainer/VBoxContainer/Resistance

@onready var health_difference_label = $HBoxContainer/DifferenceValueContainer/DifferentialContainer/Health
@onready var strength_difference_label = $HBoxContainer/DifferenceValueContainer/DifferentialContainer/Strength
@onready var magic_difference_label = $HBoxContainer/DifferenceValueContainer/DifferentialContainer/Magic
@onready var skill_difference_label = $HBoxContainer/DifferenceValueContainer/DifferentialContainer/Skill
@onready var speed_difference_label = $HBoxContainer/DifferenceValueContainer/DifferentialContainer/Speed
@onready var luck_difference_label = $HBoxContainer/DifferenceValueContainer/DifferentialContainer/Luck
@onready var defense_difference_label = $HBoxContainer/DifferenceValueContainer/DifferentialContainer/Defense
@onready var resistance_difference_label = $HBoxContainer/DifferenceValueContainer/DifferentialContainer/Resistance




func _ready():
	if unit != null:
		update_all()



func commander_visiblity_setting():
	hide_stat_header_container()
	hide_overall_growth_grade()
	hide_difference_value_container()
	set_move("")
	set_constitution("")

func hide_stat_header_container():
	stat_header_container.visible = false

func hide_overall_growth_grade():
	overall_growth_grade_label.visible = false

func hide_difference_value_container():
	difference_value_container.visible = false

func set_move(move):
	move_value_label.text = str(move)

func set_constitution(con):
	constitution_value_label.text = str(con)


func set_health_growth(hp_growth):
	var sign = ""
	if hp_growth > 0:
		sign = "+"
	health_growth_label.text = sign + str(hp_growth) + "%"

func set_strength_growth(str_growth):
	var sign = ""
	if str_growth > 0:
		sign = "+"
	strength_growth_label.text = sign + str(str_growth) + "%"

func set_magic_growth(mgc_growth):
	var sign = ""
	if mgc_growth > 0:
		sign = "+"
	magic_growth_label.text = sign + str(mgc_growth) + "%"

func set_skill_growth(skill_growth):
	var sign = ""
	if skill_growth > 0:
		sign = "+"
	skill_growth_label.text = sign + str(skill_growth) + "%"

func set_speed_growth(spd_growth):
	var sign = ""
	if spd_growth > 0:
		sign = "+"
	speed_growth_label.text = sign + str(spd_growth) + "%"

func set_luck_growth(lck_growth):
	var sign = ""
	if lck_growth > 0:
		sign = "+"
	luck_growth_label.text = sign + str(lck_growth) + "%"

func set_defense_growth(def_growth):
	var sign = ""
	if def_growth > 0:
		sign = "+"
	defense_growth_label.text = sign + str(def_growth) + "%"

func set_resistance_growth(res_growth):
	var sign = ""
	if res_growth > 0:
		sign = "+"
	resistance_growth_label.text = sign + str(res_growth) + "%"

func set_health_difference(hp_difference):
	var sign = ""
	if hp_difference > 0:
		sign = "+"
	health_difference_label.text = sign + str(hp_difference) + "%"

func set_strength_difference(str_difference):
	var sign = ""
	if str_difference > 0:
		sign = "+"
	strength_difference_label.text = sign + str(str_difference) + "%"

func set_magic_difference(mgc_difference):
	var sign = ""
	if mgc_difference > 0:
		sign = "+"
	magic_difference_label.text = sign + str(mgc_difference) + "%"

func set_skill_difference(skill_difference):
	var sign = ""
	if skill_difference > 0:
		sign = "+"
	skill_difference_label.text = sign + str(skill_difference) + "%"

func set_speed_difference(spd_difference):
	var sign = ""
	if spd_difference > 0:
		sign = "+"
	speed_difference_label.text = sign + str(spd_difference) + "%"

func set_luck_difference(lck_difference):
	var sign = ""
	if lck_difference > 0:
		sign = "+"
	luck_difference_label.text = sign + str(lck_difference) + "%"

func set_defense_difference(def_difference):
	var sign = ""
	if def_difference > 0:
		sign = "+"
	defense_difference_label.text = sign + str(def_difference) +"%"

func set_resistance_difference(res_difference):
	var sign = ""
	if res_difference > 0:
		sign = "+"
	resistance_difference_label.text = sign + str(res_difference) + "%"


func set_overall_difference(overall_diff):
	var sign = ""
	if overall_diff > 0:
		sign = "+"
	overall_difference_total_label.text = sign + str(overall_diff) + "%"

func set_overall_growth_grade_level(grade):
	overall_growth_grade_label.text = grade




func update_all():
	set_move(unit.stats.movement)
	set_constitution(unit.stats.constitution)
	
	set_health_growth(unit.growths.hp)
	set_strength_growth(unit.growths.strength)
	set_magic_growth(unit.growths.magic)
	set_skill_growth(unit.growths.skill)
	set_speed_growth(unit.growths.speed)
	set_luck_growth(unit.growths.luck)
	set_defense_growth(unit.growths.defense)
	set_resistance_growth(unit.growths.resistance)
	
	#THIS NEEDS TO BE UPDATED WHEN THE RANDOMIZATION OF STATS IS IMPLEMENTED
	var hp_difference = unit.unit_character.growths.hp
	var strength_difference = unit.unit_character.growths.strength
	var magic_difference = unit.unit_character.growths.magic
	var skill_difference = unit.unit_character.growths.skill
	var speed_difference = unit.unit_character.growths.speed
	var luck_difference = unit.unit_character.growths.luck
	var defense_difference = unit.unit_character.growths.defense
	var resistance_difference = unit.unit_character.growths.resistance
	var difference_total = hp_difference + strength_difference + magic_difference + skill_difference + speed_difference + luck_difference + defense_difference + resistance_difference
	set_health_difference(hp_difference)
	set_strength_difference(strength_difference)
	set_magic_difference(magic_difference)
	set_skill_difference(skill_difference)
	set_speed_difference(speed_difference)
	set_luck_difference(luck_difference)
	set_defense_difference(defense_difference)
	set_resistance_difference(resistance_difference)
	set_overall_difference(difference_total)
	var growth_grade = get_growth_grade(difference_total)
	set_overall_growth_grade_level(growth_grade)


func get_growth_grade(total): 
	if total <= -157:
		return "F-"
	elif total <= -133:
		return "F"
	elif total <= -109:
		return "F+"
	elif total <= -85:
		return "D+"
	elif total <= -61:
		return "D"
	elif total <= -37:
		return "D+"
	elif total <= -13:
		return "C-"
	elif total <= 12:
		return "C"
	elif total <= 36:
		return "C+"
	elif total <= 60:
		return "B-"
	elif total <= 84:
		return "B"
	elif total <= 108:
		return "B+"
	elif total <= 132:
		return "A-"
	elif total <= 156:
		return "A"
	elif total <= 180:
		return "A+"
	else:
		return "ERROR"
