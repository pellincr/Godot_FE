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

func _on_return_pressed():
	var overworld_scene = preload("res://overworld_new/overworld.tscn")
	transition_out_animation()
	get_tree().change_scene_to_file("res://overworld_new/overworld.tscn")

func go_to_totorial_scene(tutorial:PackedScene):
	playerOverworldData.current_level = tutorial
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	get_tree().change_scene_to_packed(tutorial)

func _on_mundane_pressed():
	var mundane_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/weapon_tutorials/mundane_tutorial/mundane_tutorial.tscn")
	go_to_totorial_scene(mundane_tutorial_scene)

func _on_magic_pressed():
	var magic_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/weapon_tutorials/magic_tutorial/magic_tutorial.tscn")
	go_to_totorial_scene(magic_tutorial_scene)

func _on_weapon_cycle_pressed():
	var weapon_cycle_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/weapon_tutorials/weapon_cycle_tutorial/weapon_cycle_tutorial.tscn")
	go_to_totorial_scene(weapon_cycle_tutorial_scene)

func _on_support_actions_pressed():
	var support_action_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/support_tutorials/support_action_tutorial/support_action_tutorial.tscn")
	go_to_totorial_scene(support_action_tutorial_scene)


func _on_staffs_pressed():
	var staff_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/support_tutorials/staffs_tutorial/staffs_tutorial.tscn")
	go_to_totorial_scene(staff_tutorial_scene)


func _on_banners_pressed():
	var banners_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/support_tutorials/banners_tutorial/banners_tutorial.tscn")
	go_to_totorial_scene(banners_tutorial_scene)


func _on_terrain_pressed():
	var terrain_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/terrain_tutorials/terrain_tutorial/terrain_tutorial.tscn")
	go_to_totorial_scene(terrain_tutorial_scene)


func _on_defeat_all_enemies_pressed():
	var defeat_all_enemies_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/win_conditions_tutorials/defeat_all_enemies_tutorial/defeat_all_enemies_tutorial.tscn")
	go_to_totorial_scene(defeat_all_enemies_tutorial_scene)


func _on_sieze_landmark_pressed():
	var sieze_landmark_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/win_conditions_tutorials/sieze_landmark_tutorial/sieze_landmark_tutorial.tscn")
	go_to_totorial_scene(sieze_landmark_tutorial_scene)



func _on_defeat_bosses_pressed():
	var defeat_bosses_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/win_conditions_tutorials/defeat_bosses_tutorial/defeat_bosses_tutorial.tscn")
	go_to_totorial_scene(defeat_bosses_tutorial_scene)


func _on_survive_turns_pressed():
	var survive_turns_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/win_conditions_tutorials/survive_turns_tutorial/survive_turns_tutorial.tscn")
	go_to_totorial_scene(survive_turns_tutorial_scene)


func _on_campaign_pressed():
	var tutorial_campaign = preload("res://resources/definitions/campaigns/tutorial.tres")
	playerOverworldData.current_campaign = tutorial_campaign
	playerOverworldData.max_archetype = tutorial_campaign.number_of_archetypes_drafted
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	var army_draft = preload("res://unit drafting/Unit_Commander Draft/army_drafting.tscn")
	get_tree().change_scene_to_packed(army_draft)


func _on_how_to_play_pressed():
	var how_to_play_tutorial_scene = preload("res://combat/levels/tutorial_colosseum_levels/how_to_play/how_to_play_tutorial/how_to_play_tutorial.tscn")
	go_to_totorial_scene(how_to_play_tutorial_scene)
