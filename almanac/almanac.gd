extends Control

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)

@onready var header_label = $MarginContainer/VBoxContainer/PanelContainer/HBoxContainer/HeaderLabel
@onready var almanac_total_percent = $MarginContainer/VBoxContainer/PanelContainer/HBoxContainer/AlmanacTotalPercent


@onready var almanac_scroll_container = $MarginContainer/VBoxContainer/HBoxContainer/AlmanacScrollContainer
@onready var return_button = $ReturnButton


const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

func _ready():
	set_total_percent_value(playerOverworldData.unlock_manager.get_total_unlocked_percentage())
	transition_in_animation()
	almanac_scroll_container.set_po_data(playerOverworldData)


func _on_return_button_mouse_entered():
	return_button.grab_focus()

func transition_in_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_out")
	await get_tree().create_timer(.5).timeout
	scene_transition.queue_free()

func transition_out_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5).timeout


func set_total_percent_value(percent):
	almanac_total_percent.text = str(percent) + "%"


func _on_gui_input(event):
	if event.is_action_pressed("ui_accept") and return_button.has_focus():
		transition_out_animation()
		get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")


func _on_return_button_pressed():
	transition_out_animation()
	get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")


func _on_return_button_focus_entered():
	return_button.theme = preload("res://almanac/panel_container_focused.tres")


func _on_return_button_focus_exited():
	return_button.theme = preload("res://almanac/panel_container_not_focused.tres")
