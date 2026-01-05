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

@onready var weapons_panel: PanelContainer = $WeaponsPanel
@onready var weapons_label: Label = $WeaponsPanel/HBoxContainer/WeaponsLabel
@onready var weapons_percent: Label = $WeaponsPanel/HBoxContainer/WeaponsPercent
@onready var equpiment_panel: PanelContainer = $EqupimentPanel
@onready var equpiment_label: Label = $EqupimentPanel/HBoxContainer/EqupimentLabel
@onready var equpiment_percent: Label = $EqupimentPanel/HBoxContainer/EqupimentPercent
@onready var consumables_panel: PanelContainer = $ConsumablesPanel
@onready var consumable_label: Label = $ConsumablesPanel/HBoxContainer/ConsumableLabel
@onready var consumable_percent: Label = $ConsumablesPanel/HBoxContainer/ConsumablePercent


var playerOverworldData : PlayerOverworldData


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_bumper"):
		next_header_state()
		header_swapped.emit(current_state)
	if event.is_action_pressed("left_bumper"):
		previous_header_state()
		header_swapped.emit(current_state)

func set_po_data(po_data):
	playerOverworldData = po_data

enum ALMANAC_STATES{
	UNIT_TYPES,
	COMMANDER_TYPES,
	ARCHETYPES,
	WEAPONS,
	EQUIPMENT,
	CONSUMABLES
}

var current_state := ALMANAC_STATES.UNIT_TYPES

func set_percent_label(label,percent):
	label.text = str(percent) + "%"

func previous_header_state():
	match current_state:
		ALMANAC_STATES.UNIT_TYPES:
			current_state = ALMANAC_STATES.CONSUMABLES
			swap_themes(unit_types_panel,weapons_panel)
			swap_font_colors(unit_types_label,weapons_label)
		ALMANAC_STATES.COMMANDER_TYPES:
			current_state = ALMANAC_STATES.UNIT_TYPES
			swap_themes(commander_types_panel,unit_types_panel)
			swap_font_colors(commander_types_label,unit_types_label)
		ALMANAC_STATES.ARCHETYPES:
			current_state = ALMANAC_STATES.COMMANDER_TYPES
			swap_themes(archetypes_panel,commander_types_panel)
			swap_font_colors(archetypes_label,commander_types_label)
		ALMANAC_STATES.WEAPONS:
			current_state = ALMANAC_STATES.ARCHETYPES
			swap_themes(weapons_panel,archetypes_panel)
			swap_font_colors(weapons_label,archetypes_label)
		ALMANAC_STATES.EQUIPMENT:
			current_state = ALMANAC_STATES.WEAPONS
			swap_themes(equpiment_label,weapons_panel)
			swap_font_colors(equpiment_label,weapons_label)
		ALMANAC_STATES.CONSUMABLES:
			current_state = ALMANAC_STATES.EQUIPMENT
			swap_themes(consumables_panel,equpiment_panel)
			swap_font_colors(consumable_label,equpiment_label)

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
			current_state = ALMANAC_STATES.WEAPONS
			swap_themes(archetypes_panel, weapons_panel)
			swap_font_colors(archetypes_label,weapons_label)
		ALMANAC_STATES.WEAPONS:
			current_state = ALMANAC_STATES.EQUIPMENT
			swap_themes(weapons_panel,equpiment_panel)
			swap_font_colors(weapons_label,equpiment_label)
		ALMANAC_STATES.EQUIPMENT:
			current_state = ALMANAC_STATES.CONSUMABLES
			swap_themes(equpiment_panel,consumables_panel)
			swap_font_colors(equpiment_label,consumable_label)
		ALMANAC_STATES.CONSUMABLES:
			current_state = ALMANAC_STATES.UNIT_TYPES
			swap_themes(consumables_panel,unit_types_panel)
			swap_font_colors(consumable_label,unit_types_label)

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
	#set_percent_label(items_percent,playerOverworldData.unlock_manager.get_individual_unlocked_percentage(playerOverworldData.unlock_manager.items_unlocked))
