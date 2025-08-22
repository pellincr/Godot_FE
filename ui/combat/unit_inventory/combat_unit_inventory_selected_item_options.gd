extends Panel

@onready var equip_button: Button = $VBoxContainer/EquipButton
@onready var un_equip_button: Button = $VBoxContainer/UnEquipButton
@onready var use_button: Button = $VBoxContainer/UseButton
@onready var arrange_button: Button = $VBoxContainer/ArrangeButton
@onready var discard_button: Button = $VBoxContainer/DiscardButton

@export var selected_item: ItemDefinition
@export var equipped: bool = false
@export var can_use: bool = false
@export var can_arrange : bool = false

signal equip(item:ItemDefinition)
signal unequip(item:ItemDefinition)
signal use(item:ItemDefinition)
signal arrange(item:ItemDefinition)
signal discard(item:ItemDefinition)

func popualate(selected_item : ItemDefinition, equipped : bool = false, can_use : bool = false, can_arrange : bool = false) -> void:
	self.selected_item = selected_item
	self.equipped = equipped
	self.can_use = can_use
	self.can_arrange = can_arrange
	update_buttons()

func update_buttons():
	if selected_item is WeaponDefinition:
		use_button.disabled = true
		use_button.visible = false
		if equipped:
			equip_button.visible = false
			equip_button.disabled = true
			un_equip_button.visible = true
			un_equip_button.disabled = false
			un_equip_button.grab_focus()
		else:
			if can_use: #the player can equip
				un_equip_button.visible = false
				equip_button.visible = true
				equip_button.grab_focus()
			else: 
				equip_button.visible = false
				un_equip_button.visible = false
				un_equip_button.disabled = true
				equip_button.disabled = true
	elif selected_item is ConsumableItemDefinition:
		equip_button.visible = false
		un_equip_button.visible = false
		un_equip_button.disabled = true
		equip_button.disabled = true
		if can_use:
			use_button.visible = true
			equip_button.grab_focus()
	if can_arrange:
		arrange_button.visible = true
	else : 
		arrange_button.visible = false

func _on_equip_button_pressed() -> void:
	equip.emit(selected_item)


func _on_un_equip_button_pressed() -> void:
	unequip.emit(selected_item)


func _on_use_button_pressed() -> void:
	use.emit(selected_item)


func _on_arrange_button_pressed() -> void:
	arrange.emit(selected_item)


func _on_discard_button_pressed() -> void:
	discard.emit(selected_item)

func grab_focus_btn():
	if not discard_button.disabled:
		discard_button.grab_focus()
	if not arrange_button.disabled:
		arrange_button.grab_focus()
	if not use_button.disabled:
		use_button.grab_focus()
	if not un_equip_button.disabled:
		un_equip_button.grab_focus()
	if not equip_button.disabled:
		equip_button.grab_focus()




	
