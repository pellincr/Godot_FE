extends VBoxContainer

@onready var objective_label: Label = $ObjectivePanel/ObjectiveContainer/ObjectiveLabel
@onready var turn_count_label: Label = $ObjectivePanel/ObjectiveContainer/HBoxContainer/MarginContainer/TurnInfoContainer/TurnCountContainer/TurnCountLabel
@onready var turn_par_label: Label = $ObjectivePanel/ObjectiveContainer/HBoxContainer/MarginContainer/TurnInfoContainer/TurnParContainer/TurnParLabel


func set_objective_label(text):
	objective_label.text = text

func set_turn_count_label(text):
	turn_count_label.text = text

func set_turn_par_label(text):
	turn_par_label.text = text
