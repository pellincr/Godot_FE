extends Control

@onready var background: TextureRect = $background
@onready var event_selection_container: VBoxContainer = $MarginContainer2/EventSelectionContainer

@onready var campaign_header: Control = $CampaignHeader

@onready var playerOverworldData : PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")
const MAIN_PAUSE_MENU_SCENE = preload("res://ui/main_pause_menu/main_pause_menu.tscn")
const CAMPAIGN_INFORMATION_SCENE = preload("res://ui/shared/campaign_information/campaign_information.tscn")
const EVENT_UNIT_SELECT = preload("res://campaign_map/events/event_unit_select/event_unit_select.tscn")
const EVENT_ITEM_SELECT = preload("res://campaign_map/events/event_item_select/event_item_select.tscn")

enum MENU_STATE{
	NONE, PAUSE, CAMPAIGN_INFO
}

enum STATE {
	INIT,
	OPTION_SELECTION,
	OPTION_UNIT_SELECTION,
	OPTION_UNIT_SELECTION_PREVIEW,
	OPTION_ITEM_SELECTION,
	OPTION_ITEM_SELECTION_PREVIEW,
	PROCESS
}

var current_menu_state = MENU_STATE.NONE
var state = STATE.INIT
var current_event : Event
var selected_event_option : EventOption

func _ready():
	transition_in_animation()
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
	campaign_header.set_gold_value_label(playerOverworldData.gold)
	campaign_header.set_floor_value_label(playerOverworldData.floors_climbed)
	campaign_header.set_difficulty_value_label(playerOverworldData.campaign_difficulty)
	select_event()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match current_menu_state:
			MENU_STATE.NONE:
				set_menu_state(MENU_STATE.PAUSE)
			MENU_STATE.PAUSE:
				set_menu_state(MENU_STATE.NONE)
			MENU_STATE.CAMPAIGN_INFO:
				set_menu_state(MENU_STATE.NONE)
	if event.is_action_pressed("campaign_information"):
		if current_menu_state == MENU_STATE.NONE:
			set_menu_state(MENU_STATE.CAMPAIGN_INFO)

func set_menu_state(m_state:MENU_STATE):
	current_menu_state = m_state
	update_by_menu_state()

func _on_menu_closed():
	set_menu_state(MENU_STATE.NONE)


func update_by_menu_state():
	match current_menu_state:
			MENU_STATE.NONE:
				get_child(-1).queue_free()
				event_selection_container.enable_focus()
				event_selection_container.event_option_button_1.grab_focus()
			MENU_STATE.PAUSE:
				var main_pause_menu = MAIN_PAUSE_MENU_SCENE.instantiate()
				add_child(main_pause_menu)
				main_pause_menu.menu_closed.connect(_on_menu_closed)
				event_selection_container.disable_focus()
			MENU_STATE.CAMPAIGN_INFO:
				var campaign_info = CAMPAIGN_INFORMATION_SCENE.instantiate()
				campaign_info.set_po_data(playerOverworldData)
				campaign_info.current_availabilty = CampaignInformation.AVAILABILITY_STATE.FULL_AVAILABLE
				add_child(campaign_info)
				campaign_info.menu_closed.connect(_on_menu_closed)
				event_selection_container.disable_focus()

func select_event():
	#get all events
	var events = EventDatabase.events
	
	#Do some filtering based on params here
	var chosen_event : Event = events.pick_random()
	
	#Update the display
	set_event_background(chosen_event.background)
	event_selection_container.event = chosen_event
	event_selection_container.update_by_event()
	current_event = chosen_event


func set_event_background(texture):
	background.texture = texture

func transition_in_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_out")
	await get_tree().create_timer(.5).timeout
	scene_transition.queue_free()

func transition_out_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5).timeout

