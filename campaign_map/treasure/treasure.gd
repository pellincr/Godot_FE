extends Control


@onready var treasure_button_1 = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer/TreasureButton1
@onready var weapon_detailed_info_1: Panel = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer/WeaponDetailedInfo

@onready var treasure_button_2 = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer2/TreasureButton2
@onready var weapon_detailed_info_2: Panel = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer2/WeaponDetailedInfo

@onready var treasure_button_3 = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer3/TreasureButton3
@onready var weapon_detailed_info_3: Panel = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer3/WeaponDetailedInfo

@onready var leave_button = $LeaveButton

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")
const treasure_blacklist = ["iron_sword","iron_axe","iron_lance","iron_bow","iron_fist","minor_heal", "shade","smite", "fire_spell","iron_shield","iron_dagger"]

func _ready():
	transition_in_animation()
	treasure_button_1.grab_focus()
	set_all_buttons()

#
# Plays the transition animation on combat map begin
#
func transition_in_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_out")
	await get_tree().create_timer(0.5).timeout
	scene_transition.queue_free()

#
# transitions out the animation played on combat map begin
#
func transition_out_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5).timeout

func set_button_text(button:Button, text:String):
	button.text = text

func set_button_icon(button:Button, texture:Texture2D):
	button.icon = texture

func randomize_item_selection() -> ItemDefinition:
	var valid_treasure_items = []
	for item_key in ItemDatabase.items.keys():
		if item_key not in treasure_blacklist:
			var roll = randi_range(0, 100)
			if roll < 1:
				if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["legendary"]:
					valid_treasure_items.append(item_key)
			elif roll < 10:
				if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["mythical"]:
					valid_treasure_items.append(item_key)
			elif roll < 25:
				if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["rare"]:
					valid_treasure_items.append(item_key)
			elif roll < 40:
				if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["rare"]:
					valid_treasure_items.append(item_key)
			elif roll < 65:
				if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["uncommon"]:
					valid_treasure_items.append(item_key)
			else :
				if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["common"]:
					valid_treasure_items.append(item_key)
			valid_treasure_items.append(item_key)
	var r_key = valid_treasure_items.pick_random()
	
	return ItemDatabase.items[r_key]

func set_all_buttons():
	var item1 = randomize_item_selection()
	#set_button_text(treasure_button_1,item1.name)
	weapon_detailed_info_1.item = item1
	weapon_detailed_info_1.update_by_item()
	#set_button_icon(treasure_button_1,item1.icon)
	treasure_button_1.pressed.connect(_on_treasure_selected.bind(item1))
	var item2 = randomize_item_selection()
	weapon_detailed_info_2.item = item2
	weapon_detailed_info_2.update_by_item()
	#set_button_text(treasure_button_2,item2.name)
	#set_button_icon(treasure_button_2,item2.icon)
	treasure_button_2.pressed.connect(_on_treasure_selected.bind(item2))
	var item3 = randomize_item_selection()
	#set_button_text(treasure_button_3,item3.name)
	#set_button_icon(treasure_button_3,item3.icon)
	weapon_detailed_info_3.item = item3
	weapon_detailed_info_3.update_by_item()
	treasure_button_3.pressed.connect(_on_treasure_selected.bind(item3))

func _on_treasure_selected(item):
	playerOverworldData.convoy.append(item)
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	var campaign_map_scene = preload("res://campaign_map/campaign_map.tscn")
	get_tree().change_scene_to_file("res://campaign_map/campaign_map.tscn")


func _on_leave_button_pressed():
	transition_out_animation()
	var campaign_map_scene = preload("res://campaign_map/campaign_map.tscn")
	get_tree().change_scene_to_packed(campaign_map_scene)
