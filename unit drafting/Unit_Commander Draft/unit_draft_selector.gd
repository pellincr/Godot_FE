extends Control

class_name unitDraftSelector

signal unit_selected(unit)

enum SELECTOR_STATE{
	OVERVIEW, STATS, GROWTHS
}

var menu_hover_effect = preload("res://resources/sounds/ui/menu_cursor.wav")
var menu_enter_effect = preload("res://resources/sounds/ui/menu_confirm.wav")

@onready var name_label = $Panel/MarginContainer/MainVContainer/NameLabel
@onready var class_label = $Panel/MarginContainer/MainVContainer/HBoxContainer/ClassLabel
@onready var icon = $Panel/Icon

@onready var selection_hovered = false
@onready var main_container = $Panel/MarginContainer/MainVContainer
@onready var current_state = SELECTOR_STATE.OVERVIEW


var current_draft_state = Constants.DRAFT_STATE.COMMANDER

var unit = null
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
const weapon_draft_scene = preload("res://unit drafting/Weapon Draft/weapon_draft_selector.tscn")

var playerOverworldData : PlayerOverworldData

var randomized_commander_types = []

func _ready():
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	randomize_selection()
	update_information()
	instantiate_unit_draft_selector()
	
	

func _on_gui_input(event):
	if event.is_action_pressed("ui_confirm") and has_focus():
		$AudioStreamPlayer.stream = menu_enter_effect
		$AudioStreamPlayer.play()
		unit_selected.emit(unit)
	if event.is_action_pressed("right_bumper") and has_focus():
		show_next_screen()
	if event.is_action_pressed("left_bumper") and has_focus():
		show_previous_screen()

func set_po_data(po_data):
	playerOverworldData = po_data


func set_name_label(name):
	name_label.text = name
	var rarity
	if unit is Unit:
		rarity = UnitTypeDatabase.get_definition(unit.unit_type_key).unit_rarity
	elif unit is ItemDefinition:
		rarity= unit.rarity
		
	if rarity:
		name_label.self_modulate = rarity.ui_color

func set_rarity_shadow_hue(rarity):
	var test :StyleBoxFlat = theme.get_stylebox("panel","Panel")
	test.set_shadow_color(rarity.ui_color)

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

func show_previous_screen():
	var last_child = main_container.get_children()[-1]
	last_child.queue_free()
	match current_state:
		SELECTOR_STATE.OVERVIEW:
			#If Commander, goes from overview, to stats
			if current_draft_state == Constants.DRAFT_STATE.COMMANDER:
				var stats_view = stat_view_scene.instantiate()
				main_container.add_child(stats_view)
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
			#if unit, go from overview to growths
			elif current_draft_state == Constants.DRAFT_STATE.UNIT:
				var growths_view = growths_view_scene.instantiate()
				main_container.add_child(growths_view)
				growths_view.unit = unit
				growths_view.update_all()
				current_state = SELECTOR_STATE.GROWTHS
		SELECTOR_STATE.STATS:
			#When in stats, go back to the unit or commander overview scene
			if current_draft_state == Constants.DRAFT_STATE.COMMANDER:
				var overview_view = commander_overview_scene.instantiate()
				main_container.add_child(overview_view)
				overview_view.set_icon_visibility(unit)
				current_state = SELECTOR_STATE.OVERVIEW
			else:
				var overview_view = unit_overview_scene.instantiate()
				main_container.add_child(overview_view)
				overview_view.set_stats_overview_label(unit_stat_grade)
				overview_view.set_growths_overview_label(unit_growth_grade)
				overview_view.set_icon_visibility(unit)
				current_state = SELECTOR_STATE.OVERVIEW
		SELECTOR_STATE.GROWTHS:
			#when in growths, go to stats
			var stats_view = stat_view_scene.instantiate()
			main_container.add_child(stats_view)
			current_state = SELECTOR_STATE.STATS
			stats_view.unit = unit
			stats_view.update_all()


func _on_panel_mouse_entered():
	grab_focus()


func _on_focus_entered():
	self.theme = preload("res://unit drafting/Unit_Commander Draft/draft_selector_thick_border.tres")
	$AudioStreamPlayer.stream = menu_hover_effect
	$AudioStreamPlayer.play()
	print("Selection Focused")
	if unit is Unit:
		var unit_type : UnitTypeDefinition = UnitTypeDatabase.get_definition(unit.unit_type_key)
		set_rarity_shadow_hue(unit_type.unit_rarity)
	elif unit is ItemDefinition:
		set_rarity_shadow_hue(unit.rarity)



