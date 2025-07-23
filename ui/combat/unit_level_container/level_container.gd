extends VBoxContainer

@onready var level_label = $UpperContainer/LevelLabel
@onready var xp_label = $UpperContainer/XPLabel
@onready var level_progress_bar = $LevelProgressBar

func set_level_label(level):
	level_label.text = "LV " + str(level)

func set_xp_label(xp):
	xp_label.text = "XP " + str(xp)

func set_level_progress_value(xp_amt):
	level_progress_bar.value = xp_amt
