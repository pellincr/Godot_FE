extends Control

class_name unitStatsDisplay

signal  unit_selected(unit : Unit, selected: bool)
signal  unit_dismissed(unit : Unit)

var playerOverworldData : PlayerOverworldData #ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)
var control_node : Node

var shop_scene = preload("res://overworld/shop_v_container.tscn")
var inventory_scene = preload("res://ui/combat/attack_action_inventory/attack_action_inventory.tscn")
var convoy_scene = preload("res://overworld/convoy_v_container.tscn")
@onready var selected = false
var unit = null


func _ready():
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	
	if playerOverworldData.selected_party.find(unit) == -1:
		set_select_button_text(false)
		selected = false
	else:
		set_select_button_text(true)
		selected = true

func set_control_node(c_node):
	control_node = c_node

func set_stat(label: Label, stat):
	var colon_index = label.text.find(":")
	label.text = label.text.substr(0,colon_index+1) + " " +str(stat)

func set_level(level):
	set_stat($Panel/HBoxContainer/VBoxContainer2/Level,level)

func set_hp(amount):
	set_stat($Panel/HBoxContainer/VBoxContainer2/HP,amount)

func set_strength(amount):
	set_stat($Panel/HBoxContainer/VBoxContainer2/Strength,amount)

func set_magic(amount):
	set_stat($Panel/HBoxContainer/VBoxContainer2/Magic,amount)

func set_skill(amount):
	set_stat($Panel/HBoxContainer/VBoxContainer2/Skill,amount)

func set_speed(amount):
	set_stat($Panel/HBoxContainer/VBoxContainer2/Speed,amount)

func set_luck(amount):
	set_stat($Panel/HBoxContainer/VBoxContainer2/Luck,amount)

func set_defense(amount):
	set_stat($Panel/HBoxContainer/VBoxContainer2/Defense,amount)

func set_magic_defense(amount):
	set_stat($Panel/HBoxContainer/VBoxContainer2/Magic_Defense,amount)


func set_select_button_text(state):
	if !state:
		$Panel/HBoxContainer/VBoxContainer/Select_Button.text = "SELECT"
	else:
		$Panel/HBoxContainer/VBoxContainer/Select_Button.text = "DESELECT"


func _on_select_button_pressed():
	if selected:
		#if the unit is not found in the selected party
		set_select_button_text(false)
		selected = false
	else:
		#if the unit was found
		set_select_button_text(true)
		selected = true
	unit_selected.emit(unit,selected)


func _on_inventory_button_pressed():
	var children = $Panel/HBoxContainer.get_children()
	var child_amount = children.size()
	if child_amount <= 2:
		var inventory : AttackActionInventory = inventory_scene.instantiate()
		var convoy = convoy_scene.instantiate()
		$Panel/HBoxContainer.add_child(convoy)
		$Panel/HBoxContainer.add_child(inventory)
		inventory.hide_equippable_item_info()
		inventory.set_unit(unit)
	else:
		close_menu()


func _on_dismiss_button_pressed():
	queue_free()
	unit_dismissed.emit(unit)


func _on_market_button_pressed():
	var shop = shop_scene.instantiate()
	var children = $Panel/HBoxContainer.get_children()
	var child_amount = children.size()
	if child_amount <= 2:
		$Panel/HBoxContainer.add_child(shop)
		#shop.connect("_on_shop_item_button_pressed",)
		
		shop.set_po_data(playerOverworldData)
		shop.set_control_node(control_node)
		print("Test")
	else:
		close_menu()

func close_menu():
	var children = $Panel/HBoxContainer.get_children()
	var child_amount = children.size()
	for i in child_amount:
		if i > 1:
			children[i].queue_free()

func set_po_data(po_data):
	playerOverworldData = po_data