func _on_focus_exited():
	self.theme = preload("res://unit drafting/Unit_Commander Draft/draft_selector_thin_border.tres")


func instantiate_unit_draft_selector():
	if unit is Unit:
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
	elif unit is WeaponDefinition:
		var weapon_draft = weapon_draft_scene.instantiate()
		main_container.add_child(weapon_draft)
		weapon_draft.weapon = unit
		weapon_draft.update_all()
	#create the unit to be drafted (will be different between commanders and units)
	

func randomize_selection():
	var class_rarity: UnitRarity = RarityDatabase.unit_rarities.get(get_random_rarity())
	var weapon_rarity = null
	var new_randomized_pick
	if current_draft_state == Constants.DRAFT_STATE.UNIT:
		#get what the batch of recruits is supposed to be filtered by
		var current_archetype_pick = playerOverworldData.archetype_allotments[0]
		if current_archetype_pick is armyArchetypePickWeaponDefinition:
			new_randomized_pick = randomize_weapon(current_archetype_pick, weapon_rarity)
			unit = ItemDatabase.items.get(new_randomized_pick.pick_random())
		else:
			var filtered_unit_classes = filter_classes_by_archetype_pick(current_archetype_pick, class_rarity)
			new_randomized_pick = filtered_unit_classes.pick_random()
			var new_unit_name = playerOverworldData.temp_name_list.pick_random()
			var inventory_array : Array[ItemDefinition] = set_starting_inventory(new_randomized_pick)
			var unit_character = UnitCharacter.new()
			unit_character.name = new_unit_name
			randomize_unit_stats(unit_character, new_randomized_pick)#THIS WON"E BE DONE FOR COMMANDERS IN THE FUTURE
			randomize_unit_growths(unit_character, new_randomized_pick)#THIS WON"E BE DONE FOR COMMANDERS IN THE FUTURE
			var new_recruit = Unit.create_unit_unit_character(new_randomized_pick,unit_character, inventory_array) #create_generic(new_recruit_class,iventory_array, new_unit_name, 2)
			unit = new_recruit
	else:
		#For Commander Drafting
		var all_commander_classes = UnitTypeDatabase.commander_types.keys()
		var unlocked_commander_classes = filter_all_commander_by_unlocked(all_commander_classes)
		var available_commander_classes = filter_commander_by_already_generated(unlocked_commander_classes)
		new_randomized_pick = available_commander_classes.pick_random()
		var new_unit_name = playerOverworldData.temp_name_list.pick_random()
		var inventory_array : Array[ItemDefinition] = set_starting_inventory(new_randomized_pick)
		var unit_character = UnitCharacter.new()
		unit_character.name = new_unit_name
		 
		#set_base_unit_stats(unit_character, new_randomized_pick)#THIS WON"E BE DONE FOR COMMANDERS IN THE FUTURE
		#set_base_unit_growths(unit_character, new_randomized_pick)#THIS WON"E BE DONE FOR COMMANDERS IN THE FUTURE
		var stats = UnitStat.new()
		var growths = UnitStat.new()
		unit_character.stats = stats
		unit_character.growths = growths
		
		var new_recruit = Unit.create_unit_unit_character(new_randomized_pick,unit_character, inventory_array) #create_generic(new_recruit_class,iventory_array, new_unit_name, 2)
		unit = new_recruit
		




