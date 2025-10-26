extends PanelContainer

signal convoy_panel_pressed()

@onready var label: Label = $MarginContainer/Label


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		convoy_panel_pressed.emit()
		AudioManager.play_sound_effect("menu_confirm")


func _on_focus_entered() -> void:
	#label.self_modulate = "FFFFFF"
	AudioManager.play_sound_effect("menu_cursor")
	theme = preload("res://ui/battle_prep_new/unit_army_panel/unit_panel_not_selected_hovered.tres")


func _on_focus_exited() -> void:
	#label.self_modulate = "828282"
	theme = preload("res://ui/battle_prep_new/unit_army_panel/unit_panel_not_selected.tres")
