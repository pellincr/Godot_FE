extends Control




@onready var stat_header_container = $HBoxContainer/StatHeaderContainer
@onready var overall_growth_grade = $HBoxContainer/GrowthsValueContainer/OverallGrowthGradeLabel
@onready var difference_value_container = $HBoxContainer/DifferenceValueContainer

@onready var move_value_label = $HBoxContainer/GrowthsValueContainer/ValueContainer/MoveValue
@onready var consitution_value_label = $HBoxContainer/GrowthsValueContainer/ValueContainer/ConsitutionValue

func commander_visiblity_setting():
	hide_stat_header_container()
	hide_overall_growth_grade()
	hide_difference_value_container()
	set_move("")
	set_consitution("")

func hide_stat_header_container():
	stat_header_container.visible = false

func hide_overall_growth_grade():
	overall_growth_grade.visible = false

func hide_difference_value_container():
	difference_value_container.visible = false

func set_move(move):
	move_value_label.text = str(move)
	
func set_consitution(con):
	consitution_value_label.text = str(con)