func _on_event_option_selected(event_option: EventOption):
	selected_event_option = event_option
	playerOverworldData.gold = playerOverworldData.gold + event_option.gold_change
	match event_option.effect:
		EventOption.EVENT_EFFECT.CHANGE_RANDOM_UNIT_STATS:
			var target_unit : Unit = playerOverworldData.total_party.pick_random()
			if event_option.unit_stat_change != null:
				target_unit.unit_character.update_stats(event_option.unit_stat_change)
				target_unit.update_stats()
				await create_event_popup(target_unit)
			if event_option.unit_growth_change != null:
				target_unit.unit_character.update_growths(event_option.unit_growth_change)
				target_unit.update_growths()
				await create_event_popup(target_unit)
		EventOption.EVENT_EFFECT.CHANGE_TARGET_UNIT_STATS:
			##Create the unit picker ui
			var event_unit_select = EVENT_UNIT_SELECT.instantiate()
			event_unit_select.playerOverworldData = playerOverworldData
			event_unit_select.description = event_option.description
			event_unit_select.background_texture = current_event.background
			self.add_child(event_unit_select)
			await event_unit_select
			
			event_unit_select.connect("unit_selected", _on_target_unit_selected)
			return
		EventOption.EVENT_EFFECT.CHANGE_ALL_UNIT_STATS:
			for target_unit : Unit in playerOverworldData.total_party:
				if event_option.unit_stat_change != null:
					target_unit.unit_character.update_stats(event_option.unit_stat_change)
					#await create_event_popup(target_unit)
				if event_option.unit_growth_change != null:
					target_unit.unit_character.update_growths(event_option.unit_growth_change)
					#await create_event_popup(target_unit)
		EventOption.EVENT_EFFECT.CHANGE_COMMANDER_UNIT_STATS: #TO BE IMPL
			pass
		EventOption.EVENT_EFFECT.CHANGE_RANDOM_WEAPON_STATS: 
			if event_option.wpn_stat_change != null:
				var _wpn_array : Array[WeaponDefinition] = []
				# check convoy
				for item in playerOverworldData.convoy:
					if item is WeaponDefinition: 
						_wpn_array.append(item)
				# check all units
				for player_unit: Unit in playerOverworldData.total_party:
					for item in player_unit.inventory.items:
						if item is WeaponDefinition: 
							_wpn_array.append(item)
				var target_item = _wpn_array.pick_random()
				event_option.wpn_stat_change.apply_weapon_stats(target_item)
				await create_event_popup(target_item)
		EventOption.EVENT_EFFECT.CHANGE_TARGET_WEAPON_STATS:
			##Create the unit picker ui
			var _wpn_array : Array[event_item_selection_info] = []
			if event_option.wpn_stat_change != null:
				# check convoy
				for item in playerOverworldData.convoy:
					if item is WeaponDefinition: 
						var new_info = event_item_selection_info.new(item)
						_wpn_array.append(new_info)
				# check all units
				for player_unit: Unit in playerOverworldData.total_party:
					for item in player_unit.inventory.items:
						if item is WeaponDefinition:
							var new_info = event_item_selection_info.new(item, player_unit.name, player_unit.get_unit_type_definition().icon)
							_wpn_array.append(new_info)

			var event_item_select = EVENT_ITEM_SELECT.instantiate()
			event_item_select.event_item_selection_info = _wpn_array
			event_item_select.background_texture = current_event.background
			self.add_child(event_item_select)
			await event_item_select
			event_item_select.connect("item_panel_pressed", _on_target_item_selected)
			return
		EventOption.EVENT_EFFECT.CHANGE_COMMANDER_WEAPON_STATS:
			if event_option.wpn_stat_change != null:
				var target_item : WeaponDefinition = null
				# check convoy
				for item :ItemDefinition in playerOverworldData.convoy:
					if ItemDatabase.is_commander_weapon(item.db_key):
						if item is WeaponDefinition:
							target_item = item 
							break
				# check all units
				if target_item == null:
					for player_unit: Unit in playerOverworldData.total_party:
						for item in player_unit.inventory.items:
							if ItemDatabase.is_commander_weapon(item.db_key):
								if item is WeaponDefinition:
									target_item = item 
									break
				event_option.wpn_stat_change.apply_weapon_stats(target_item)
		EventOption.EVENT_EFFECT.GIVE_ITEM:
			var target_item : ItemDefinition = null
			#Get the item to give 
			if event_option.target_item != null: #is it a direct call?
				target_item = event_option.target_item.duplicate()
			elif event_option.loot_table != null: #get it from a loot table
				target_item = event_option.loot_table.get_loot()
			else : # This is the catch case
				target_item = ItemDatabase.items["iron_sword"]
			#Lets augment this given item if it has those changes
			playerOverworldData.convoy.append(target_item)
			if event_option.wpn_stat_change != null and target_item != null:
				if target_item is WeaponDefinition:
					event_option.wpn_stat_change.apply_weapon_stats(target_item)
			await create_event_popup(target_item)
		EventOption.EVENT_EFFECT.GIVE_EXPERIENCE:
			pass
		##OLD
		EventOption.EVENT_EFFECT.STRENGTH_ALL:
			#Give All Units +1 Strength
			for unit : Unit in playerOverworldData.total_party:
				unit.stats.strength += 1
		EventOption.EVENT_EFFECT.MAGIC_ALL:
			#Give All Units +1 Magic
			for unit : Unit in playerOverworldData.total_party:
				unit.stats.magic += 1
		EventOption.EVENT_EFFECT.RANDOM_WEAPON:
			await give_random_item(ItemConstants.ITEM_TYPE.WEAPON)
		EventOption.EVENT_EFFECT.RANDOM_CONSUMABLE:
			await give_random_item(ItemConstants.ITEM_TYPE.USEABLE_ITEM)
		EventOption.EVENT_EFFECT.FLEE:
			pass
		EventOption.EVENT_EFFECT.BANDIT_BRIBE:
			playerOverworldData.gold = clampi(playerOverworldData.gold - 400, 0, playerOverworldData.gold)
		EventOption.EVENT_EFFECT.BANDIT_FIGHT:
			for unit in playerOverworldData.total_party.size()/2:
				var target_unit : Unit = playerOverworldData.total_party.pick_random()
				target_unit.hp = clampi(target_unit.hp - 8, 1, target_unit.stats.hp)
				await create_event_popup(target_unit)
		EventOption.EVENT_EFFECT.BANDIT_INTIMIDATE:
			var target_unit : Unit = playerOverworldData.total_party.pick_random()
			var bonus = target_unit.stats.strength / 2
			var intimidation_roll = randi_range(0, 20)
			if intimidation_roll + bonus > 10:
				playerOverworldData.gold = playerOverworldData.gold + 800
			else:
				for unit in playerOverworldData.total_party.size()/2:
					var damage_unit : Unit = playerOverworldData.total_party.pick_random()
					damage_unit.hp = clampi(target_unit.hp - 11, 1, target_unit.stats.hp)
					await create_event_popup(target_unit)
		EventOption.EVENT_EFFECT.TRIAL_MEDITATE:
			for unit_choice in 2:
				var target_unit : Unit = playerOverworldData.total_party.pick_random()
				target_unit.unit_character.stats.resistance += 1
				target_unit.update_stats()
				await create_event_popup(target_unit)
		EventOption.EVENT_EFFECT.TRIAL_CUT_PATH:
			give_random_item(ItemConstants.ITEM_TYPE.WEAPON, "rare")
		EventOption.EVENT_EFFECT.TRIAL_RUSH_THROUGH:
			for unit_choice in 2:
				var target_unit : Unit = playerOverworldData.total_party.pick_random()
				target_unit.unit_character.stats.hp = target_unit.unit_character.stats.hp -3
				#target_unit.hp = clampi(target_unit.unit_character.stats.hp -3, 1, 9999999)
				target_unit.unit_character.stats.speed =  target_unit.unit_character.stats.speed +1
				target_unit.update_stats()
				await create_event_popup(target_unit)
		EventOption.EVENT_EFFECT.GOBLET_DRINK:
			for unit_choice in 2:
				var target_unit : Unit = playerOverworldData.total_party.pick_random()
				target_unit.unit_character.stats.luck =  target_unit.unit_character.stats.luck -4
				target_unit.unit_character.stats.strength +=  1
				target_unit.unit_character.stats.magic += 1
				target_unit.update_stats()
				await create_event_popup(target_unit)
		EventOption.EVENT_EFFECT.GOBLET_SPILL:
			for unit : Unit in playerOverworldData.total_party:
				unit.unit_character.stats.luck += 1
	
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	get_tree().change_scene_to_file("res://campaign_map/campaign_map.tscn")

