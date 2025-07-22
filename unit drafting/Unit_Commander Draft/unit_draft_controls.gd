extends HBoxContainer


@onready var cycle_container = $CycleContainer
@onready var view_container = $ViewsContainer
@onready var details_container = $DetailsContainer
@onready var select_container = $SelectContainer


func set_cycle_visibility(visibility):
	if visibility:
		cycle_container.visible = true
	else:
		cycle_container.visible = false

func set_view_visibility(visibility):
	if visibility:
		view_container.visible = true
	else:
		view_container.visible = false

func set_details_visibility(visibility):
	if visibility:
		details_container.visible = true
	else:
		details_container.visible = false

func set_select_visibility(visibility):
	if visibility:
		select_container.visible = true
	else:
		select_container.visible = false
