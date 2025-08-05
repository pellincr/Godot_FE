extends Control

signal adventure_begun()
const overworld_scene = "res://overworld_new/overworld.tscn"
var playerOverworldData : PlayerOverworldData

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")


func _ready():
	transition_in_animation()
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	SelectedSaveFile.save(playerOverworldData)

func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)
	print("Loaded")

func set_player_overworld_data(po_data):
	playerOverworldData = po_data

func _on_begin_adventure_button_pressed():
	var overworld = preload(overworld_scene)
	overworld.instantiate().set_po_data(playerOverworldData)
	transition_out_animation()
	get_tree().change_scene_to_packed(overworld)

#Returns to the main menu scene from the selected save
func _on_return_to_start_button_pressed():
	transition_out_animation()
	get_tree().change_scene_to_file("res://Game Start Screen/start_screen.tscn")
	SelectedSaveFile.selected_save_path = ""


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
