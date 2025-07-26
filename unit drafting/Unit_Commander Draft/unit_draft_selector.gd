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
	var rarity:UnitRarity = UnitTypeDatabase.unit_types.get(unit.unit_type_key).unit_rarity
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
				growths_value_container.unit = unit
				growths_value_container.update_all()
				growths_value_container.commander_visiblity_setting()
			current_state = SELECTOR_STATE.STATS
			stats_view.unit = unit
			stats_view.update_all()
		SELECTOR_STATE.STATS:
			if current_draft_state == Constants.DRAFT_STATE.COMMANDER:
				var overview_view = commander_overview_scene.instantiate()
				main_container.add_child(overview_view)
				overview_view.set_icon_visibility(unit)
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
			overview_view.set_icon_visibility(unit)
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
		overview_scene.set_icon_visibility(unit)
	elif current_draft_state == Constants.DRAFT_STATE.UNIT:
		overview_scene = unit_overview_scene.instantiate()
		main_container.add_child(overview_scene)
		overview_scene.set_stats_overview_label(unit_stat_grade)
		overview_scene.set_growths_overview_label(unit_growth_grade)
		overview_scene.set_icon_visibility(unit)
	#create the unit to be drafted (will be different between commanders and units)
	

func randomize_unit():
	var all_unit_classes = UnitTypeDatabase.unit_types.keys()
	var class_rarity: UnitRarity = RarityDatabase.rarities.get(get_random_rarity())
	var new_recruit_class = all_unit_classes.pick_random()
	if current_draft_state == Constants.DRAFT_STATE.UNIT:
		#get what the batch of recruits is supposed to be filtered by
		var current_archetype_pick = playerOverworldData.archetype_allotments[0]
		var filtered_unit_classes = filter_classes_by_archetype_pick(all_unit_classes, current_archetype_pick, class_rarity)
		new_recruit_class = filtered_unit_classes.pick_random()
	#while(new_recruit_class == null):
	#	new_recruit_class = all_unit_classes.pick_random()
	var new_unit_name = playerOverworldData.temp_name_list.pick_random()
	var inventory_array : Array[ItemDefinition] = set_starting_inventory(new_recruit_class)
	var unit_character = UnitCharacter.new()
	unit_character.name = new_unit_name
	#new_recruit_class = "axe_armor"#TO BE REMOVED 
	randomize_unit_stats(unit_character, new_recruit_class)#THIS WON"E BE DONE FOR COMMANDERS IN THE FUTURE
	randomize_unit_growths(unit_character, new_recruit_class)#THIS WON"E BE DONE FOR COMMANDERS IN THE FUTURE
	var new_recruit = Unit.create_unit_unit_character(new_recruit_class,unit_character, inventory_array) #create_generic(new_recruit_class,iventory_array, new_unit_name, 2)
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


func randomize_unit_stats(unit_character, unit_type_key):
	var stats = UnitStat.new()
	var deviation = 1.75
	var health_rand = clampi(randfn( 0, 3), - UnitTypeDatabase.unit_types[unit_type_key].base_stats.hp, 10) 
	var strength_rand = clampi(randfn( 0, deviation), - UnitTypeDatabase.unit_types[unit_type_key].base_stats.strength, 4) 
	var magic_rand = clampi(randfn( 0, deviation), - UnitTypeDatabase.unit_types[unit_type_key].base_stats.magic, 4) 
	var skill_rand = clampi(randfn( 0, deviation), - UnitTypeDatabase.unit_types[unit_type_key].base_stats.skill, 4) 
	var speed_rand = clampi(randfn( 0, deviation), - UnitTypeDatabase.unit_types[unit_type_key].base_stats.speed, 4) 
	var luck_rand = clampi(randfn( 0, deviation), - UnitTypeDatabase.unit_types[unit_type_key].base_stats.luck, 4) 
	var defense_rand = clampi(randfn( 0, deviation), - UnitTypeDatabase.unit_types[unit_type_key].base_stats.defense, 4) 
	var resistance_rand = clampi(randfn( 0, deviation), - UnitTypeDatabase.unit_types[unit_type_key].base_stats.resistance, 4) 
	stats.hp = health_rand
	stats.strength = strength_rand
	stats.magic = magic_rand
	stats.skill = skill_rand
	stats.speed = speed_rand
	stats.luck = luck_rand
	stats.defense = defense_rand
	stats.resistance = resistance_rand
	unit_character.stats = stats

