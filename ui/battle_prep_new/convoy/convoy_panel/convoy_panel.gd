extends PanelContainer

signal convoy_panel_pressed()



func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		convoy_panel_pressed.emit()
