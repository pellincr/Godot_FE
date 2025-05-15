extends Control

class_name unitStats

signal  unit_selected(unit : Unit, selected: bool)
signal  unit_dismissed(unit : Unit)

var playerOverworldData = PlayerOverworldData.new()#ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)
@onready var selected = false
var unit = null


func _ready():
	if playerOverworldData.selected_party.find(unit) == -1:
		set_select_button_text(false)
		selected = false
	else:
		set_select_button_text(true)
		selected = true


func set_stat(label: Label, stat):
	var colon_index = label.text.find(":")
	label.text = label.text.substr(0,colon_index+1) + " " +str(stat)

func set_level(level):
	set_stat($Panel/VBoxContainer/Level,level)

func set_hp(amount):
	set_stat($Panel/VBoxContainer/HP,amount)

func set_strength(amount):
	set_stat($Panel/VBoxContainer/Strength,amount)

func set_magic(amount):
	set_stat($Panel/VBoxContainer/Magic,amount)

func set_skill(amount):
	set_stat($Panel/VBoxContainer/Skill,amount)

func set_speed(amount):
	set_stat($Panel/VBoxContainer/Speed,amount)

func set_luck(amount):
	set_stat($Panel/VBoxContainer/Luck,amount)

func set_defense(amount):
	set_stat($Panel/VBoxContainer/Defense,amount)

func set_magic_defense(amount):
	set_stat($Panel/VBoxContainer/Magic_Defense,amount)


func set_select_button_text(state):
	if !state:
		$Panel2/VBoxContainer/Select_Button.text = "SELECT"
	else:
		$Panel2/VBoxContainer/Select_Button.text = "DESELECT"


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
	var action_inventory = $AttackActionInventory
	action_inventory.visible = !action_inventory.visible
	action_inventory.unit = unit


func _on_dismiss_button_pressed():
	queue_free()
	unit_dismissed.emit(unit)
