extends HBoxContainer
class_name AlmanacScrollHeader

signal header_swapped(almanac_state)

@onready var unit_types_panel = $UnitTypesPanel
@onready var unit_types_label = $UnitTypesPanel/HBoxContainer/UnitTypesLabel
@onready var unit_types_percent = $UnitTypesPanel/HBoxContainer/UnitTypesPercent

@onready var commander_types_panel = $CommanderTypesPanel
@onready var commander_types_label = $CommanderTypesPanel/HBoxContainer/CommanderTypesLabel
@onready var commander_types_percent = $CommanderTypesPanel/HBoxContainer/CommanderTypesPercent

@onready var archetypes_panel = $ArchetypesPanel
@onready var archetypes_label = $ArchetypesPanel/HBoxContainer/ArchetypesLabel
@onready var archetypes_percent = $ArchetypesPanel/HBoxContainer/ArchetypesPercent

@onready var items_panel = $ItemsPanel
@onready var items_label = $ItemsPanel/HBoxContainer/ItemsLabel
@onready var items_percent = $ItemsPanel/HBoxContainer/ItemsPercent

var playerOverworldData : PlayerOverworldData


func _process(delta):
	if Input.is_action_just_pressed("right_bumper"):
		next_header_state()
		header_swapped.emit(current_state)
	if Input.is_action_just_pressed("left_bumper"):
		previous_header_state()
		header_swapped.emit(current_state)

func set_po_data(po_data):
	playerOverworldData = po_data

enum ALMANAC_STATES{
	UNIT_TYPES,
	COMMANDER_TYPES,
	ARCHETYPES,
	ITEMS
}

var current_state := ALMANAC_STATES.UNIT_TYPES

func set_percent_label(label,percent):
	label.text = str(percent) + "%"

func previous_header_state():
	match current_state:
		ALMANAC_STATES.UNIT_TYPES:
			current_state = ALMANAC_STATES.ITEMS
			swap_themes(unit_types_panel,items_panel)
			swap_font_colors(unit_types_label,items_label)
		ALMANAC_STATES.COMMANDER_TYPES:
			current_state = ALMANAC_STATES.UNIT_TYPES
			swap_themes(commander_types_panel,unit_types_panel)
			swap_font_colors(commander_types_label,unit_types_label)
		ALMANAC_STATES.ARCHETYPES:
			current_state = ALMANAC_STATES.COMMANDER_TYPES
			swap_themes(archetypes_panel,commander_types_panel)
			swap_font_colors(archetypes_label,commander_types_label)
		ALMANAC_STATES.ITEMS:
			current_state = ALMANAC_STATES.ARCHETYPES
			swap_themes(items_panel,archetypes_panel)
			swap_font_colors(items_label,archetypes_label)

func next_header_state():
	match current_state:
		ALMANAC_STATES.UNIT_TYPES:
			current_state = ALMANAC_STATES.COMMANDER_TYPES
			swap_themes(unit_types_panel,commander_types_panel)
			swap_font_colors(unit_types_label,commander_types_label)
		ALMANAC_STATES.COMMANDER_TYPES:
			current_state = ALMANAC_STATES.ARCHETYPES
			swap_themes(commander_types_panel,archetypes_panel)
			swap_font_colors(archetypes_label,commander_types_label)
		ALMANAC_STATES.ARCHETYPES:
			current_state = ALMANAC_STATES.ITEMS
			swap_themes(archetypes_panel,items_panel)
			swap_font_colors(archetypes_label,items_label)
		ALMANAC_STATES.ITEMS:
			current_state = ALMANAC_STATES.UNIT_TYPES
			swap_themes(items_panel,unit_types_panel)
			swap_font_colors(items_label,unit_types_label)

func swap_themes(panel1,panel2):
	var temp_theme = panel1.theme
	panel1.theme = panel2.theme
	panel2.theme = temp_theme

func swap_font_colors(label1:Label,label2:Label):
	var temp_color = label1.self_modulate
	label1.self_modulate = label2.self_modulate
	label2.self_modulate = temp_color

func update_all_percents():
	set_percent_label(unit_types_percent,playerOverworldData.unlock_manager.get_individual_unlocked_percentage(playerOverworldData.unlock_manager.unit_types_unlocked))
	set_percent_label(commander_types_percent,playerOverworldData.unlock_manager.get_individual_unlocked_percentage(playerOverworldData.unlock_manager.commander_types_unlocked))
	set_percent_label(archetypes_percent,playerOverworldData.unlock_manager.get_individual_unlocked_percentage(playerOverworldData.unlock_manager.archetypes_unlocked))
	set_percent_label(items_percent,playerOverworldData.unlock_manager.get_individual_unlocked_percentage(playerOverworldData.unlock_manager.items_unlocked))
