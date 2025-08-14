extends Control

@onready var button = $MarginContainer/VBoxContainer/Button


func _ready():
	button.grab_focus()

func _on_button_pressed():
	#var campaign_map_scene = preload()
	get_tree().change_scene_to_file("res://campaign_map/campaign_map.tscn")


func _on_button_gui_input(event):
	if event.is_action_pressed("ui_accept") and has_focus():
		var campaign_map_scene = preload("res://campaign_map/campaign_map.tscn")
		get_tree().change_scene_to_packed(campaign_map_scene)
