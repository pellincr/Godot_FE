extends Button

signal event_option_selected(event_option:EventOption)
@onready var rich_text_label: RichTextLabel = $MarginContainer/RichTextLabel

var event_option : EventOption

func _ready():
	if event_option:
		update_by_event_option()

func update_by_event_option():
	if event_option != null:
		self.visible = true
		rich_text_label.text = "[color=#FAFA82]" + event_option.title + "[/color][p]" + event_option.description + "[/p]"
	else :
		self.visible = false
		self.focus_mode = FOCUS_NONE
	
func _on_pressed():
	event_option_selected.emit(event_option)

func _on_gui_input(event):
	if event.is_action_pressed("ui_accept") and has_focus():
		_on_pressed()
