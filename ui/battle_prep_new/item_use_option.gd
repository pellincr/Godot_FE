extends VBoxContainer

signal item_confirmed(item)
signal cancelled()

@onready var use_button: GeneralMenuButton = $UseButton

var unit : Unit
var item : ItemDefinition

"""
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if use_panel.has_focus():
			use_item(item, unit)
			item_confirmed.emit(item)
		queue_free()
	if Input.is_action_just_pressed("ui_accept"):
		cancel()
		queue_free()
"""

func _ready() -> void:
	use_button.grab_focus()

func use_item(i:ItemDefinition, u:Unit):
	u.use_consumable_item(i)
	if item.uses == 0:
		u.discard_item(i)

func cancel():
	cancelled.emit()

func _on_use_button_pressed() -> void:
	use_item(item, unit)
	item_confirmed.emit(item)


func _on_cancel_button_pressed() -> void:
	cancel()
	queue_free()
