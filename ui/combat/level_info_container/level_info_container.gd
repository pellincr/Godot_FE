extends VBoxContainer

@onready var objective_label: Label = $ObjectivePanel/ObjectiveContainer/ObjectiveLabel
@onready var turn_count_label: Label = $ObjectivePanel/ObjectiveContainer/HBoxContainer/MarginContainer/TurnCountContainer/TurnCountLabel
@onready var par_turn_value_label: Label = $ObjectivePanel/ObjectiveContainer/HBoxContainer/MarginContainer/TurnCountContainer/ParTurnValueLabel

func set_objective_label(text):
	objective_label.text = text

func set_turn_count_label(text):
	turn_count_label.text = text

func set_par_turn_value_label(par_turns):
	par_turn_value_label.text = "/ " + str(par_turns)


func set_turn_count_value_color(current_turn, par_turns):
	if current_turn <= par_turns * .8:
		turn_count_label.modulate = Color.GREEN
	elif current_turn <= par_turns:
		turn_count_label.modulate = Color.YELLOW
	elif current_turn <= par_turns * 1.2:
		turn_count_label.modulate = Color.RED
	else:
		turn_count_label.modulate = Color.DARK_RED
