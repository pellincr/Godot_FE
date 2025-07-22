extends Control

class_name unitDraftSelector

signal unit_selected(unit)

enum SELECTOR_STATE{
	OVERVIEW, STATS, GROWTHS
}



@onready var name_label = $Panel/MarginContainer/MainVContainer/NameLabel
@onready var class_label = $Panel/MarginContainer/MainVContainer/HBoxContainer/ClassLabel
@onready var icon = $Panel/Icon

@onready var selection_hovered = false
@onready var main_container = $Panel/MarginContainer/MainVContainer
@onready var current_state = SELECTOR_STATE.OVERVIEW

var current_draft_state = Constants.DRAFT_STATE.COMMANDER

var unit: Unit = null
var unit_stat_grade = ""
var unit_growth_grade = ""

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
	randomize_unit()
	update_information()
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
				growths_view.unit = unit
				growths_view.update_all()
				current_state = SELECTOR_STATE.GROWTHS
		SELECTOR_STATE.GROWTHS:
			var overview_view = unit_overview_scene.instantiate()
			main_container.add_child(overview_view)
			overview_view.set_stats_overview_label(unit_stat_grade)
			overview_view.set_growths_overview_label(unit_growth_grade)
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
		main_container.add_child(overview_scene)
	elif current_draft_state == Constants.DRAFT_STATE.UNIT:
		overview_scene = unit_overview_scene.instantiate()
		main_container.add_child(overview_scene)
		overview_scene.set_stats_overview_label(unit_stat_grade)
		overview_scene.set_growths_overview_label(unit_growth_grade)
	#create the unit to be drafted (will be different between commanders and units)
	

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
	randomize_unit_stats(new_recruit)#THIS WON"E BE DONE FOR COMMANDERS IN THE FUTURE
	randomize_unit_growths(new_recruit)#THIS WON"E BE DONE FOR COMMANDERS IN THE FUTURE
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


func randomize_unit_stats(unit):
	var health_rand = randi_range(unit.hp - 6, unit.hp + 6)
	var strength_rand = randi_range(unit.strength - 2, unit.strength + 2)
	var magic_rand = randi_range(unit.magic - 2, unit.magic + 2)
	var skill_rand = randi_range(unit.skill - 2, unit.skill + 2)
	var speed_rand = randi_range(unit.speed - 2, unit.speed + 2)
	var luck_rand = randi_range(unit.luck - 2, unit.luck + 2)
	var defense_rand = randi_range(unit.defense - 2, unit.defense + 2)
	var resistance_rand = randi_range(unit.magic_defense - 2, unit.magic_defense + 2)
	unit.hp = health_rand
	unit.strength = strength_rand
	unit.magic = magic_rand
	unit.skill = skill_rand
	unit.speed = speed_rand
	unit.luck = luck_rand
	unit.defense = defense_rand
	unit.magic_defense = resistance_rand

func randomize_unit_growths(unit):
	var health_rand = randi_range(unit.hp_growth - 0, unit.hp_growth + 0)
	var strength_rand = randi_range(unit.strength_growth - 0, unit.strength_growth + 0)
	var magic_rand = randi_range(unit.magic_growth - 0, unit.magic_growth + 0)
	var skill_rand = randi_range(unit.skill_growth - 0, unit.skill_growth + 0)
	var speed_rand = randi_range(unit.speed_growth - 0, unit.speed_growth + 0)
	var luck_rand = randi_range(unit.luck_growth - 0, unit.luck_growth + 0)
	var defense_rand = randi_range(unit.defense_growth - 0, unit.defense_growth + 0)
	var resistance_rand = randi_range(unit.magic_defense_growth - 0, unit.magic_defense_growth + 0)
	unit.hp_growth = health_rand
	unit.strength_growth = strength_rand
	unit.magic_growth = magic_rand
	unit.skill_growth = skill_rand
	unit.speed_growth = speed_rand
	unit.luck_growth = luck_rand
	unit.defense_growth = defense_rand
	unit.magic_defense_growth = resistance_rand


