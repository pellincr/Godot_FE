extends Control

var initial_value : int
var desired_value : int
var displayed_value : int
var overflow_value = 0
var tween = null
@export var progressBar : ProgressBar
@export var value_label : Label

signal finished()

func _ready():
	self.desired_value = progressBar.value
	self.initial_value = progressBar.value

func _process(delta: float) -> void:
	if tween:
		update_label(progressBar.value)

func set_value(amount: int):
	self.displayed_value = amount
	progressBar.value = self.displayed_value

func set_max_value(amount: int):
	progressBar.max_value = amount
	
func set_initial_value(init_amount: int):
	self.initial_value = init_amount
	set_value(self.initial_value)
	update_label(self.initial_value)

func activate_tween():
	tween = get_tree().create_tween()
	tween.tween_property(progressBar, "value", desired_value, generate_bar_time()).set_delay(.2)
	tween.connect("finished", tween_done)

func update_label(f: float):
	value_label.text = str(int(f)) 

func set_desired_value(value :int):
	self.desired_value = value

func generate_bar_time() -> float:
	return sqrt(abs(abs(desired_value) - abs(initial_value)))/6

func tween_done():
	self.progressBar.value = desired_value
	await get_tree().create_timer(0.3).timeout
	emit_signal("finished")