func get_random_rarity():
	var total_weight : int
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
	var unit_type : UnitTypeDefinition
	unit_type = UnitTypeDatabase.get_definition(unit_type_key)
	var health_rand = clampi(randfn( 0, 3), - unit_type.base_stats.hp, 10) 
	var strength_rand = clampi(randfn( 0, deviation), - unit_type.base_stats.strength, 4) 
	var magic_rand = clampi(randfn( 0, deviation), - unit_type.base_stats.magic, 4) 
	var skill_rand = clampi(randfn( 0, deviation), - unit_type.base_stats.skill, 4) 
	var speed_rand = clampi(randfn( 0, deviation), - unit_type.base_stats.speed, 4) 
	var luck_rand = clampi(randfn( 0, deviation), - unit_type.base_stats.luck, 4) 
	var defense_rand = clampi(randfn( 0, deviation), - unit_type.base_stats.defense, 4) 
	var resistance_rand = clampi(randfn( 0, deviation), - unit_type.base_stats.resistance, 4) 
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
	var unit_type : UnitTypeDefinition
	unit_type = UnitTypeDatabase.get_definition(unit_type_key)
	var health_rand = clampi(randfn( 0, 10), - unit_type.growth_stats.hp, 40) 
	var strength_rand = clampi(randfn( 0, 10), - unit_type.growth_stats.strength, 20) 
	var magic_rand = clampi(randfn( 0, 10), - unit_type.growth_stats.magic, 20) 
	var skill_rand = clampi(randfn( 0, 10), - unit_type.growth_stats.skill, 20) 
	var speed_rand = clampi(randfn( 0, 10), - unit_type.growth_stats.speed, 20) 
	var luck_rand = clampi(randfn( 0, 10), - unit_type.growth_stats.luck, 20) 
	var defense_rand = clampi(randfn( 0, 10), - unit_type.growth_stats.defense, 20) 
	var resistance_rand = clampi(randfn( 0, 10), - unit_type.growth_stats.resistance, 20) 
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
	var unit_type: UnitTypeDefinition = UnitTypeDatabase.get_definition(unit_class)
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
		inventory.append(ItemDatabase.items["evil_eye"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.LIGHT):
		inventory.append(ItemDatabase.items["smite"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.NATURE):
		inventory.append(ItemDatabase.items["fire_spell"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.ANIMAL):
		inventory.append(ItemDatabase.items["iron_sword"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.MONSTER):
		inventory.append(ItemDatabase.items["iron_sword"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.SHIELD):
		inventory.append(ItemDatabase.items["iron_shield"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.DAGGER):
		inventory.append(ItemDatabase.items["iron_dagger"])
	if weapon_types.has(ItemConstants.WEAPON_TYPE.BANNER):
		inventory.append(ItemDatabase.items["iron_sword"])
	if inventory.size() > 4:
		return inventory.slice(0,3)
	return inventory



func update_information():
	if unit is Unit:
		set_name_label(unit.name)
		var unit_type : UnitTypeDefinition = UnitTypeDatabase.get_definition(unit.unit_type_key)
		set_rarity_shadow_hue(unit_type.unit_rarity)
		var weapon_types = unit_type.usable_weapon_types
		set_class_label(unit_type.unit_type_name)
		set_icon(unit.map_sprite)
		unit_growth_grade = get_growth_grade(get_unit_growth_difference_total())
		unit_stat_grade = get_stat_grade(get_unit_stat_difference_total())
	elif unit is WeaponDefinition:
		set_name_label(unit.name)
		set_icon(unit.icon)
		set_class_label("")
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

func filter_all_commander_by_unlocked(commander_type_keys: Array) -> Array:
	var accum = []
	for commander_type_key in commander_type_keys:
		if playerOverworldData.unlock_manager.commander_types_unlocked.keys().has(commander_type_key):
			if playerOverworldData.unlock_manager.commander_types_unlocked[commander_type_key]:
				accum.append(commander_type_key)
	return accum

func filter_all_classes_by_unlocked(unit_type_keys: Array) -> Array:
	var accum = []
	for unit_type_key in unit_type_keys:
		if playerOverworldData.unlock_manager.unit_types_unlocked.keys().has(unit_type_key):
			if playerOverworldData.unlock_manager.unit_types_unlocked[unit_type_key]:
				accum.append(unit_type_key)
	return accum

func filter_all_items_by_unlocked(item_keys: Array) -> Array:
	var accum = []
	for item_key in item_keys:
		if playerOverworldData.unlock_manager.items_unlocked.keys().has(item_key):
			if playerOverworldData.unlock_manager.items_unlocked[item_key]:
				accum.append(item_key)
	return accum

func filter_classes_by_archetype_pick(unit_archetype_pick, class_rarity):
	#var class_list = UnitTypeDatabase.unit_types.keys()
	var class_list = filter_all_classes_by_unlocked(UnitTypeDatabase.unit_types.keys())
	var archetype_pick_factions = unit_archetype_pick.factions
	var archetype_pick_traits = unit_archetype_pick.traits
	var archetype_pick_rarity = unit_archetype_pick.rarity
	var archetype_pick_weapon_types = unit_archetype_pick.weapon_types
	var archetype_pick_unit_type = unit_archetype_pick.unit_type
	#fill in factions list
	var faction_filtered_list = filter_classes_by_faction(class_list, archetype_pick_factions, class_rarity)
	#fill in traits list
	var traits_filtered_list = filter_classes_by_trait(class_list, archetype_pick_traits, class_rarity)
	#fill in rarity list
	var rarity_filtered_list = filter_classes_by_rarity(class_list, archetype_pick_rarity, class_rarity)
	#fill in weapon type list
	var weapon_type_filtered_list = filter_classes_by_weapon_type(class_list, archetype_pick_weapon_types, class_rarity)
	#fill in unit type list
	var unit_type_filtered_list = filter_classes_by_unit_type(class_list, archetype_pick_unit_type, class_rarity)
	var combo1 = get_list_in_common(faction_filtered_list,traits_filtered_list)
	var combo2 = get_list_in_common(rarity_filtered_list,combo1)
	var combo3 = get_list_in_common(weapon_type_filtered_list,combo2)
	var combo4 = get_list_in_common(unit_type_filtered_list,combo3)
	return combo4

func get_list_in_common(list_1, list_2):
	var accum = []
	for given_element in list_1:
		if list_2.has(given_element):
			accum.append(given_element)
	return accum

func filter_classes_by_faction(class_list, archetype_pick_factions, class_rarity):
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

func filter_classes_by_trait(class_list, archetype_pick_traits, class_rarity):
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

func filter_classes_by_rarity(class_list, archetype_pick_rarity, class_rarity):
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

func filter_classes_by_weapon_type(class_list, archetype_pick_weapon_types, class_rarity):
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

func filter_classes_by_unit_type(class_list, archetype_pick_unit_type, class_rarity):
	var accum = []
	if archetype_pick_unit_type != "":
		#If there is a reason to filter by faction
		for given_class in class_list:
					if archetype_pick_unit_type == given_class:
						accum.append(given_class)
	else:
		return class_list
	return accum

func filter_commander_by_already_generated(commander_class_keys):
	var accum = []
	for commander_class_key in commander_class_keys:
		if !randomized_commander_types.has(commander_class_key):
			accum.append(commander_class_key)
	if accum.is_empty():
		return commander_class_keys
	else:
		return accum

func randomize_weapon(archetype_pick, weapon_rarity):
	var all_item_types = ItemDatabase.items.keys()
	var all_unlocked_item_types = filter_all_items_by_unlocked(all_item_types)
	var all_non_base_weapon_typess = filter_items_by_base_type(all_unlocked_item_types)
	var archetype_pick_weapon_types = archetype_pick.weapon_type
	var archetype_pick_damage_types = archetype_pick.item_damage_type
	var archetype_pick_scaling_type = archetype_pick.item_scaling_type
	#fill in weapon_type_list
	var weapon_type_filtered_list = filter_items_by_weapon_type(all_non_base_weapon_typess,archetype_pick_weapon_types,weapon_rarity)
	#fill in damage type list
	var damage_type_filtered_list = filter_items_by_damage_type(all_non_base_weapon_typess,archetype_pick_damage_types,weapon_rarity)
	#fill in scaling type list
	var scaling_type_filtered_list = filter_items_by_scaling_type(all_non_base_weapon_typess,archetype_pick_scaling_type,weapon_rarity)
	var combo1 = get_list_in_common(weapon_type_filtered_list,damage_type_filtered_list)
	var combo2 = get_list_in_common(combo1,scaling_type_filtered_list)
	return combo2

func filter_items_by_weapon_type(items_list:Array, weapon_type_list : Array, weapon_rarity):
	var accum = []
	if !weapon_type_list.is_empty():
		#If there is a reason to filter by weapon type
		for item in items_list:
			var item_type : ItemDefinition = ItemDatabase.items.get(item)
			if item_type is WeaponDefinition:
				if weapon_type_list.has(item_type.weapon_type):
					accum.append(item)
	else:
		return items_list
	return accum

func filter_items_by_damage_type(items_list:Array, damage_type_list : Array, weapon_rarity):
	var accum = []
	if !damage_type_list.is_empty():
		#If there is a reason to filter by weapon type
		for item in items_list:
			var item_type : ItemDefinition = ItemDatabase.items.get(item)
			if item_type is WeaponDefinition:
				if damage_type_list.has(item_type.DAMAGE_TYPE):
					accum.append(item)
	else:
		return items_list
	return accum

func filter_items_by_scaling_type(items_list:Array, scaling_type_list : Array, weapon_rarity):
	var accum = []
	if !scaling_type_list.is_empty():
		#If there is a reason to filter by weapon type
		for item in items_list:
			var item_type : ItemDefinition = ItemDatabase.items.get(item)
			if item_type is WeaponDefinition:
				if scaling_type_list.has(item_type.item_scaling_type):
					accum.append(item)
	else:
		return items_list
	return accum

func filter_items_by_base_type(items_list:Array):
	items_list.erase("iron_sword")
	items_list.erase("iron_lance")
	items_list.erase("iron_axe")
	items_list.erase("iron_bow")
	return items_list

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
