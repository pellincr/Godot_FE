extends Control

var initial_value : int
var desired_value : int
var displayed_value : int
var overflow_value = 0
var tween = null

signal finished()

func _ready():
	self.desired_value = $Panel/ProgressBar.value
	self.initial_value = $Panel/ProgressBar.value

func _process(delta: float) -> void:
	if tween:
		update_xp_label($Panel/ProgressBar.value)

func set_value(amount: int):
	self.displayed_value = amount
	$Panel/ProgressBar.value = self.displayed_value

func set_initial_value(experience_amount: int):
	self.initial_value = experience_amount
	set_value(self.initial_value)
	update_xp_label(self.initial_value)

func activate_tween():
	tween = get_tree().create_tween()
	tween.tween_property($Panel/ProgressBar, "value", desired_value, generate_bar_time()).set_delay(.2)
	tween.connect("finished", tween_done)

func update_xp_label(f: float):
	$Panel/xpValue.text = str(int(f)) 

#func update_xp(input: int) :
	#desired_value = input + $Panel/ProgressBar.value
	#activate_tween()

func set_desired_value(value :int):
	self.desired_value = value

func generate_bar_time() -> float:
	return sqrt(desired_value - initial_value)/6


func tween_done():
	await get_tree().create_timer(0.3).timeout
	emit_signal("finished")
