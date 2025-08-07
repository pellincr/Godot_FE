extends HBoxContainer


@onready var move_value_label = $Panel/MarginContainer/MainContainer/MoveConContainer/MoveContainer/Value
@onready var constitution_value_label = $Panel/MarginContainer/MainContainer/MoveConContainer/ConstitutionContainer/Value

@onready var unit_type_full_stat_container = $Panel/MarginContainer/MainContainer/UnitTypeFullStatContainer

@onready var unit_icon = $Panel/UnitIcon

var unit_type : UnitTypeDefinition

# Called when the node enters the scene tree for the first time.
func _ready():
	if unit_type:
		update_by_unit_type()


func set_value_label(label,value):
	label.text = str(value)

func set_unit_icon(texture):
	unit_icon.texture = texture

func update_by_unit_type():
	set_value_label(move_value_label,unit_type.base_stats.movement)
	set_value_label(constitution_value_label,unit_type.base_stats.constitution)
	set_unit_icon(unit_type.icon)
	unit_type_full_stat_container.unit_type = unit_type
	unit_type_full_stat_container.update_by_unit_type()
