extends PanelContainer

var playerOverworldData : PlayerOverworldData

@onready var unit_type_label = $MarginContainer/HBoxContainer/UnitTypeLabel
@onready var unit_type_icon = $MarginContainer/HBoxContainer/UnitTypeIcon

var unit_type : UnitTypeDefinition


# Called when the node enters the scene tree for the first time.
func _ready():
	if unit_type:
		if check_if_unlocked():
			update_by_unit_type()
		else:
			update_set_locked()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if has_focus():
		theme = preload("res://almanac/panel_container_focused.tres")
	else:
		theme = preload("res://almanac/panel_container_not_focused.tres")


func set_po_data(po_data):
	playerOverworldData = po_data

func set_unit_type_label(text):
	unit_type_label.text = text

func set_unit_type_icon(texture):
	unit_type_icon.texture = texture
	


func update_by_unit_type():
	set_unit_type_label(unit_type.unit_type_name)
	set_unit_type_icon(unit_type.icon)

func update_set_locked():
	var hidden_unit_icon = preload("res://resources/sprites/icons/UnitArchetype.png")
	set_unit_type_label("???")
	set_unit_type_icon(hidden_unit_icon)

func _on_mouse_entered():
	grab_focus()

##TODO FIX THIS
func check_if_unlocked():
	if UnitTypeDatabase.get_commander_definition(unit_type.db_key):
		#var test = playerOverworldData.unlock_manager.commander_types_unlocked[unit_type.db_key]
		#return test
		return true
	elif UnitTypeDatabase.get_unit_definition(unit_type.db_key):
		#var test = playerOverworldData.unlock_manager.unit_types_unlocked.get(unit_type.db_key)
		#return test
		return true
