extends Control

signal equip_item(item:ItemDefinition)
signal use_item(item:ItemDefinition)
signal send_item_to_convoy(item:ItemDefinition)
signal sell_item(item:ItemDefinition)
signal menu_closed()

@onready var equip_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/EquipButton
@onready var use_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/UseButton
@onready var to_convoy_button: GeneralMenuButton = $PanelContainer/MarginContainer/VBoxContainer/ToConvoyButton

var item : ItemDefinition


func _ready() -> void:
	if item:
		if item is WeaponDefinition:
			set_use_button_visible(false)
			equip_button.grab_focus()
		elif item is ConsumableItemDefinition:
			set_equip_button_visible(false)
			use_button.grab_focus()
		else:
			set_use_button_visible(false)
			set_equip_button_visible(false)
			to_convoy_button.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		_on_cancel_button_pressed()

func set_equip_button_visible(vis:bool):
	equip_button.visible = vis

func set_use_button_visible(vis:bool):
	use_button.visible = vis




func _on_equip_button_pressed() -> void:
	equip_item.emit(item)
	_on_cancel_button_pressed()


func _on_use_button_pressed() -> void:
	use_item.emit(item)
	_on_cancel_button_pressed()


func _on_to_convoy_button_pressed() -> void:
	send_item_to_convoy.emit(item)
	_on_cancel_button_pressed()


func _on_sell_button_pressed() -> void:
	sell_item.emit(item)
	_on_cancel_button_pressed()


func _on_cancel_button_pressed() -> void:
	queue_free()
	menu_closed.emit()
