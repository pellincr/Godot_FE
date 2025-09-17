extends VBoxContainer

const UNIT_ACTION_BUTTON = preload("res://ui/combat/unit_action_container/unit_action_button/unit_action_button.tscn")

@export var controller: CController

var button_array : Array[Button] = []
func populate(available_actions: Array[String], controller_node: CController):
	button_array.clear()
	var focused : bool = false
	self.controller = controller_node
	for action in available_actions:
		var btn = UNIT_ACTION_BUTTON.instantiate()
		button_array.append(btn)
		btn.set_button(action)
		btn.pressed.connect(func():
				controller.unit_action_selection_handler(action))
		self.add_child(btn)
		if focused == false:
			btn.grab_focus.call_deferred()
			focused = true
	configure_focus_wrap()
	#add a cancel button
	#var btn = UNIT_ACTION_BUTTON.instantiate()
	#btn.set_button("Cancel")
	#btn.pressed.connect(func():
	#		controller.unit_action_selection_handler("Cancel"))
	#self.add_child(btn)
	#if focused == false:
	#	btn.grab_focus.call_deferred()
	#	focused = true

func configure_focus_wrap():
	button_array.front().focus_neighbor_top = button_array.front().get_path_to(button_array.back())
	button_array.back().focus_neighbor_bottom = button_array.back().get_path_to(button_array.front())
