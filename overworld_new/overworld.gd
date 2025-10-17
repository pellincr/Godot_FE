extends Panel

var playerOverworldData : PlayerOverworldData
var save_file_name = "PlayerOverworldSave.tres"

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")
const main_pause_menu_scene = preload("res://ui/main_pause_menu/main_pause_menu.tscn")

@onready var return_button = $ReturnButton
@onready var tutorial_campaign_selecter = $Tutorial

var pause_menu_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	transition_in_animation()
	tutorial_campaign_selecter.grab_focus()
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
	load_data()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if !pause_menu_open:
			var main_pause_menu = main_pause_menu_scene.instantiate()
			add_child(main_pause_menu)
			main_pause_menu.menu_closed.connect(_on_menu_closed)
			#disable_screen_focus()
			pause_menu_open = true
		else:
			get_child(-1).queue_free()
			_on_menu_closed()


func set_po_data(po_data):
	playerOverworldData = po_data

func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)
	print("Loaded")


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


func _on_campaign_selector_node_campaign_selected(campaign : Campaign):
	playerOverworldData.current_campaign = campaign
	playerOverworldData.max_archetype = campaign.number_of_archetypes_drafted
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	var army_draft = preload("res://unit drafting/Unit_Commander Draft/army_drafting.tscn")
	get_tree().change_scene_to_packed(army_draft)
	


func _on_return_button_pressed():
	transition_out_animation()
	get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")


func _on_colosseum_button_pressed():
	transition_out_animation()
	var tutorial_colosseum_scene = preload("res://overworld_new/tutorial_colosseum/tutorial_colosseum.tscn")
	get_tree().change_scene_to_packed(tutorial_colosseum_scene)

func set_screen_focus(focus):
	for child in self.get_children():
		if child is Panel:
			child.focus_mode = focus

func enable_screen_focus():
	set_screen_focus(FOCUS_ALL)

func disable_screen_focus():
	set_screen_focus(FOCUS_NONE)

func _on_menu_closed():
	#enable_screen_focus()
	pause_menu_open = false
	tutorial_campaign_selecter.grab_focus()
