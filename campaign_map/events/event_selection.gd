extends Control


@onready var icon = $MarginContainer/VBoxContainer/HBoxContainer/EventIconPanelContainer/Icon
@onready var event_selection_container = $MarginContainer/VBoxContainer/HBoxContainer/EventSelectionContainer

@onready var playerOverworldData : PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

func _ready():
	transition_in_animation()
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
	var events = EventDatabase.events
	var chosen_event : Event = events.pick_random()
	#set_event_icon(chosen_event.icon)
	event_selection_container.event = chosen_event
	event_selection_container.update_by_event()

func set_event_icon(texture):
	icon.texture = texture

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
	match event_option.effect:
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
