extends HBoxContainer

@onready var main_scroll_container = $MainContainer/DetailedViewSubContainer/ScrollContainer/MainScrollContainer
@onready var unit_type_header = $MainContainer/UnitTypeHeader

@onready var main_container = $MainContainer

@onready var detailed_view_sub_container = $MainContainer/DetailedViewSubContainer

const unit_type_panel_container_scene = preload("res://unit_type_almanac/unit_type_panel_container.tscn")
const unit_type_almanac_detailed_view_scene = preload("res://unit_type_almanac/unit_type_almanac_detailed_view.tscn")

enum UNIT_TYPE {
	UNIT, COMMANDER
}

var current_type = UNIT_TYPE.UNIT

func _ready():
	fill_main_scroll_container_unit_type()

func clear_main_scroll_container():
	var children = main_scroll_container.get_children()
	for child in children:
		child.queue_free()

func fill_main_scroll_container_unit_type():
	var unit_type_keys = UnitTypeDatabase.unit_types.keys()
	for unit_type_key in unit_type_keys:
		var unit_type = UnitTypeDatabase.unit_types[unit_type_key]
		var unit_type_panel_container = unit_type_panel_container_scene.instantiate()
		unit_type_panel_container.focus_entered.connect(_on_unit_type_panel_focued.bind(unit_type))
		unit_type_panel_container.unit_type = unit_type
		main_scroll_container.add_child(unit_type_panel_container)

func fill_main_scroll_container_commander_type():
	var commander_type_keys = UnitTypeDatabase.commander_types.keys()
	for commander_type_key in commander_type_keys:
		var commander_type = UnitTypeDatabase.commander_types[commander_type_key]
		var unit_type_panel_container = unit_type_panel_container_scene.instantiate()
		unit_type_panel_container.unit_type = commander_type
		unit_type_panel_container.focus_entered.connect(_on_unit_type_panel_focued.bind(commander_type))
		main_scroll_container.add_child(unit_type_panel_container)

func clear_sub_children():
	var children = detailed_view_sub_container.get_children()
	for child_index in children.size():
		if child_index == 0:
			pass
		else:
			children[child_index].queue_free()

func _on_unit_type_header_header_swapped():
	clear_main_scroll_container()
	match current_type:
		UNIT_TYPE.UNIT:
			current_type = UNIT_TYPE.COMMANDER
			fill_main_scroll_container_commander_type()
		UNIT_TYPE.COMMANDER:
			current_type = UNIT_TYPE.UNIT
			fill_main_scroll_container_unit_type()

func _on_unit_type_panel_focued(unit_type):
	clear_sub_children()
	var unit_type_almanac_detailed_view = unit_type_almanac_detailed_view_scene.instantiate()
	unit_type_almanac_detailed_view.unit_type = unit_type
	detailed_view_sub_container.add_child(unit_type_almanac_detailed_view)
	
