extends VBoxContainer

const UNIT_ACTION_BUTTON = preload("res://ui/combat/unit_action_container/unit_action_button/unit_action_button.tscn")

@export var controller: CController

func populate(available_actions: Array[String], controller_node: CController):
	var focused : bool = false
	self.controller = controller_node
	for action in available_actions:
		var btn = UNIT_ACTION_BUTTON.instantiate()
		btn.set_button(action)
		btn.pressed.connect(func():
				controller.unit_action_selection_handler(action))
		self.add_child(btn)
		if focused == false:
			btn.grab_focus.call_deferred()
			focused = true
	#add a cancel button
	#var btn = UNIT_ACTION_BUTTON.instantiate()
	#btn.set_button("Cancel")
	#btn.pressed.connect(func():
	#		controller.unit_action_selection_handler("Cancel"))
	#self.add_child(btn)
	#if focused == false:
	#	btn.grab_focus.call_deferred()
	#	focused = true
