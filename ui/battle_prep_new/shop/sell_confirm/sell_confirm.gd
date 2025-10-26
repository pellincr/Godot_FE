extends PanelContainer
signal sell_item()
signal menu_closed()

@onready var sell_button: GeneralMenuButton = $MarginContainer/VBoxContainer/SellButton

func _ready() -> void:
	sell_button.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_cancel_button_pressed()


func _on_cancel_button_pressed() -> void:
	queue_free()
	menu_closed.emit()



func _on_sell_button_pressed() -> void:
	queue_free()
	sell_item.emit()
