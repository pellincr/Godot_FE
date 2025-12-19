extends Control

class_name StartScreen

enum STATE {
	TITLE_SCREEN,
	SAVE_SLOT
}

var current_state = STATE.TITLE_SCREEN

#@onready var playerOverworldData := PlayerOverworldData.new()

#Extra Scenes
const OPTIONS_SCENE = preload("res://options/options.tscn")
const MAIN_MENU_SCENE = preload("res://Game Main Menu/main_menu.tscn")
const TITLE_SCREEN_SCENE = preload("res://Main Game Scenes/Start Screen/Title Screen/title_screen.tscn")
const SAVE_SLOT_SELECT_SCENE = preload("res://Main Game Scenes/Start Screen/Save Slot Select/save_slot_select.tscn")


#Called when the node enters the scene tree for the first time.
func _ready():
	set_current_state(current_state)
	#Load the Saved Options
	OptionsConfig.load_options()
	#Create a new PO_Data
	#if !playerOverworldData:
	#	playerOverworldData = PlayerOverworldData.new()
	SceneTransitionAnimation.transition_in_animation(self)
	SelectedSaveFile.selected_save_path = ""
	AudioManager.play_music("menu_theme")

func set_current_state(state:STATE):
	current_state = state
	update_by_state()

func clear_children():
	for child in get_children():
		child.queue_free()

func update_by_state():
	clear_children()
	match current_state:
		STATE.TITLE_SCREEN:
			var title_screen = TITLE_SCREEN_SCENE.instantiate()
			add_child(title_screen)
			title_screen.start_game.connect(_on_start_game_pressed)
			SignalBus.options_open.connect(_on_options_button_pressed)
		STATE.SAVE_SLOT:
			var save_slot_select_screen = SAVE_SLOT_SELECT_SCENE.instantiate()
			add_child(save_slot_select_screen)
			save_slot_select_screen.menu_back.connect(_on_save_slot_select_menu_back)
			save_slot_select_screen.save_entered.connect(_on_save_entered)

##Title Screen Functions
func _on_start_game_pressed():
	set_current_state(STATE.SAVE_SLOT)

func _on_options_button_pressed():
	var options = OPTIONS_SCENE.instantiate()
	add_child(options)

##Save Slot Select Screen Functions
func _on_save_slot_select_menu_back():
	set_current_state(STATE.TITLE_SCREEN)

func _on_save_entered():
	SceneTransitionAnimation.transition_out_animation(self)
	##TODO Change scene to new overworld
	pass