func give_random_item(item_type : ItemConstants.ITEM_TYPE, desired_rarity : String = ""):
	var item_keys = ItemDatabase.items.keys()
	var available_items = []
	var chosen_item : ItemDefinition
	for key in item_keys:
		var item = ItemDatabase.items[key]
		if desired_rarity != "":
			if item.rarity == RarityDatabase.rarities[desired_rarity]:
				match item_type:
					ItemConstants.ITEM_TYPE.WEAPON:
						if item is WeaponDefinition:
							available_items.append(item)
					ItemConstants.ITEM_TYPE.USEABLE_ITEM:
						if item is ConsumableItemDefinition:
							available_items.append(item)
		else :
			match item_type:
				ItemConstants.ITEM_TYPE.WEAPON:
					if item is WeaponDefinition:
						available_items.append(item)
				ItemConstants.ITEM_TYPE.USEABLE_ITEM:
					if item is ConsumableItemDefinition:
						available_items.append(item)
	if !available_items.is_empty():
		chosen_item = available_items.pick_random()
	else:
		chosen_item = ItemDatabase.items["iron_sword"]
	playerOverworldData.convoy.append(chosen_item)
	await create_event_popup(chosen_item)
	print("Item Recieved")

func _on_event_selection_container_leave_selected():
	transition_out_animation()
	get_tree().change_scene_to_file("res://campaign_map/campaign_map.tscn")

