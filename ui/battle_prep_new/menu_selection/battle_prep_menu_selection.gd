extends Control

signal start_game()
signal state_selected(state:BattlePrep.PREP_STATE)
signal save_game()


@onready var start_battle_button: GeneralMenuButton = $BattlePrepMenuSelection/MarginContainer/ButtonContainer/StartBattleButton
#@onready var shop_button: Button = $MarginContainer/ButtonContainer/ShopButton
@onready var button_container: VBoxContainer = $BattlePrepMenuSelection/MarginContainer/ButtonContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_battle_button.grab_focus()


func _on_unit_selection_button_pressed() -> void:
	state_selected.emit(BattlePrep.PREP_STATE.UNIT_SELECTION)


func _on_swap_spaces_button_pressed() -> void:
	state_selected.emit(BattlePrep.PREP_STATE.SWAP_SPACES)


func _on_shop_button_pressed() -> void:
	state_selected.emit(BattlePrep.PREP_STATE.SHOP)

func _on_inventory_button_pressed() -> void:
	state_selected.emit(BattlePrep.PREP_STATE.INVENTORY)

func _on_training_grounds_button_pressed() -> void:
	state_selected.emit(BattlePrep.PREP_STATE.TRAINING_GROUNDS)

func _on_graveyard_button_pressed() -> void:
	state_selected.emit(BattlePrep.PREP_STATE.GRAVEYARD)

func set_button_focus(focus_bool:bool):
	var buttons = button_container.get_children()
	for button in buttons:
		if focus_bool:
			button.focus_mode = FocusMode.FOCUS_ALL
		else:
			button.focus_mode = FocusMode.FOCUS_NONE

func disable_button_focus():
	set_button_focus(false)

func enable_button_focus():
	set_button_focus(true)

#func shop_entered(state : BattlePrep.PREP_STATE):
#	state_selected.emit(state)


func _on_start_battle_button_pressed() -> void:
	start_game.emit()

func grab_start_button_focus():
	start_battle_button.grab_focus()





func _on_save_preparations_button_pressed() -> void:
	save_game.emit()
