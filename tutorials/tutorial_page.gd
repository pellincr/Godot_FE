extends Control


@onready var main_scroll_container = $MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/MainScrollContainer

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")


var tutorials = [
	TutorialPanel.TUTORIAL.HOW_TO_PLAY,
	TutorialPanel.TUTORIAL.DRAFT,
	TutorialPanel.TUTORIAL.BATTLE_PREP,
	TutorialPanel.TUTORIAL.CAMPAIGN_MAP,
	TutorialPanel.TUTORIAL.MUNDANE_WEAPONS,
	TutorialPanel.TUTORIAL.MAGIC_WEAPONS,
	TutorialPanel.TUTORIAL.WEAPON_CYCLE,
	TutorialPanel.TUTORIAL.SUPPORT_ACTIONS,
	TutorialPanel.TUTORIAL.STAFFS,
	TutorialPanel.TUTORIAL.BANNERS,
	TutorialPanel.TUTORIAL.TERRAIN,
	TutorialPanel.TUTORIAL.DEFEAT_ALL_ENEMIES,
	TutorialPanel.TUTORIAL.SIEZE_LANDMARK,
	TutorialPanel.TUTORIAL.DEFEAT_BOSSES,
	TutorialPanel.TUTORIAL.SURVIVE_TURNS]

var focused := false
var pressed_tutorial_button : Button

func _ready():
	transition_in_animation()
	fill_main_scroll_container()

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

func create_tutorial_button(tutorial : TutorialPanel.TUTORIAL) -> Button:
	var button := Button.new()
	match tutorial:
		TutorialPanel.TUTORIAL.HOW_TO_PLAY:
			button.text = "How to Play"
		TutorialPanel.TUTORIAL.DRAFT:
			button.text = "Army Drafting"
		TutorialPanel.TUTORIAL.BATTLE_PREP:
			button.text = "Battle Preparation"
		TutorialPanel.TUTORIAL.CAMPAIGN_MAP:
			button.text = "Campaign Map"
		TutorialPanel.TUTORIAL.MUNDANE_WEAPONS:
			button.text = "Mundane Weapons"
		TutorialPanel.TUTORIAL.MAGIC_WEAPONS:
			button.text = "Magic Weapons"
		TutorialPanel.TUTORIAL.WEAPON_CYCLE:
			button.text = "Weapon Cycle"
		TutorialPanel.TUTORIAL.SUPPORT_ACTIONS:
			button.text = "Support Actions"
		TutorialPanel.TUTORIAL.STAFFS:
			button.text = "Staffs"
		TutorialPanel.TUTORIAL.BANNERS:
			button.text = "Banners"
		TutorialPanel.TUTORIAL.TERRAIN:
			button.text = "Terrain"
		TutorialPanel.TUTORIAL.DEFEAT_ALL_ENEMIES:
			button.text = "Defeat All Enemies"
		TutorialPanel.TUTORIAL.SIEZE_LANDMARK:
			button.text = "Sieze Landmark"
		TutorialPanel.TUTORIAL.DEFEAT_BOSSES:
			button.text = "Defeat Bosses"
		TutorialPanel.TUTORIAL.SURVIVE_TURNS:
			button.text = "Survive Turns"
	button.pressed.connect(_on_tutorial_button_pressed.bind(tutorial,button))
	return button

func fill_main_scroll_container():
	for tutorial in tutorials:
		var button := create_tutorial_button(tutorial)
		main_scroll_container.add_child(button)
		if !focused:
			button.grab_focus()
			focused = true

func _on_tutorial_button_pressed(tutorial:TutorialPanel.TUTORIAL,button):
	var tutorial_panel = preload("res://ui/tutorial/tutorial_panel.tscn").instantiate()
	tutorial_panel.current_state = tutorial
	tutorial_panel.tutorial_completed.connect(_on_tutorial_complete)
	add_child(tutorial_panel)
	pressed_tutorial_button = button


func _on_return_button_pressed():
	transition_out_animation()
	get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")


func _on_tutorial_complete():
	pressed_tutorial_button.grab_focus()