func create_event_popup(effect):
	var event_popup = preload("res://ui/event_effect_popup/event_effect_popup.tscn").instantiate()
	event_popup.effect = effect
	add_child(event_popup)
	await get_tree().create_timer(3).timeout
	event_popup.queue_free()

func _on_target_unit_selected(unit: Unit):
	var create_timeout : bool = false
	match selected_event_option.effect:
		EventOption.EVENT_EFFECT.CHANGE_TARGET_UNIT_STATS:
			if selected_event_option.unit_stat_change != null:
				unit.unit_character.update_stats(selected_event_option.unit_stat_change)
				unit.update_stats()
				create_timeout = true
			if selected_event_option.unit_growth_change != null:
				unit.unit_character.update_growths(selected_event_option.unit_growth_change)
				unit.update_growths()
				create_timeout = true
	if create_timeout:
		await create_event_popup(unit)
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	get_tree().change_scene_to_file("res://campaign_map/campaign_map.tscn")

func _on_target_item_selected(item: ItemDefinition):
	var create_timeout : bool = false
	match selected_event_option.effect:
		EventOption.EVENT_EFFECT.CHANGE_TARGET_WEAPON_STATS:
			if item is WeaponDefinition:
				if selected_event_option.wpn_stat_change != null:
					selected_event_option.wpn_stat_change.apply_weapon_stats(item)
					await create_event_popup(item)
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	get_tree().change_scene_to_file("res://campaign_map/campaign_map.tscn")

class event_item_selection_info:
	var item : ItemDefinition
	var owner_name : String = "Convoy"
	var owner_icon : Texture2D = null
	
	func _init(i : ItemDefinition, o_name : String = "Convoy", o_texture : Texture2D = null) -> void:
		item = i
		owner_name = o_name
		owner_icon = o_texture
