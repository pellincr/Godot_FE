extends VBoxContainer

signal event_option_selected(event)
signal leave_selected()
@onready var event_name_label: RichTextLabel = $EventNameLabel
@onready var event_description: RichTextLabel = $EventDescription

@onready var event_option_button_1 = $EventOptionButton1
@onready var event_option_button_2 = $EventOptionButton2
@onready var event_option_button_3 = $EventOptionButton3
@onready var event_option_button_4 = $EventOptionButton4


@onready var leave_button = $LeaveButton

var event : Event

func _ready():
	event_option_button_1.grab_focus()
	if event:
		update_by_event()

func set_description_text(text):
	event_description.text = "[center]" + text + "[/center]"

func set_header_text(text):
	event_name_label.text = "[center][color=#FAFA82]" + text + "[/color][/center]"

func update_by_event():
	set_header_text(event.name)
	set_description_text(event.description)
	
	event_option_button_1.event_option = event.option1
	event_option_button_1.update_by_event_option()
	event_option_button_2.event_option = event.option2
	event_option_button_2.update_by_event_option()
	event_option_button_3.event_option = event.option3
	event_option_button_3.update_by_event_option()

func _on_event_option_selected(event_option):
	event_option_selected.emit(event_option)
	event_option_button_1.focus_mode = FOCUS_NONE
	event_option_button_2.focus_mode = FOCUS_NONE
	event_option_button_3.focus_mode = FOCUS_NONE

func _leave_selected():
	leave_selected.emit()
