extends PanelContainer

var playerOverworldData : PlayerOverworldData

@onready var archetype_name = $MarginContainer/ArchetypeName


var archetype : ArmyArchetypeDefinition

# Called when the node enters the scene tree for the first time.
func _ready():
	if archetype:
		if check_if_unlocked():
			update_by_archetype()
		else:
			update_set_locked()



func set_po_data(po_data):
	playerOverworldData = po_data


func _on_focus_entered():
	theme = preload("res://almanac/panel_container_focused.tres")


func _on_focus_exited():
	theme = preload("res://almanac/panel_container_not_focused.tres")

func set_archetype_name_label(name):
	archetype_name.text = name

func update_by_archetype():
	set_archetype_name_label(archetype.name)

## TODO
func check_if_unlocked():
	return true
	#var test = playerOverworldData.unlock_manager.archetypes_unlocked[archetype.db_key]
	#return test

func update_set_locked():
	set_archetype_name_label("???")
