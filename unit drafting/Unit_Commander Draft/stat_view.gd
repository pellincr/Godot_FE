extends Control

@onready var unit: Unit = null

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
	health_difference_label.text = str(hp_difference)

func set_strength_difference(str_difference):
	strength_difference_label.text = str(str_difference)

func set_magic_difference(mgc_difference):
	magic_difference_label.text = str(mgc_difference)

func set_skill_difference(skl_difference):
	skill_difference_label.text = str(skl_difference)

func set_speed_difference(spd_difference):
	speed_difference_label.text = str(spd_difference)

func set_luck_difference(lck_difference):
	luck_difference_label.text = str(lck_difference)

func set_defense_difference(def_difference):
	defense_difference_label.text = str(def_difference)

func set_resistance_difference(res_difference):
	resistance_difference_label.text = str(res_difference)

func update_all():
	set_move(unit.movement)
	set_constitution(unit.constitution)
	
	set_health_val(unit.hp)
	set_strength_val(unit.strength)
	set_magic_val(unit.magic)
	set_skill_val(unit.skill)
	set_speed_val(unit.speed)
	set_luck_val(unit.luck)
	set_defense_val(unit.defense)
	set_resistance_val(unit.magic_defense)
	
	#THIS NEEDS TO BE UPDATED WHEN THE RANDOMIZATION OF STATS IS IMPLEMENTED
	set_health_difference(unit.hp_growth)
	set_strength_difference(unit.strength_growth)
	set_magic_difference(unit.magic_growth)
	set_skill_difference(unit.skill_growth)
	set_speed_difference(unit.speed_growth)
	set_luck_difference(unit.luck_growth)
	set_defense_difference(unit.defense_growth)
	set_resistance_difference(unit.magic_defense_growth)
