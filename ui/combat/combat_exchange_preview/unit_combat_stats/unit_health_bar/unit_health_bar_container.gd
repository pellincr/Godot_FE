extends VBoxContainer

@onready var current_hp = $HBoxContainer/HBoxContainer/CurrentHP
@onready var max_hp = $HBoxContainer/HBoxContainer/MaxHP
@onready var main_health_bar = $MainHealthBar
@onready var damage_bar = $MainHealthBar/DamageBar
@onready var expected_hp_label = $ExpectedHPLabel

var max_health: int = 0
var current_health: int = 0
var predicted_health: int = 0

func set_all(m_hp: int, c_hp: int, p_hp: int):
	self.max_health = m_hp
	self.current_health = c_hp
	self.predicted_health = p_hp
	update_display()

func set_label_value(label:Label,value:int):
	label.text = str(value)

func set_progress_bar_value(progress_bar : ProgressBar, value : int):
	progress_bar.value = value

func set_progress_bar_max_value(progress_bar : ProgressBar, max_value : int):
	progress_bar.max_value = max_value

func update_display():
	set_label_value(current_hp,current_health)
	set_label_value(max_hp,max_health)
	set_label_value(expected_hp_label,predicted_health) #THIS WILL NEED TO HAVE A CALCULATION DONE
	set_progress_bar_max_value(main_health_bar, max_health)
	set_progress_bar_max_value(damage_bar, max_health)
	set_progress_bar_value(main_health_bar,predicted_health)#THIS WILL NEED TO HAVE A CALCULATION DON
	set_progress_bar_value(damage_bar,current_health)
	
