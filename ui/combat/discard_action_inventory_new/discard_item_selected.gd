extends Panel

@onready var item_icon: TextureRect = $Panel/MarginContainer/VBoxContainer2/HBoxContainer2/ItemIcon
@onready var item_name: Label = $Panel/MarginContainer/VBoxContainer2/HBoxContainer2/ItemName
@onready var cancel_button: Button = $Panel/MarginContainer/VBoxContainer2/HBoxContainer/CancelButton
@onready var discard_button: Button = $Panel/MarginContainer/VBoxContainer2/HBoxContainer/DiscardButton

@export var selected_item: ItemDefinition

signal discard(item:ItemDefinition)
signal cancel()

func popualate(selected_item : ItemDefinition) -> void:
	self.selected_item = selected_item
	update_visuals()

func update_visuals():
	if selected_item != null:
		item_icon.texture = selected_item.icon
		item_name.text = str(selected_item.name + " ?")

func _on_discard_button_pressed() -> void:
	discard.emit(selected_item)

func grab_focus_btns():
	discard_button.grab_focus()

func _on_cancel_button_pressed() -> void:
	cancel.emit()
