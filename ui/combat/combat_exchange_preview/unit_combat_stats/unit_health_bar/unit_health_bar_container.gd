extends VBoxContainer

@onready var current_hp = $HBoxContainer/HBoxContainer/CurrentHP
@onready var max_hp = $HBoxContainer/HBoxContainer/MaxHP
@onready var main_health_bar = $MainHealthBar
@onready var damage_bar = $MainHealthBar/DamageBar
@onready var expected_hp_label = $ExpectedHPLabel

var unit : Unit

func _ready():
	if unit:
		update_by_unit()

func set_label_value(label:Label,value:int):
	label.text = str(value)

func set_progress_bar_value(progress_bar : ProgressBar, value : int):
	progress_bar.value = value

func update_by_unit():
	set_label_value(current_hp,unit.hp)
	set_label_value(max_hp,unit.stats.hp)
	set_label_value(expected_hp_label,unit.hp) #THIS WILL NEED TO HAVE A CALCULATION DONE
	set_progress_bar_value(main_health_bar,unit.hp)#THIS WILL NEED TO HAVE A CALCULATION DON
	set_progress_bar_value(damage_bar,unit.hp)
