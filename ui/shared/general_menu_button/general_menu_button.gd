extends Button

class_name GeneralMenuButton


func _on_focus_entered() -> void:
	AudioManager.play_sound_effect("menu_cursor")


func _on_pressed() -> void:
	AudioManager.play_sound_effect("menu_confirm")
