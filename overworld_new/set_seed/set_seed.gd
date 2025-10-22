extends Control

signal set_seed(campaign_seed:int)
signal menu_closed()

@onready var seed_initialize_container: VBoxContainer = $PanelContainer/MarginContainer/SeedInitializeContainer
@onready var set_seed_container: VBoxContainer = $PanelContainer/MarginContainer/SetSeedContainer
@onready var random_seed_button: GeneralMenuButton = $PanelContainer/MarginContainer/SeedInitializeContainer/RandomSeedButton

@onready var seed_value_label: Label = $PanelContainer/MarginContainer/SetSeedContainer/UpperValueContainer/SeedValueLabel
@onready var keyboard_value_container: GridContainer = $PanelContainer/MarginContainer/SetSeedContainer/KeyboardValueContainer
@onready var button_1: GeneralMenuButton = $PanelContainer/MarginContainer/SetSeedContainer/KeyboardValueContainer/Button1

func _ready() -> void:
	random_seed_button.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_back") :
		queue_free()
		menu_closed.emit()


func set_seed_value_label(val):
	seed_value_label.text = val

func _on_random_seed_button_pressed() -> void:
	randomize()
	var campaign_seed := randi()
	seed(campaign_seed)
	print("Seed set to: " + str(campaign_seed))
	
	queue_free()
	set_seed.emit(campaign_seed)


func _on_set_seed_button_pressed() -> void:
	set_seed_container.visible = true
	seed_initialize_container.visible = false
	button_1.grab_focus()

func add_self_to_seed():
	for child in keyboard_value_container.get_children():
		if child.has_focus() and seed_value_label.text.length() < 10:
			set_seed_value_label(seed_value_label.text+child.text)


func _on_confirm_seed_button_pressed() -> void:
	var campaign_seed = hash(seed_value_label.text)
	seed(campaign_seed)
	print("Seed set to: " + str(campaign_seed))
	queue_free()
	set_seed.emit(campaign_seed)


func _on_return_button_pressed() -> void:
	seed_initialize_container.visible = true
	set_seed_container.visible = false
	seed_value_label.text = ""


func _on_backspace_button_pressed() -> void:
	set_seed_value_label(seed_value_label.text.left(seed_value_label.text.length() - 1))
