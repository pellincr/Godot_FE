extends Control

class_name CampaignModifier

signal start_game(seeded: bool, seed:int, difficulty: DIFFICULTY, modifiers : Array[MODIFIER])
signal menu_closed()

@onready var easy_mode_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/DificultyButtons/EasyModeButton
@onready var normal_mode_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/DificultyButtons/NormalModeButton
@onready var hard_mode_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/DificultyButtons/HardModeButton
@onready var custom_mode_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/CustomModeButton

@onready var modifier_buttons: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ModifierButtons
@onready var modifier_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ModifierButtons/ModifierScrollContainer/ModifierContainer

#Seed Information
@onready var set_seed_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/SetSeedContainer
@onready var seed_value_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SetSeedContainer/UpperValueContainer/SeedValueLabel
@onready var info_label : Label = $PanelContainer/MarginContainer/VBoxContainer/InfoLabel
@onready var keyboard_value_container: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/SetSeedContainer/KeyboardValueContainer

@onready var enter_seed_check_box: CheckBox = $PanelContainer/MarginContainer/VBoxContainer/BottomContainer/EnterSeedCheckBox

@onready var start_campaign_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/BottomContainer/StartCampaignButton


enum DIFFICULTY{
	EASY,
	NORMAL,
	HARD,
	CUSTOM
}

enum MODIFIER{
	#HARD_LEVELING, 
	GOLIATH_MODE, 
	HYPER_GROWTH,
	LEVEL_SURGE
}

var current_difficulty := DIFFICULTY.NORMAL
var selected_modifiers : Array[MODIFIER]

func _ready() -> void:
	start_campaign_button.grab_focus()
	normal_mode_button.button_pressed = true
	fill_modifier_container()

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
		normal_mode_button.button_pressed = false
		hard_mode_button.button_pressed = false
		custom_mode_button.button_pressed = false
		modifier_buttons.visible = false
	else:
		easy_mode_button.button_pressed = true

func _on_easy_mode_hovered() -> void:
	update_info_text("pass")
	

func _on_normal_mode_button_pressed() -> void:
	if current_difficulty != DIFFICULTY.NORMAL:
		current_difficulty = DIFFICULTY.NORMAL
		easy_mode_button.button_pressed = false
		hard_mode_button.button_pressed = false
		custom_mode_button.button_pressed = false
		modifier_buttons.visible = false
	else:
		easy_mode_button.button_pressed = true

func _on_hard_mode_button_pressed() -> void:
	if current_difficulty != DIFFICULTY.HARD:
		current_difficulty = DIFFICULTY.HARD
		easy_mode_button.button_pressed = false
		normal_mode_button.button_pressed = false
		custom_mode_button.button_pressed = false
		modifier_buttons.visible = false
	else:
		hard_mode_button.button_pressed = true


func _on_custom_mode_button_pressed() -> void:
	modifier_buttons.visible = true
	#if current_difficulty != DIFFICULTY.CUSTOM:
		#current_difficulty = DIFFICULTY.CUSTOM
		#easy_mode_button.button_pressed = false
		#normal_mode_button.button_pressed = false
		#hard_mode_button.button_pressed = false
		#modifier_buttons.visible = true
	#else:
		#custom_mode_button.button_pressed = true
		#modifier_buttons.visible = true


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
	start_game.emit(seeded, selected_seed,current_difficulty, selected_modifiers)
	AudioManager.play_sound_effect("begin_campaign")

func get_modifier_name(mod:MODIFIER) -> String:
	var final_string = ""
	match mod:
		MODIFIER.GOLIATH_MODE:
			final_string = "Base Boost"
		MODIFIER.HYPER_GROWTH:
			final_string = "Hyper Growth"
		MODIFIER.LEVEL_SURGE:
			final_string = "Level Surge"
	return final_string


func update_info_text(str):
	info_label.text = str


func fill_modifier_container():
	for mod : MODIFIER in MODIFIER.values():
		var check_box := CheckButton.new()
		var modifier_name = get_modifier_name(mod)
		check_box.text = modifier_name
		modifier_container.add_child(check_box)
		check_box.size_flags_horizontal = Control.SIZE_FILL
		check_box.toggled.connect(_on_modifier_check_box_toggled.bind(mod))

func _on_modifier_check_box_toggled(toggled_on:bool, mod:MODIFIER):
	if toggled_on:
		selected_modifiers.append(mod)
	else:
		if selected_modifiers.has(mod):
			selected_modifiers.erase(mod)
