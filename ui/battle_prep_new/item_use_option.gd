extends VBoxContainer

signal item_confirmed(item)

@onready var use_panel = $UsePanel
@onready var use_label = $Panel/UseLabel
@onready var cancel_panel = $CancelPanel
@onready var cancel_label = $Panel2/CancelLabel

var unit : Unit
var item : ItemDefinition


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if use_panel.has_focus():
			use_item(item, unit)
			item_confirmed.emit(item)
		queue_free()
	if Input.is_action_just_pressed("ui_accept"):
		cancel()
		queue_free()



func use_item(item:ItemDefinition, unit:Unit):
	unit.use_consumable_item(item)
	if item.uses == 0:
		unit.discard_item(item)

func cancel():
	pass


func _on_use_panel_mouse_entered():
	use_panel.grab_focus()


func _on_cancel_panel_mouse_entered():
	cancel_panel.grab_focus()


func _on_use_panel_focus_entered() -> void:
	use_panel.theme = preload("res://ui/battle_prep_new/panel_option_focused.tres")


func _on_use_panel_focus_exited() -> void:
	use_panel.theme = preload("res://ui/battle_prep_new/panel_option_not_focused.tres")


func _on_cancel_label_focus_entered() -> void:
	cancel_panel.theme = preload("res://ui/battle_prep_new/panel_option_focused.tres")


func _on_cancel_label_focus_exited() -> void:
	cancel_panel.theme = preload("res://ui/battle_prep_new/panel_option_not_focused.tres")
