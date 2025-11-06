extends Control

signal drafting_complete(po_data)

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)

#const treasure_blacklist = ["iron_sword","iron_axe","iron_lance","iron_bow","iron_fist","heal_staff", "shade","smite", "fire_spell","iron_shield","iron_dagger"]

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")
const unit_selector_scene = preload("res://unit drafting/Unit_Commander Draft/unit_draft_selector.tscn")
const unit_draft_scene = preload("res://unit drafting/Unit_Commander Draft/unit_draft.tscn")

const unit_draft_controls_scene = preload("res://unit drafting/Unit_Commander Draft/unit_draft_controls.tscn")
#const menu_enter_effect = preload("res://resources/sounds/ui/menu_confirm.wav")

@onready var campaign_header: Control = $MarginContainer/MainContainer/CampaignHeader

@onready var army_draft_stage_label = $MarginContainer/MainContainer/HBoxContainer/ArmyDraftStageLabel
@onready var pick_amount_label = $MarginContainer/MainContainer/HBoxContainer/PickAmountLabel
@onready var header_label = $MarginContainer/MainContainer/HeaderPanel/HeaderLabel

@onready var army_list_container = $MarginContainer/MainContainer/MarginContainer/ArmyListContainer
@onready var army_list_label = $MarginContainer/MainContainer/MarginContainer/ArmyListContainer/ArmyListLabel
@onready var archetype_icon_container = $MarginContainer/MainContainer/MarginContainer/ArmyListContainer/ArchetypeIconContainer
@onready var main_container: HBoxContainer = $MarginContainer/CenterContainer/MainContainer

@onready var unit_draft_controls = $MarginContainer/UnitDraftControls

@onready var leave_button = $LeaveButton

@onready var current_draft_state = Constants.DRAFT_STATE.UNIT




func _ready():
	transition_in_animation()
	update_to_unit_draft_screen()
	campaign_header.set_gold_value_label(playerOverworldData.gold)
	campaign_header.set_floor_value_label(playerOverworldData.floors_climbed)
	campaign_header.set_difficulty_value_label(playerOverworldData.campaign_difficulty)
	#create_unit_selector_list(4, main_container)
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

func recruiting_complete():
	#queue_free()
	playerOverworldData.completed_drafting = true
	SelectedSaveFile.save(playerOverworldData)
	var campaign_map_scene = "res://campaign_map/campaign_map.tscn"
	transition_out_animation()
	get_tree().change_scene_to_file(campaign_map_scene)

func update_to_unit_draft_screen():
	unit_draft_controls.set_cycle_view_left_visibility(true)
	unit_draft_controls.set_cycle_view_right_visibility(true)
	var unit_draft = unit_draft_scene.instantiate()
	unit_draft.set_po_data(playerOverworldData)
	unit_draft.current_state = current_draft_state
	main_container.add_child(unit_draft)

	#unit_draft.set_control_node(control_node)
	unit_draft.connect("unit_drafted",unit_drafted)


func unit_drafted(unit):
	if unit is Unit:
		playerOverworldData.append_to_array(playerOverworldData.total_party,unit)
		recruiting_complete()

func update_icon(icon1,texture):
	icon1.texture = texture

func set_army_draft_stage_label(text):
	army_draft_stage_label.text = text

func set_pick_amount_label(text):
	pick_amount_label.text = text

func set_header_label(text):
	header_label.text = text



#unit_selectors = create_unit_selector_list(4, main_container)


#num string container -> list of buttons
#Creates a given amount of buttons with the specified text in the entered container
func create_unit_selector_list(selector_count: int, selector_container):
	var accum = []
	for i in range(selector_count):
		var unit_selector : unitDraftSelector = unit_selector_scene.instantiate()
		unit_selector.connect("unit_selected",unit_drafted)
		unit_selector.set_po_data(playerOverworldData)
		unit_selector.current_draft_state = current_draft_state
		selector_container.add_child(unit_selector)
		accum.append(unit_selector)
	accum[0].grab_focus()


func _on_leave_button_pressed():
	transition_out_animation()
	var campaign_map_scene = preload("res://campaign_map/campaign_map.tscn")
	get_tree().change_scene_to_packed(campaign_map_scene)
