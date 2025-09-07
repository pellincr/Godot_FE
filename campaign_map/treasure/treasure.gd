extends Control


@onready var treasure_button_1 = $MarginContainer/VBoxContainer/TreasureButtonContainer/TreasureButton1
@onready var treasure_button_2 = $MarginContainer/VBoxContainer/TreasureButtonContainer/TreasureButton2
@onready var treasure_button_3 = $MarginContainer/VBoxContainer/TreasureButtonContainer/TreasureButton3

@onready var leave_button = $LeaveButton

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

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
	var valid_treasure_items
	for item_key in ItemDatabase.items.keys():
		var item : ItemDefinition = ItemDatabase.items[item_key]
		if item.rarity != RarityDatabase.get("common"):
			valid_treasure_items.append(item_key)
	var r_key = valid_treasure_items.pick_random()
	
	return ItemDatabase.items[r_key]

func set_all_buttons():
	var item1 = randomize_item_selection()
	set_button_text(treasure_button_1,item1.name)
	set_button_icon(treasure_button_1,item1.icon)
	treasure_button_1.pressed.connect(_on_treasure_selected.bind(item1))
	var item2 = randomize_item_selection()
	set_button_text(treasure_button_2,item2.name)
	set_button_icon(treasure_button_2,item2.icon)
	treasure_button_2.pressed.connect(_on_treasure_selected.bind(item2))
	var item3 = randomize_item_selection()
	set_button_text(treasure_button_3,item3.name)
	set_button_icon(treasure_button_3,item3.icon)
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
