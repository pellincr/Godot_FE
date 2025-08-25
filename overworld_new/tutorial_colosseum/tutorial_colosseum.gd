extends Control

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")


@onready var playerOverworldData: PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)
@onready var mundane = $TutorialContainer/WeaponTutorialContainer/Mundane

func _ready():
	transition_in_animation()
	mundane.grab_focus()

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

func _on_mundane_pressed():
	var mundane_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/mundane_tutorial/mundane_tutorial.tscn")
	playerOverworldData.current_level = mundane_tutorial_scene
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	get_tree().change_scene_to_packed(mundane_tutorial_scene)


func _on_return_pressed():
	var overworld_scene = preload("res://overworld_new/overworld.tscn")
	transition_out_animation()
	get_tree().change_scene_to_packed(overworld_scene)
