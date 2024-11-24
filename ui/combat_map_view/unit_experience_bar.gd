extends Control

var reference_unit : Unit

var initial_value
var desired_value
var overflow_value = 0
var tween = null

signal finished()

func _ready():
	self.desired_value = $Panel/ProgressBar.value
	self.initial_value = $Panel/ProgressBar.value

func _process(delta: float) -> void:
	if tween:
		check_level_up()
		update_xp_label($Panel/ProgressBar.value)

func set_reference_unit(u:Unit):
	self.reference_unit = u
	set_value()
	update_xp_label(u.experience)

func set_value():
	$Panel/ProgressBar.value = reference_unit.experience
	self.initial_value = $Panel/ProgressBar.value

func activate_tween():
	tween = get_tree().create_tween()
	tween.tween_property($Panel/ProgressBar, "value", desired_value, generate_bar_time()).set_delay(.2)
	tween.connect("finished", tween_done)

func update_xp_label(f: float):
	$Panel/xpValue.text = str(int(f)) 

func update_xp(input: int) :
	desired_value = input + $Panel/ProgressBar.value
	if desired_value >= 100: 
		overflow_value = desired_value - 100
		desired_value = 100
	activate_tween()
	reference_unit.experience = input + $Panel/ProgressBar.value

func generate_bar_time() -> float:
	return sqrt(desired_value - initial_value)/3


func check_level_up():
	if $Panel/ProgressBar.value == 100:
		print("Unit Leveled up!")
		reference_unit.level_up_generic()
		$Panel/ProgressBar.value == 0
		

func tween_done():
	tween = null
	if overflow_value > 0:
		desired_value = overflow_value
		overflow_value = 0
		activate_tween()
	await get_tree().create_timer(0.5).timeout
	emit_signal("finished")
