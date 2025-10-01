extends Control

@onready var background: TextureRect = $background
@onready var event_selection_container: VBoxContainer = $MarginContainer2/EventSelectionContainer

@onready var playerOverworldData : PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

enum STATE {
	INIT,
	OPTION_SELECTION,
	OPTION_UNIT_SELECTION,
	OPTION_UNIT_SELECTION_PREVIEW,
	OPTION_ITEM_SELECTION,
	OPTION_ITEM_SELECTION_PREVIEW,
	PROCESS
}

var state = STATE.INIT
var current_event : Event
var selected_event_option : EventOption

func _ready():
	transition_in_animation()
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
	select_event()

func select_event():
	#get all events
	var events = EventDatabase.events
	
	#Do some filtering based on params here
	var chosen_event : Event = events.pick_random()
	
	#Update the display
	set_event_background(chosen_event.background)
	event_selection_container.event = chosen_event
	event_selection_container.update_by_event()


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
	playerOverworldData.gold = playerOverworldData.gold + event_option.gold_change
	match event_option.effect:
		EventOption.EVENT_EFFECT.CHANGE_RANDOM_UNIT_STATS:
			var target_unit : Unit = playerOverworldData.total_party.pick_random()
			if event_option.unit_stat_change != null:
				target_unit.unit_character.update_stats(event_option.unit_stat_change)
				await create_event_popup(target_unit)
			if event_option.unit_growth_change != null:
				target_unit.unit_character.update_growths(event_option.unit_growth_change)
				await create_event_popup(target_unit)
		EventOption.EVENT_EFFECT.CHANGE_TARGET_UNIT_STATS:
			##Create the unit picker ui
			pass
		EventOption.EVENT_EFFECT.CHANGE_ALL_UNIT_STATS:
			for target_unit : Unit in playerOverworldData.total_party:
				if event_option.unit_stat_change != null:
					target_unit.unit_character.update_stats(event_option.unit_stat_change)
					await create_event_popup(target_unit)
				if event_option.unit_growth_change != null:
					target_unit.unit_character.update_growths(event_option.unit_growth_change)
					await create_event_popup(target_unit)
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
			pass
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
			if event_option.wpn_stat_change != null and target_item != null:
				if target_item is WeaponDefinition:
					event_option.wpn_stat_change.apply_weapon_stats(target_item)
			playerOverworldData.convoy.append(target_item)
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
