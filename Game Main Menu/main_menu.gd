extends Control

signal adventure_begun()
const overworld_scene = "res://overworld_new/overworld.tscn"
var playerOverworldData : PlayerOverworldData

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

const ALMANAC_SCENE = preload("res://almanac/almanac.tscn")
const TUTORIAL_PAGE_SCENE = preload("res://tutorials/tutorial_page.tscn")
const HALL_OF_HEROES_SCENE = preload("res://hall_of_heroes/hall_of_heroes.tscn")

@onready var new_game_button = $VBoxContainer/NewGameButton

@onready var continue_game_button = $VBoxContainer/ContinueGameButton


func _ready():
	transition_in_animation()
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	#SelectedSaveFile.save(playerOverworldData)
	load_data()
	if playerOverworldData.current_campaign:
		continue_game_button.visible = true
		set_continue_game_button_text()
		continue_game_button.grab_focus()
	else:
		continue_game_button.visible = false
		new_game_button.grab_focus()

func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)
	print("Loaded")

func set_player_overworld_data(po_data):
	playerOverworldData = po_data

func set_button_text(button,text):
	button.text = text



func _on_continue_game_button_pressed():
	if playerOverworldData.completed_drafting:
		if playerOverworldData.current_level:
			if playerOverworldData.began_level:
				#if the level was previously being played
				transition_out_animation()
				get_tree().change_scene_to_packed(playerOverworldData.current_level)
			else:
				#when the level has been selected but battle prep has not been completed
				var battle_prep_scene = preload("res://ui/battle_preparation/battle_preparation.tscn")
				get_tree().change_scene_to_packed(battle_prep_scene)
		else:
			#when the level has not been selected from the campaign map yet
			var campaign_map = preload("res://campaign_map/campaign_map.tscn")
			get_tree().change_scene_to_packed(campaign_map)
	else:
		#when drafting is not completed, but the campaign was selected
		var draft_scene = preload("res://unit drafting/Unit_Commander Draft/army_drafting.tscn")
		get_tree().change_scene_to_packed(draft_scene)
	


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


func _on_almanac_button_pressed():
	transition_out_animation()
	get_tree().change_scene_to_packed(ALMANAC_SCENE)


func _on_hall_of_heroes_button_pressed():
	transition_out_animation()
	get_tree().change_scene_to_packed(HALL_OF_HEROES_SCENE)


func _on_tutorials_pressed():
	transition_out_animation()
	get_tree().change_scene_to_packed(TUTORIAL_PAGE_SCENE)


func _on_new_game_button_pressed():
	var overworld = preload(overworld_scene)
	playerOverworldData.current_campaign = null
	playerOverworldData.completed_drafting = false
	playerOverworldData.current_level = null
	playerOverworldData.began_level = false
	playerOverworldData.floors_climbed = 0
	playerOverworldData.current_archetype_count = 0
	overworld.instantiate().set_po_data(playerOverworldData)
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	get_tree().change_scene_to_packed(overworld)

func set_continue_game_button_text():
	var str = ""
	if playerOverworldData.completed_drafting:
		str = playerOverworldData.current_campaign.name + " - Floor " + str(playerOverworldData.combat_maps_completed)
		if playerOverworldData.began_level:
			str += " - Battle"
		elif playerOverworldData.current_level:
			str += " - Prep"
	else:
		str = playerOverworldData.current_campaign.name + " - Draft"
	continue_game_button.text = "Continue :" + str
