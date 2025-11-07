extends Control


@onready var treasure_button_1 = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer/TreasureButton1
@onready var weapon_detailed_info_1: Panel = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer/WeaponDetailedInfo

@onready var treasure_button_2 = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer2/TreasureButton2
@onready var weapon_detailed_info_2: Panel = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer2/WeaponDetailedInfo

@onready var treasure_button_3 = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer3/TreasureButton3
@onready var weapon_detailed_info_3: Panel = $MarginContainer/VBoxContainer/TreasureButtonContainer/VBoxContainer3/WeaponDetailedInfo

@onready var leave_button = $LeaveButton

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)

const MAIN_PAUSE_MENU_SCENE = preload("res://ui/main_pause_menu/main_pause_menu.tscn")
const CAMPAIGN_INFORMATION_SCENE = preload("res://ui/shared/campaign_information/campaign_information.tscn")
const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")
const treasure_blacklist = ["iron_sword","iron_axe","iron_lance","iron_bow","iron_fist","minor_heal", "shade","smite", "fire_spell","iron_shield","iron_dagger"]

enum MENU_STATE{
	NONE, PAUSE, CAMPAIGN_INFO
}

var current_menu_state = MENU_STATE.NONE

func _ready():
	transition_in_animation()
	treasure_button_1.grab_focus()
	set_all_buttons()

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
				enable_focus()
				treasure_button_1.grab_focus()
			MENU_STATE.PAUSE:
				var main_pause_menu = MAIN_PAUSE_MENU_SCENE.instantiate()
				add_child(main_pause_menu)
				main_pause_menu.menu_closed.connect(_on_menu_closed)
				disable_focus()
			MENU_STATE.CAMPAIGN_INFO:
				var campaign_info = CAMPAIGN_INFORMATION_SCENE.instantiate()
				campaign_info.set_po_data(playerOverworldData)
				campaign_info.current_availabilty = CampaignInformation.AVAILABILITY_STATE.FULL_AVAILABLE
				add_child(campaign_info)
				campaign_info.menu_closed.connect(_on_menu_closed)
				disable_focus()

func enable_focus():
	treasure_button_1.focus_mode = FOCUS_ALL
	treasure_button_2.focus_mode = FOCUS_ALL
	treasure_button_3.focus_mode = FOCUS_ALL

func disable_focus():
	treasure_button_1.focus_mode = FOCUS_NONE
	treasure_button_2.focus_mode = FOCUS_NONE
	treasure_button_3.focus_mode = FOCUS_NONE

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
