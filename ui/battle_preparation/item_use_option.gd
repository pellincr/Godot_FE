extends VBoxContainer

signal item_confirmed(item)

@onready var use_panel = $UsePanel
@onready var use_label = $Panel/UseLabel
@onready var cancel_panel = $CancelPanel
@onready var cancel_label = $Panel2/CancelLabel

var unit : Unit
var item : ItemDefinition


func _process(delta):
	if use_panel.has_focus():
		use_panel.theme = preload("res://ui/battle_preparation/panel_option_focused.tres")
	else:
		use_panel.theme = preload("res://ui/battle_preparation/panel_option_not_focused.tres")
	if cancel_panel.has_focus():
		cancel_panel.theme = preload("res://ui/battle_preparation/panel_option_focused.tres")
	else:
		cancel_panel.theme = preload("res://ui/battle_preparation/panel_option_not_focused.tres")
	
	
	if Input.is_action_just_pressed("ui_accept") and use_panel.has_focus():
		use_item(item, unit)
		item_confirmed.emit(item)
		queue_free()
	if Input.is_action_just_pressed("ui_accept") and cancel_panel.has_focus():
		cancel()
		queue_free()



func use_item(item:ItemDefinition, unit:Unit):
	unit.use_consumable_item(item)

func cancel():
	pass


func _on_use_panel_mouse_entered():
	use_panel.grab_focus()


func _on_cancel_panel_mouse_entered():
	cancel_panel.grab_focus()
