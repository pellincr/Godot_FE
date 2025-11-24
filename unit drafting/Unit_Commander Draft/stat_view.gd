extends Control

var unit: Unit = null

@onready var main_container = $MainContainer
@onready var difference_value_container = $MainContainer/DifferenceValueContainer

@onready var move_value_label = $MainContainer/StatValueContainer/ValueContainer/MoveValue
@onready var constitution_value_label = $MainContainer/StatValueContainer/ValueContainer/ConsitutionValue

@onready var health_value_label = $MainContainer/StatValueContainer/ValueContainer2/Health
@onready var strength_value_label = $MainContainer/StatValueContainer/ValueContainer2/Strength
@onready var magic_value_label = $MainContainer/StatValueContainer/ValueContainer2/Magic
@onready var skill_value_label = $MainContainer/StatValueContainer/ValueContainer2/Skill
@onready var speed_value_label = $MainContainer/StatValueContainer/ValueContainer2/Speed
@onready var luck_value_label = $MainContainer/StatValueContainer/ValueContainer2/Luck
@onready var defense_value_label = $MainContainer/StatValueContainer/ValueContainer2/Defense
@onready var resistance_value_label = $MainContainer/StatValueContainer/ValueContainer2/Resistance



@onready var health_difference_label = $MainContainer/DifferenceValueContainer/DifferentialContainer/Health
@onready var strength_difference_label = $MainContainer/DifferenceValueContainer/DifferentialContainer/Strength
@onready var magic_difference_label = $MainContainer/DifferenceValueContainer/DifferentialContainer/Magic
@onready var skill_difference_label = $MainContainer/DifferenceValueContainer/DifferentialContainer/Skill
@onready var speed_difference_label = $MainContainer/DifferenceValueContainer/DifferentialContainer/Speed
@onready var luck_difference_label = $MainContainer/DifferenceValueContainer/DifferentialContainer/Luck
@onready var defense_difference_label = $MainContainer/DifferenceValueContainer/DifferentialContainer/Defense
@onready var resistance_difference_label = $MainContainer/DifferenceValueContainer/DifferentialContainer/Resistance

@onready var overall_stat_header_label = $MainContainer/StatHeaderContainer/OverallStatHeader
@onready var overall_stat_grade_label = $MainContainer/StatValueContainer/OverallStatGradeLabel
@onready var overall_difference_label = $MainContainer/DifferenceValueContainer/Overall

# Called when the node enters the scene tree for the first time.
func _ready():
	if unit != null:
		update_all()
	#hide_difference_value_container()
	#hide_stat_grade()
	#var test = preload("res://unit drafting/Unit_Commander Draft/growths_view.tscn").instantiate()
	#add_child_to_main_container(test)
	#test.commander_visiblity_setting()


func add_child_to_main_container(child):
	main_container.add_child(child)


func hide_difference_value_container():
	difference_value_container.visible = false

func hide_stat_grade():
	overall_stat_header_label.visible = false
	overall_stat_grade_label.visible = false
	overall_difference_label.visible = false
	

func set_move(move):
	move_value_label.text = str(move)

func set_constitution(con):
	constitution_value_label.text = str(con)

func set_health_val(hp_val):
	health_value_label.text = str(hp_val)

func set_strength_val(str_val):
	strength_value_label.text = str(str_val)

func set_magic_val(mgc_val):
	magic_value_label.text = str(mgc_val)

func set_skill_val(skl_val):
	skill_value_label.text = str(skl_val)

func set_speed_val(spd_val):
	speed_value_label.text = str(spd_val)

func set_luck_val(lck_val):
	luck_value_label.text = str(lck_val)

func set_defense_val(def_val):
	defense_value_label.text = str(def_val)

func set_resistance_val(res_val):
	resistance_value_label.text = str(res_val)




func set_health_difference(hp_difference):
	var sign = ""
	if hp_difference > 0:
		sign = "+"
	health_difference_label.text = sign + str(hp_difference)