func randomize_unit_growths(unit_character, unit_type_key):
	var growths = UnitStat.new()
	var health_rand = clampi(randfn( 0, 10), - UnitTypeDatabase.unit_types[unit_type_key].growth_stats.hp, 40) 
	var strength_rand = clampi(randfn( 0, 10), - UnitTypeDatabase.unit_types[unit_type_key].growth_stats.strength, 20) 
	var magic_rand = clampi(randfn( 0, 10), - UnitTypeDatabase.unit_types[unit_type_key].growth_stats.magic, 20) 
	var skill_rand = clampi(randfn( 0, 10), - UnitTypeDatabase.unit_types[unit_type_key].growth_stats.skill, 20) 
	var speed_rand = clampi(randfn( 0, 10), - UnitTypeDatabase.unit_types[unit_type_key].growth_stats.speed, 20) 
	var luck_rand = clampi(randfn( 0, 10), - UnitTypeDatabase.unit_types[unit_type_key].growth_stats.luck, 20) 
	var defense_rand = clampi(randfn( 0, 10), - UnitTypeDatabase.unit_types[unit_type_key].growth_stats.defense, 20) 
	var resistance_rand = clampi(randfn( 0, 10), - UnitTypeDatabase.unit_types[unit_type_key].growth_stats.resistance, 20) 
	growths.hp = health_rand
	growths.strength = strength_rand
	growths.magic = magic_rand
	growths.skill = skill_rand
	growths.speed = speed_rand
	growths.luck = luck_rand
	growths.defense = defense_rand
	growths.resistance = resistance_rand
	unit_character.growths = growths


