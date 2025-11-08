extends Control

class_name CampaignModifier

signal start_game(seeded: bool, seed:int, difficulty: DIFFICULTY)
signal menu_closed()

@onready var easy_mode_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/DificultyButtons/EasyModeButton
@onready var hard_mode_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/DificultyButtons/HardModeButton
@onready var custom_mode_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/DificultyButtons/CustomModeButton
#Seed Information
@onready var set_seed_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/SetSeedContainer
@onready var seed_value_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SetSeedContainer/UpperValueContainer/SeedValueLabel
@onready var keyboard_value_container: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/SetSeedContainer/KeyboardValueContainer

@onready var enter_seed_check_box: CheckBox = $PanelContainer/MarginContainer/VBoxContainer/BottomContainer/EnterSeedCheckBox

@onready var start_campaign_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/BottomContainer/StartCampaignButton


enum DIFFICULTY{
	EASY,HARD,CUSTOM
}
var current_difficulty := DIFFICULTY.EASY

func _ready() -> void:
	start_campaign_button.grab_focus()
	easy_mode_button.button_pressed = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_back") :
		queue_free()
		menu_closed.emit()


func set_seed_value_label(txt):
	seed_value_label.text = txt

func _add_self_to_seed():
	for child in keyboard_value_container.get_children():
		if child.has_focus() and seed_value_label.text.length() < 10:
			set_seed_value_label(seed_value_label.text + child.text)

func _on_backspace_button_pressed() -> void:
	set_seed_value_label(seed_value_label.text.left(seed_value_label.text.length() - 1))

func _on_easy_mode_button_pressed() -> void:
	if current_difficulty != DIFFICULTY.EASY:
		current_difficulty = DIFFICULTY.EASY
		hard_mode_button.button_pressed = false
	else:
		easy_mode_button.button_pressed = true


func _on_hard_mode_button_pressed() -> void:
	if current_difficulty != DIFFICULTY.HARD:
		current_difficulty = DIFFICULTY.HARD
		easy_mode_button.button_pressed = false
	else:
		hard_mode_button.button_pressed = true


func _on_custom_mode_button_pressed() -> void:
	pass # Replace with function body.


func _on_enter_seed_check_box_toggled(toggled_on: bool) -> void:
	set_seed_container.visible = toggled_on


func _on_start_campaign_button_pressed() -> void:
	#Determine if the Seed needs to be set
	var seeded : bool
	var selected_seed : int
	if enter_seed_check_box.button_pressed:
		selected_seed = hash(seed_value_label.text)
		seeded = true
	else:
		randomize()
		selected_seed = randi()
		seeded = false
	start_game.emit(seeded, selected_seed,current_difficulty)
	AudioManager.play_sound_effect("begin_campaign")