func set_strength_difference(str_difference):
	var sign = ""
	if str_difference > 0:
		sign = "+"
	strength_difference_label.text = sign + str(str_difference)

func set_magic_difference(mgc_difference):
	var sign = ""
	if mgc_difference > 0:
		sign = "+"
	magic_difference_label.text = sign + str(mgc_difference)

func set_skill_difference(skl_difference):
	var sign = ""
	if skl_difference > 0:
		sign = "+"
	skill_difference_label.text = sign + str(skl_difference)

func set_speed_difference(spd_difference):
	var sign = ""
	if spd_difference > 0:
		sign = "+"
	speed_difference_label.text = sign + str(spd_difference)

func set_luck_difference(lck_difference):
	var sign = ""
	if lck_difference > 0:
		sign = "+"
	luck_difference_label.text = sign + str(lck_difference)

func set_defense_difference(def_difference):
	var sign = ""
	if def_difference > 0:
		sign = "+"
	defense_difference_label.text = sign + str(def_difference)

func set_resistance_difference(res_difference):
	var sign = ""
	if res_difference > 0:
		sign = "+"
	resistance_difference_label.text = sign + str(res_difference)

func set_overall_difference(overall_diff):
	var sign = ""
	if overall_diff > 0:
		sign = "+"
	overall_difference_label.text = sign + str(overall_diff)

func set_overall_stat_grade_level(grade):
	overall_stat_grade_label.text = grade

func set_object_color(object, value):
	if value + unit.level < 2:
		object.modulate = Color.DARK_RED
	elif value + unit.level < 4:
		object.modulate = Color.RED
	elif value + unit.level < 8:
		object.modulate = Color.YELLOW
	else:
		object.modulate = Color.GREEN

func update_all():
	set_move(unit.stats.movement)
	set_constitution(unit.stats.constitution)
	
	set_health_val(unit.stats.hp)
	#set_object_color(health_value_label)
	set_strength_val(unit.stats.strength)
	set_object_color(strength_value_label,unit.stats.strength)
	set_magic_val(unit.stats.magic)
	set_object_color(magic_value_label,unit.stats.magic)
	set_skill_val(unit.stats.skill)
	set_object_color(skill_value_label,unit.stats.skill)
	set_speed_val(unit.stats.speed)
	set_object_color(speed_value_label,unit.stats.speed)
	set_luck_val(unit.stats.luck)
	set_object_color(luck_value_label,unit.stats.luck)
	set_defense_val(unit.stats.defense)
	set_object_color(defense_value_label,unit.stats.defense)
	set_resistance_val(unit.stats.resistance)
	set_object_color(resistance_value_label,unit.stats.resistance)
	
	#THIS NEEDS TO BE UPDATED WHEN THE RANDOMIZATION OF STATS IS IMPLEMENTED
	var hp_difference = unit.unit_character.stats.hp
	var strength_difference = unit.unit_character.stats.strength
	var magic_difference = unit.unit_character.stats.magic
	var skill_difference = unit.unit_character.stats.skill
	var speed_difference = unit.unit_character.stats.speed
	var luck_difference = unit.unit_character.stats.luck
	var defense_difference = unit.unit_character.stats.defense 
	var resistance_difference = unit.unit_character.stats.resistance
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
	var stat_grade = get_stat_grade(difference_total)
	set_overall_stat_grade_level(stat_grade)



func get_stat_grade(total): 
	if total <= -18:
		return "F-"
	elif total <= -16:
		return "F"
	elif total <= -14:
		return "F+"
	elif total <= -11:
		return "D+"
	elif total <= -8:
		return "D"
	elif total <= -5:
		return "D+"
	elif total <= -3:
		return "C-"
	elif total <= 0:
		return "C"
	elif total <= 2:
		return "C+"
	elif total <= 5:
		return "B-"
	elif total <= 8:
		return "B"
	elif total <= 11:
		return "B+"
	elif total <= 14:
		return "A-"
	elif total <= 17:
		return "A"
	elif total <= 20:
		return "A+"
	else:
		return "ERROR"
