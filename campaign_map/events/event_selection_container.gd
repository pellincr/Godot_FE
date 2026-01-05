extends VBoxContainer

signal event_option_selected(event)
signal leave_selected()
signal event_option_hovered(event_option)
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
	event_option_button_1.connect("focus_entered",_on_event_option_hovered.bind(event.option1))
	event_option_button_2.event_option = event.option2
	event_option_button_2.update_by_event_option()
	event_option_button_2.connect("focus_entered",_on_event_option_hovered.bind(event.option2))
	event_option_button_3.event_option = event.option3
	event_option_button_3.update_by_event_option()
	event_option_button_3.connect("focus_entered",_on_event_option_hovered.bind(event.option3))

func _on_event_option_selected(event_option):
	event_option_selected.emit(event_option)
	disable_focus()

func _on_event_option_hovered(event_option):
	event_option_hovered.emit(event_option)

func disable_focus():
	event_option_button_1.focus_mode = FOCUS_NONE
	event_option_button_2.focus_mode = FOCUS_NONE
	event_option_button_3.focus_mode = FOCUS_NONE

func enable_focus():
	if not event_option_button_1.disabled:
		event_option_button_1.focus_mode = FOCUS_ALL
	if not event_option_button_1.disabled:
		event_option_button_2.focus_mode = FOCUS_ALL
	if not event_option_button_1.disabled:
		event_option_button_3.focus_mode = FOCUS_ALL



func update_valid_event_options(option_1: bool, option_2: bool, option_3: bool):
	update_event_option_button(option_1, event_option_button_1)
	update_event_option_button(option_2, event_option_button_2)
	update_event_option_button(option_3, event_option_button_3)

func update_event_option_button(valid:bool, button:Button):
	if valid:
		button.focus_mode = FOCUS_ALL
		button.visible = true
		button.disabled = false
	else:
		button.focus_mode = Control.FOCUS_NONE
		button.visible = false
		button.disabled = true

func _leave_selected():
	leave_selected.emit()

func grab_first_effective_focus():
	if not event_option_button_1.disabled:
		event_option_button_1.grab_focus()
		return
	if not event_option_button_2.disabled:
		event_option_button_2.grab_focus()
		return
	if not event_option_button_3.disabled:
		event_option_button_3.grab_focus()
		return
