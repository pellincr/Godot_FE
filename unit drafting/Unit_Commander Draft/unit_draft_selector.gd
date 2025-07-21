extends Control

class_name unitDraftSelector

signal unit_selected(unit)

enum SELECTOR_STATE{
	OVERVIEW, STATS, GROWTHS
}



@onready var name_label = $Panel/MainVContainer/NameLabel
@onready var class_label = $Panel/MainVContainer/HBoxContainer/ClassLabel
@onready var icon = $Panel/Icon

@onready var selection_hovered = false
@onready var main_container = $Panel/MainVContainer
@onready var current_state = SELECTOR_STATE.OVERVIEW

var current_draft_state = Constants.DRAFT_STATE.COMMANDER

var unit: Unit = null

var possible_rarities = {
	"Common" : 60,
	"Uncommon" : 25,
	"Rare" : 10
}

const commander_overview_scene = preload("res://unit drafting/Unit_Commander Draft/commander_select_overview.tscn")
const unit_overview_scene = preload("res://unit drafting/Unit_Commander Draft/unit_select_overview.tscn")
const stat_view_scene = preload("res://unit drafting/Unit_Commander Draft/stat_view.tscn")
const growths_view_scene = preload("res://unit drafting/Unit_Commander Draft/growths_view.tscn")

var playerOverworldData : PlayerOverworldData


func _ready():
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	instantiate_unit_draft_selector()

func _process(delta):
	if Input.is_action_just_pressed("details") and selection_hovered:
		show_next_screen()
	if Input.is_action_just_pressed("ui_confirm") and selection_hovered:
		unit_selected.emit(unit)

func set_po_data(po_data):
	playerOverworldData = po_data


func set_name_label(name):
	name_label.text = name
	var rarity:UnitRarity = UnitTypeDatabase.unit_types.get(unit.unit_class_key).unit_rarity
	name_label.self_modulate = rarity.ui_color

func set_class_label(class_text):
	class_label.text = class_text

func set_icon(img):
	icon.texture = img

func show_next_screen():
	var last_child = main_container.get_children()[-1]
	last_child.queue_free()
	match current_state:
		SELECTOR_STATE.OVERVIEW:
			#When in the Overview State, Go to the Stats screen
			var stats_view = stat_view_scene.instantiate()
			main_container.add_child(stats_view)
			if current_draft_state == Constants.DRAFT_STATE.COMMANDER:
				stats_view.hide_difference_value_container()
				stats_view.hide_stat_grade()
				var growths_value_container = growths_view_scene.instantiate()
				stats_view.add_child_to_main_container(growths_value_container)
				growths_value_container.commander_visiblity_setting()
			current_state = SELECTOR_STATE.STATS
			stats_view.unit = unit
			stats_view.update_all()
		SELECTOR_STATE.STATS:
			if current_draft_state == Constants.DRAFT_STATE.COMMANDER:
				var overview_view = commander_overview_scene.instantiate()
				main_container.add_child(overview_view)
				current_state = SELECTOR_STATE.OVERVIEW
			elif current_draft_state == Constants.DRAFT_STATE.UNIT:
				var growths_view = growths_view_scene.instantiate()
				main_container.add_child(growths_view)
				current_state = SELECTOR_STATE.GROWTHS
		SELECTOR_STATE.GROWTHS:
			var overview_view = unit_overview_scene.instantiate()
			main_container.add_child(overview_view)
			current_state = SELECTOR_STATE.OVERVIEW
			


func _on_panel_mouse_entered():
	selection_hovered = true
	#var style_box: StyleBoxFlat = $Panel.get_theme_stylebox("panel")
	self.theme = preload("res://unit drafting/Unit_Commander Draft/draft_selector_thick_border.tres")
	print("Selection Hovered")


func _on_panel_mouse_exited():
	selection_hovered = false
	#var stylebox: StyleBoxFlat = $Panel.get_theme_stylebox("panel")
	self.theme = preload("res://unit drafting/Unit_Commander Draft/draft_selector_thin_border.tres")
	print("Selection Exited")

func instantiate_unit_draft_selector():
	var overview_scene = null
	if current_draft_state == Constants.DRAFT_STATE.COMMANDER:
		overview_scene = commander_overview_scene.instantiate()
	elif current_draft_state == Constants.DRAFT_STATE.UNIT:
		overview_scene = unit_overview_scene.instantiate()
	main_container.add_child(overview_scene)
	#create the unit to be drafted (will be different between commanders and units)
	randomize_unit()
	update_information()

func randomize_unit():
	var all_unit_classes = UnitTypeDatabase.unit_types.keys()
	var class_rarity: UnitRarity = RarityDatabase.rarities.get(get_random_rarity())
	var new_recruit_class = UnitTypeDatabase.unit_types.get(all_unit_classes.pick_random())
	if current_draft_state == Constants.DRAFT_STATE.UNIT:
		#get what the batch of recruits is supposed to be filtered by
		var unit_filter = playerOverworldData.archetype_allotments[0]
		#get the list of all classes that meets the filter criteria
		var filtered_unit_classes = get_units_by_class(all_unit_classes,unit_filter, class_rarity)
		if filtered_unit_classes.size() == 0:
			filtered_unit_classes = get_units_by_weapon(all_unit_classes,unit_filter, class_rarity)
		new_recruit_class = filtered_unit_classes.pick_random()
	while(new_recruit_class == null):
		new_recruit_class = UnitTypeDatabase.unit_types.get(all_unit_classes.pick_random())
	var new_unit_name = playerOverworldData.temp_name_list.pick_random()
	var iventory_array : Array[ItemDefinition]
	iventory_array.append(ItemDatabase.items["brass_knuckles"])
	var new_recruit = Unit.create_generic(new_recruit_class,iventory_array, new_unit_name, 2)
	unit = new_recruit

func get_random_rarity():
	var total_weight = 0
	for weight in possible_rarities.values():
		total_weight += weight
		
	var random_value = randi() % total_weight
	var current_weight = 0
	
	for rarity in possible_rarities.keys():
		current_weight += possible_rarities[rarity]
		if random_value < current_weight:
			return rarity
	return "Common"

func update_information():
	set_name_label(unit.unit_name)
	set_class_label(unit.unit_class_key)
	set_icon(unit.map_sprite)



#purpose: to return a list of units that can use the available weapon type
func get_units_by_weapon(given_unit_classes, weapon_type, rarity):
	var viable_units = []
	for i in given_unit_classes.size():
		var unit_class = UnitTypeDatabase.unit_types.get(given_unit_classes[i])
		if unit_class.usable_weapon_types.has(weapon_type) and unit_class.unit_rarity == rarity:
			viable_units.append(unit_class)
	return viable_units

#purpose: to return a list of units that can use the available class type
func get_units_by_class(given_unit_classes, class_type, rarity):
	var viable_units = []
	for i in given_unit_classes.size():
		var unit_class = UnitTypeDatabase.unit_types.get(given_unit_classes[i])
		if unit_class.class_type.has(class_type) and unit_class.unit_rarity == rarity:
			viable_units.append(unit_class)
	return viable_units
