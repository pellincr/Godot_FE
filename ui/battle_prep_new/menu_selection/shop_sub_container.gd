extends MarginContainer

signal shop_entered(state : BattlePrep.PREP_STATE)
signal menu_closed()

@onready var buy_button: Button = $PanelContainer/VBoxContainer/BuyButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buy_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		menu_closed.emit()
		queue_free()


func _on_buy_button_pressed() -> void:
	shop_entered.emit(BattlePrep.PREP_STATE.SHOP_BUY)


func _on_sell_button_pressed() -> void:
	shop_entered.emit(BattlePrep.PREP_STATE.SHOP_SELL)
