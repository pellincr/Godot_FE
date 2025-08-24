extends MarginContainer

@onready var hoh_main_scroll_container = $VBoxContainer/HallOfHeroesMainScrollContainer

@onready var return_button = $VBoxContainer/ReturnButton

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	transition_in_animation()
	hoh_main_scroll_container.set_po_data(playerOverworldData)
	hoh_main_scroll_container.fill_main_scroll_container()
	return_button.grab_focus()


func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and return_button.has_focus():
		transition_out_animation()
		get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")
	if return_button.has_focus():
		return_button.theme = preload("res://almanac/panel_container_focused.tres")
	else:
		return_button.theme = preload("res://almanac/panel_container_not_focused.tres")


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
