extends HBoxContainer

signal header_swapped()

@onready var left_header = $LeftHeader/LeftHeader
@onready var right_header = $RightHeader/RightHeader



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left_bumper") or Input.is_action_just_pressed("right_bumper"):
		swap_headers()


func swap_headers():
	var temp = left_header.text
	left_header.text = right_header.text
	right_header.text = temp
	header_swapped.emit()