func update_information():
	set_name_label(unit.unit_name)
	set_class_label(UnitTypeDatabase.unit_types.get(unit.unit_class_key).unit_type_name)
	set_icon(unit.map_sprite)
	unit_growth_grade = get_growth_grade(get_unit_growth_difference_total())
	unit_stat_grade = get_stat_grade(get_unit_stat_difference_total())
	#var last_child = main_container.get_children()[-1]
	#last_child.queue_free()
	#instantiate_unit_draft_selector()
	#if last_child. is_class("UnitOverview"):
	#	last_child.set_stats_overview_label(unit_stat_grade)
	#	last_child.set_growths_overview_label(unit_growth_grade)

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


func get_unit_stat_difference_total():
	var hp_difference = unit.hp - UnitTypeDatabase.unit_types.get(unit.unit_class_key).hp
	var strength_difference = unit.strength - UnitTypeDatabase.unit_types.get(unit.unit_class_key).strength
	var magic_difference = unit.magic - UnitTypeDatabase.unit_types.get(unit.unit_class_key).magic
	var skill_difference = unit.skill - UnitTypeDatabase.unit_types.get(unit.unit_class_key).skill
	var speed_difference = unit.speed - UnitTypeDatabase.unit_types.get(unit.unit_class_key).speed
	var luck_difference = unit.luck - UnitTypeDatabase.unit_types.get(unit.unit_class_key).luck
	var defense_difference = unit.defense - UnitTypeDatabase.unit_types.get(unit.unit_class_key).defense
	var resistance_difference = unit.magic_defense - UnitTypeDatabase.unit_types.get(unit.unit_class_key).magic_defense
	var difference_total = hp_difference + strength_difference + magic_difference + skill_difference + speed_difference + luck_difference + defense_difference + resistance_difference
	return difference_total

func get_unit_growth_difference_total():
	var hp_difference = unit.hp_growth - UnitTypeDatabase.unit_types.get(unit.unit_class_key).hp_growth
	var strength_difference = unit.strength_growth - UnitTypeDatabase.unit_types.get(unit.unit_class_key).strength_growth
	var magic_difference = unit.magic_growth - UnitTypeDatabase.unit_types.get(unit.unit_class_key).magic_growth
	var skill_difference = unit.skill_growth - UnitTypeDatabase.unit_types.get(unit.unit_class_key).skill_growth
	var speed_difference = unit.speed_growth - UnitTypeDatabase.unit_types.get(unit.unit_class_key).speed_growth
	var luck_difference = unit.luck_growth - UnitTypeDatabase.unit_types.get(unit.unit_class_key).luck_growth
	var defense_difference = unit.defense_growth - UnitTypeDatabase.unit_types.get(unit.unit_class_key).defense_growth
	var resistance_difference = unit.magic_defense_growth - UnitTypeDatabase.unit_types.get(unit.unit_class_key).magic_defense_growth
	var difference_total = hp_difference + strength_difference + magic_difference + skill_difference + speed_difference + luck_difference + defense_difference + resistance_difference
	return difference_total

func get_stat_grade(total): 
	if total <= -18:
		return "F-"
	elif total <= -16:
		return "F"
	elif total <= -14:
		return "F+"
	elif total <= -11:
		return "D+"
	elif total <= -8:
		return "D"
	elif total <= -5:
		return "D+"
	elif total <= -3:
		return "C-"
	elif total <= 0:
		return "C"
	elif total <= 2:
		return "C+"
	elif total <= 5:
		return "B-"
	elif total <= 8:
		return "B"
	elif total <= 11:
		return "B+"
	elif total <= 14:
		return "A-"
	elif total <= 17:
		return "A"
	elif total <= 20:
		return "A+"
	else:
		return "ERROR"

func get_growth_grade(total): 
	if total <= -157:
		return "F-"
	elif total <= -133:
		return "F"
	elif total <= -109:
		return "F+"
	elif total <= -85:
		return "D+"
	elif total <= -61:
		return "D"
	elif total <= -37:
		return "D+"
	elif total <= -13:
		return "C-"
	elif total <= 12:
		return "C"
	elif total <= 36:
		return "C+"
	elif total <= 60:
		return "B-"
	elif total <= 84:
		return "B"
	elif total <= 108:
		return "B+"
	elif total <= 132:
		return "A-"
	elif total <= 156:
		return "A"
	elif total <= 180:
		return "A+"
	else:
		return "ERROR"
