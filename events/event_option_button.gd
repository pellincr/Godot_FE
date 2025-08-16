extends Button

signal event_option_selected(event_option:EventOption)

var event_option : EventOption

func _ready():
	if event_option:
		update_by_event_option()

func update_by_event_option():
	text = event_option.description

func _on_pressed():
	event_option_selected.emit(event_option)


func _on_gui_input(event):
	if event.is_action_pressed("ui_accept") and has_focus():
		_on_pressed()