func set_starting_inventory(unit_class) -> Array[ItemDefinition]: 
	var inventory: Array[ItemDefinition]
	var unit_type: UnitTypeDefinition = UnitTypeDatabase.unit_types.get(unit_class)
	var weapon_types = unit_type.usable_weapon_types
	if weapon_types.has(ItemConstants.WEAPON_TYPE.SWORD):
		inventory.append(ItemDatabase.items["iron_sword"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.AXE):
		inventory.append(ItemDatabase.items["iron_axe"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.LANCE):
		inventory.append(ItemDatabase.items["iron_lance"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.BOW):
		inventory.append(ItemDatabase.items["iron_bow"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.FIST):
		inventory.append(ItemDatabase.items["brass_knuckles"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.STAFF):
		inventory.append(ItemDatabase.items["heal_staff"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.DARK):
		inventory.append(ItemDatabase.items["dark_pulse"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.LIGHT):
		inventory.append(ItemDatabase.items["smite"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.NATURE):
		inventory.append(ItemDatabase.items["fire_spell"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.ANIMAL):
		inventory.append(ItemDatabase.items[""])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.MONSTER):
		inventory.append(ItemDatabase.items[""])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.SHIELD):
		inventory.append(ItemDatabase.items["iron_shield"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.DAGGER):
		inventory.append(ItemDatabase.items["iron_dagger"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.BANNER):
		inventory.append(ItemDatabase.items[""])
	if inventory.size() > 4:
		return inventory.slice(0,3)
	return inventory



func update_information():
	set_name_label(unit.name)
	set_class_label(UnitTypeDatabase.unit_types.get(unit.unit_type_key).unit_type_name)
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
		var unit_class: UnitTypeDefinition = UnitTypeDatabase.unit_types.get(given_unit_classes[i])
		if unit_class.usable_weapon_types.has(weapon_type) and unit_class.unit_rarity == rarity:
			viable_units.append(unit_class.unit_type_name)
	return viable_units

#purpose: to return a list of units that can use the available class type
func get_units_by_class(given_unit_classes, unit_trait, rarity):
	var viable_units = []
	for i in given_unit_classes.size():
		var unit_type: UnitTypeDefinition = UnitTypeDatabase.unit_types.get(given_unit_classes[i])
		if unit_type.traits.has(unit_trait) and unit_type.unit_rarity == rarity:
			viable_units.append(unit_type.unit_type_name)
	return viable_units


func filter_classes_by_archetype_pick(class_list, unit_archetype_pick, class_rarity):
	var archetype_pick_factions = unit_archetype_pick.factions
	var archetype_pick_traits = unit_archetype_pick.traits
	var archetype_pick_rarity = unit_archetype_pick.rarity
	var archetype_pick_weapon_types = unit_archetype_pick.weapon_types
	var archetype_pick_unit_type = unit_archetype_pick.unit_type
	#fill in factions list
	var faction_filtered_list = filter_by_faction(class_list, archetype_pick_factions, class_rarity)
	#fill in traits list
	var traits_filtered_list = filter_by_trait(class_list, archetype_pick_traits, class_rarity)
	#fill in rarity list
	var rarity_filtered_list = filter_by_rarity(class_list, archetype_pick_rarity, class_rarity)
	#fill in weapon type list
	var weapon_type_filtered_list = filter_by_weapon_type(class_list, archetype_pick_weapon_types, class_rarity)
	#fill in unit type list
	var unit_type_filtered_list = filter_by_unit_type(class_list, archetype_pick_unit_type, class_rarity)
	var combo1 = get_classes_in_common(faction_filtered_list,traits_filtered_list)
	var combo2 = get_classes_in_common(rarity_filtered_list,combo1)
	var combo3 = get_classes_in_common(weapon_type_filtered_list,combo2)
	var combo4 = get_classes_in_common(unit_type_filtered_list,combo3)
	return combo4

func get_classes_in_common(class_list_1, class_list_2):
	var accum = []
	for given_class in class_list_1:
		if class_list_2.has(given_class):
			accum.append(given_class)
	return accum

func filter_by_faction(class_list, archetype_pick_factions, class_rarity):
	var accum = []
	if archetype_pick_factions.size() > 0:
		#If there is a reason to filter by faction
			for faction in archetype_pick_factions:
				for given_class in class_list:
					var unit_type: UnitTypeDefinition = UnitTypeDatabase.unit_types.get(given_class)
					if unit_type.faction.has(faction):
						accum.append(given_class)
	else:
		return class_list
	return accum

func filter_by_trait(class_list, archetype_pick_traits, class_rarity):
	var accum = []
	if archetype_pick_traits.size() > 0:
		#If there is a reason to filter by faction
			for faction in archetype_pick_traits:
				for given_class in class_list:
					var unit_type: UnitTypeDefinition = UnitTypeDatabase.unit_types.get(given_class)
					if unit_type.traits.has(faction):
						accum.append(given_class)
	else:
		return class_list
	return accum

func filter_by_rarity(class_list, archetype_pick_rarity, class_rarity):
	var accum = []
	if archetype_pick_rarity != null:
		#If there is a reason to filter by faction
		for given_class in class_list:
					var unit_type: UnitTypeDefinition = UnitTypeDatabase.unit_types.get(given_class)
					if archetype_pick_rarity == unit_type.unit_rarity:
						accum.append(given_class)
	else:
		return class_list
	return accum

func filter_by_weapon_type(class_list, archetype_pick_weapon_types, class_rarity):
	var accum = []
	if archetype_pick_weapon_types.size() > 0:
		#If there is a reason to filter by faction
			for weapon_type in archetype_pick_weapon_types:
				for given_class in class_list:
					var unit_type: UnitTypeDefinition = UnitTypeDatabase.unit_types.get(given_class)
					if unit_type.usable_weapon_types.has(weapon_type):
						accum.append(given_class)
	else:
		return class_list
	return accum

func filter_by_unit_type(class_list, archetype_pick_unit_type, class_rarity):
	var accum = []
	if archetype_pick_unit_type != "":
		#If there is a reason to filter by faction
		for given_class in class_list:
					if archetype_pick_unit_type == given_class:
						accum.append(given_class)
	else:
		return class_list
	return accum







func get_unit_stat_difference_total():
	var difference_total = unit.unit_character.stats.hp + unit.unit_character.stats.strength + unit.unit_character.stats.magic + unit.unit_character.stats.skill + unit.unit_character.stats.speed + unit.unit_character.stats.luck + unit.unit_character.stats.defense + unit.unit_character.stats.resistance
	return difference_total

func get_unit_growth_difference_total():
	var difference_total = unit.unit_character.growths.hp + unit.unit_character.growths.strength + unit.unit_character.growths.magic + unit.unit_character.growths.skill + unit.unit_character.growths.speed + unit.unit_character.growths.luck + unit.unit_character.growths.defense + unit.unit_character.growths.resistance
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
