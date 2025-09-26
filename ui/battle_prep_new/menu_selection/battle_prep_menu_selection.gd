extends PanelContainer

signal start_game()
signal state_selected(state:BattlePrep.PREP_STATE)


@onready var start_battle_button: Button = $MarginContainer/ButtonContainer/StartBattleButton
#@onready var shop_button: Button = $MarginContainer/ButtonContainer/ShopButton
@onready var button_container: VBoxContainer = $MarginContainer/ButtonContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_battle_button.grab_focus()


func _on_unit_selection_button_pressed() -> void:
	state_selected.emit(BattlePrep.PREP_STATE.UNIT_SELECTION)


func _on_swap_spaces_button_pressed() -> void:
	state_selected.emit(BattlePrep.PREP_STATE.SWAP_SPACES)


func _on_shop_button_pressed() -> void:
	#set_prep_state(BattlePrep.PREP_STATE.SHOP)
	state_selected.emit(BattlePrep.PREP_STATE.SHOP)
	#var shop_sub_container = preload("res://ui/battle_prep_new/menu_selection/shop_sub_container.tscn").instantiate()
	#add_child(shop_sub_container)
	#shop_sub_container.position = Vector2(395,135)
	#shop_sub_container.menu_closed.connect(shop_menu_close)
	#shop_sub_container.shop_entered.connect(shop_entered)
	#disable_button_focus()

#func shop_menu_close():
#	enable_button_focus()
#	shop_button.grab_focus()

func _on_inventory_button_pressed() -> void:
	state_selected.emit(BattlePrep.PREP_STATE.INVENTORY)

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
