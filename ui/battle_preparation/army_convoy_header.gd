extends VBoxContainer

signal header_swapped()

@onready var upper_container = $UpperContainer

@onready var units_left_value_label = $UpperContainer/HBoxContainer/UnitsLeftValueLabel

@onready var left_header_label = $LowerContainer/PanelContainer/HBoxContainer/LeftHeaderLabel
@onready var right_header_label = $LowerContainer/PanelContainer2/HBoxContainer/RightHeaderLabel




func _process(delta):
	if Input.is_action_just_pressed("left_bumber") or Input.is_action_just_pressed("right_bumper"):
		swap_header_labels()
		swap_upper_container_visibiltiy()
		header_swapped.emit()


func set_units_left_value(left, total):
	units_left_value_label.text = str(left) + "/" + total


func set_left_header_label(text):
	left_header_label.text = text

func set_right_header_label(text):
	right_header_label.text = text


func swap_header_labels():
	var temp = left_header_label.text
	set_left_header_label(right_header_label.text)
	set_right_header_label(temp)

func swap_upper_container_visibiltiy():
	upper_container.visible = !upper_container.visible
