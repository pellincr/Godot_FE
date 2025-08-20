extends HBoxContainer


@onready var cycle_container = $CycleContainer
@onready var cycle_views_left_container = $CycleViewLeftContainer
@onready var cycle_view_right_container = $CycleViewRight
@onready var select_container = $SelectContainer


func set_cycle_visibility(visibility):
	if visibility:
		cycle_container.visible = true
	else:
		cycle_container.visible = false

func set_cycle_view_left_visibility(visibility):
	if visibility:
		cycle_views_left_container.visible = true
	else:
		cycle_views_left_container.visible = false

func set_cycle_view_right_visibility(visibility):
	if visibility:
		cycle_view_right_container.visible = true
	else:
		cycle_view_right_container.visible = false

func set_select_visibility(visibility):
	if visibility:
		select_container.visible = true
	else:
		select_container.visible = false
