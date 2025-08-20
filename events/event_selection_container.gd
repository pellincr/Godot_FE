extends VBoxContainer

signal event_option_selected(event)
signal leave_selected()

@onready var event_name_label = $EventNameLabel
@onready var event_description = $EventDescriptionPanel/EventDescription

@onready var event_option_button_1 = $EventOptionButton1
@onready var event_option_button_2 = $EventOptionButton2

@onready var leave_button = $LeaveButton

var event : Event

func _ready():
	event_option_button_1.grab_focus()
	if event:
		update_by_event()

func set_label_text(label,text):
	label.text = text


func update_by_event():
	set_label_text(event_name_label,event.name)
	set_label_text(event_description,event.description)
	event_option_button_1.event_option = event.option1
	event_option_button_1.update_by_event_option()
	event_option_button_2.event_option = event.option2
	event_option_button_2.update_by_event_option()

func _on_event_option_selected(event_option):
	event_option_selected.emit(event_option)

func _leave_selected():
	leave_selected.emit()
