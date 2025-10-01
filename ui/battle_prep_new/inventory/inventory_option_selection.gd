extends PanelContainer


signal inventory_option_state_selected(state : InventoryPrepScreen.INVENTORY_STATE)
signal store_all()
signal menu_closed()

@onready var manage_items_button: Button = $MarginContainer/VBoxContainer/ManageItemsButton


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		queue_free()
		menu_closed.emit()


func _on_manage_items_button_pressed() -> void:
	AudioManager.play_sound_effect("menu_confirm")
	inventory_option_state_selected.emit(InventoryPrepScreen.INVENTORY_STATE.MANAGE_ITEMS)


func _on_trade_button_pressed() -> void:
	AudioManager.play_sound_effect("menu_confirm")
	inventory_option_state_selected.emit(InventoryPrepScreen.INVENTORY_STATE.PICK_TRADE_UNIT)


func _on_store_all_button_pressed() -> void:
	AudioManager.play_sound_effect("menu_confirm")
	store_all.emit()

func manage_items_button_grab_focus():
	manage_items_button.grab_focus()
