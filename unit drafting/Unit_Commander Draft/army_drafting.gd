extends Control
@onready var current_draft_state = Constants.DRAFT_STATE.COMMANDER
@onready var main_container = $MarginContainer/MainContainer
var playerOverworldData : PlayerOverworldData
var control_node : Node = self

signal drafting_complete(po_data)

const unit_draft_scene = preload("res://unit drafting/Unit_Commander Draft/unit_draft.tscn")
const archetype_draft_scene = preload("res://unit drafting/Archetype Draft/ArmyArchetypeDraft.tscn")
const unit_draft_controls_scene = preload("res://unit drafting/Unit_Commander Draft/unit_draft_controls.tscn")
#const menu_enter_effect = preload("res://resources/sounds/ui/menu_confirm.wav")

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")
const main_pause_menu_scene = preload("res://ui/main_pause_menu/main_pause_menu.tscn")


@onready var army_draft_stage_label = $MarginContainer/MainContainer/HBoxContainer/ArmyDraftStageLabel
@onready var pick_amount_label = $MarginContainer/MainContainer/HBoxContainer/PickAmountLabel
@onready var header_label = $MarginContainer/MainContainer/HeaderPanel/HeaderLabel

@onready var army_list_container = $MarginContainer/MainContainer/MarginContainer/ArmyListContainer
@onready var army_list_label = $MarginContainer/MainContainer/MarginContainer/ArmyListContainer/ArmyListLabel
@onready var archetype_icon_container = $MarginContainer/MainContainer/MarginContainer/ArmyListContainer/ArchetypeIconContainer

#@onready var unit_draft_controls = $MarginContainer/UnitDraftControls
@onready var controls_ui_container: ControlsUI = $ControlsUIContainer

var max_unit_draft = 0
var current_drafted = []

var pause_menu_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	transition_in_animation()
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	load_data()
	controls_ui_container.current_control_state = ControlsUI.CONTROL_STATE.DRAFT
	controls_ui_container.update_by_control_state()
	if playerOverworldData.floors_climbed > 0:
		#if drafting in the middle of a campaign
		current_draft_state = Constants.DRAFT_STATE.ARCHETYPE
		update_to_archetype_screen()
		set_army_draft_stage_label("Army Draft - Stage 2 of 3")
		set_pick_amount_label("Pick 1 of " + str(playerOverworldData.max_archetype))
		set_header_label("Draft an Army Archetype")
	else:
		#if it's the first draft of the campaign
		var unit_draft = unit_draft_scene.instantiate()
		unit_draft.current_state = current_draft_state
		unit_draft.set_po_data(playerOverworldData)
		main_container.add_child(unit_draft)
		unit_draft.connect("commander_drafted",commander_selection_complete)
		if playerOverworldData.current_campaign.name == "Tutorial":
			var tutorial_panel = preload("res://ui/tutorial/tutorial_panel.tscn").instantiate()
			tutorial_panel.current_state = TutorialPanel.TUTORIAL.DRAFT
			tutorial_panel.tutorial_completed.connect(tutorial_completed.bind(unit_draft.get_first_selector()))
			add_child(tutorial_panel)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if !pause_menu_open:
			var main_pause_menu = main_pause_menu_scene.instantiate()
			add_child(main_pause_menu)
			main_pause_menu.menu_closed.connect(_on_menu_closed)
			disable_screen_focus()
			pause_menu_open = true
		else:
			get_child(-1).queue_free()
			_on_menu_closed()

func set_player_overworld_data(po_data):
	playerOverworldData = po_data

func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)
	print("Loaded")


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

func tutorial_completed(selector):
	await Input.is_action_pressed("ui_accept")
	selector.grab_focus()

func commander_selection_complete(commander):
	playerOverworldData.append_to_array(playerOverworldData.total_party,commander)
	update_to_archetype_screen()
	update_archetype_icon_container(commander)
	set_army_draft_stage_label("Army Draft - Stage 2 of 3")
	set_pick_amount_label("Pick 1 of " + str(playerOverworldData.max_archetype))
	set_header_label("Draft an Army Archetype")

func archetype_selection_complete(po_data):
	playerOverworldData = po_data
	max_unit_draft = playerOverworldData.archetype_allotments.size()
	update_to_unit_draft_screen()
	set_army_draft_stage_label("Army Draft - Stage 3 of 3")
	set_pick_amount_label("Pick 1 of " + str(playerOverworldData.archetype_allotments.size()))
	set_header_label("Draft a " + playerOverworldData.archetype_allotments[0].name)

func recruiting_complete():
	#queue_free()
	playerOverworldData.completed_drafting = true
	SelectedSaveFile.save(playerOverworldData)
	#drafting_complete.emit(playerOverworldData)
	#get_tree().change_scene_to_file("res://combat/game.tscn")
	#var battle_prep_scene = preload("res://ui/battle_preparation/battle_preparation.tscn")
	#battle_prep_scene.instantiate().set_po_data(playerOverworldData)
	var campaign_map_scene = preload("res://campaign_map/campaign_map.tscn")
	transition_out_animation()
	get_tree().change_scene_to_packed(campaign_map_scene) #battle_prep_scene"res://combat/levels/test_level_1/test_game_1.tscn"



func update_to_archetype_screen():
	#$AudioStreamPlayer.stream = menu_enter_effect
	#$AudioStreamPlayer.play()
	#AudioManager
	current_draft_state = Constants.DRAFT_STATE.ARCHETYPE
	army_list_label.visible = true
	#unit_draft_controls.set_cycle_view_left_visibility(false)
	#unit_draft_controls.set_cycle_view_right_visibility(false)
	#update_army_icon_container()
	var archetype_draft = archetype_draft_scene.instantiate()
	main_container.add_child(archetype_draft)
	archetype_draft.set_po_data(playerOverworldData)
	archetype_draft.connect("archetype_selection_complete",archetype_selection_complete)
	archetype_draft.connect("archetype_selected",archetype_selected)

func update_to_unit_draft_screen():
	#$AudioStreamPlayer.stream = menu_enter_effect
	#$AudioStreamPlayer.play()
	current_draft_state = Constants.DRAFT_STATE.UNIT
	#unit_draft_controls.set_cycle_view_left_visibility(true)
	#unit_draft_controls.set_cycle_view_right_visibility(true)
	var unit_draft = unit_draft_scene.instantiate()
	unit_draft.set_po_data(playerOverworldData)
	unit_draft.current_state = current_draft_state
	main_container.add_child(unit_draft)

	unit_draft.set_control_node(control_node)
	unit_draft.connect("unit_drafted",unit_drafted)


func unit_drafted(unit):
	if unit is Unit:
		playerOverworldData.append_to_array(playerOverworldData.total_party,unit)
	elif unit is WeaponDefinition:
		playerOverworldData.append_to_array(playerOverworldData.convoy, unit.duplicate())
	current_drafted.append(unit)
	playerOverworldData.archetype_allotments.remove_at(0)
	#update_army_icon_container()
	update_archetype_icon_container(unit)
	
	if (playerOverworldData.archetype_allotments.size() > 0):
		set_pick_amount_label("Pick " + str(playerOverworldData.total_party.size()) + " of " + 
		str(playerOverworldData.archetype_allotments.size() + playerOverworldData.total_party.size()-1))
		set_header_label("Draft a " + playerOverworldData.archetype_allotments[0].name)
	#if (playerOverworldData.total_party.size() + playerOverworldData.convoy.size()) >= max_unit_draft + 1:
	if current_drafted.size() >= max_unit_draft:
		recruiting_complete()


func archetype_selected(archetype):
	#update_archetype_icon_container()
	add_archetype_to_archetype_icon_container(archetype)
	if playerOverworldData.current_archetype_count <= playerOverworldData.max_archetype:
		set_pick_amount_label("Pick " + str(playerOverworldData.current_archetype_count+1) + " of " + str(playerOverworldData.max_archetype))


func add_archetype_to_archetype_icon_container(archetype : ArmyArchetypeDefinition):
	var picks := archetype.archetype_picks
	#var panel = Panel.new()
	var hbox = HBoxContainer.new()
	var panel = PanelContainer.new()
	for pick in picks:
		for i in pick.volume:
			var icon
			if pick is armyArchetypePickWeaponDefinition:
				icon = preload("res://unit drafting/Archetype Draft/archetype_icons/item_archetype_icon.tscn").instantiate()
				icon.item_archetype_pick = pick
				hbox.add_child(icon)
				panel.add_child(hbox)
				archetype_icon_container.add_child(panel)
				icon.update_by_archetype_pick()
			else:
				#icon = preload("res://resources/sprites/icons/UnitArchetype.png")
				#var texture = TextureRect.new()
				#texture.texture = icon
				icon = preload("res://unit drafting/Archetype Draft/archetype_icons/unit_archetype_icon.tscn").instantiate()
				icon.unit_archetype_pick = pick
				hbox.add_child(icon)
				panel.add_child(hbox)
				archetype_icon_container.add_child(panel)
				icon.update_by_archetype_pick()

func update_archetype_icon_container(unit):
	#clear_archetype_icons()
	var archetype_icon_children = archetype_icon_container.get_children()
	if archetype_icon_children.is_empty():
		var icon = unit.icon
		var texture = TextureRect.new()
		texture.texture = icon
		texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		archetype_icon_container.add_child(texture)
	else:
		var accum = []
		for item in archetype_icon_children:
			if item is PanelContainer:
				for hbox_container in item.get_children():
					accum.append_array(hbox_container.get_children())
		var current_icon
		#if !playerOverworldData.current_level > 0:
			#current_icon = accum[playerOverworldData.total_party.size()-2]
		current_icon = accum[current_drafted.size()-1]
		#else:
		#	current_icon = accum[playerOverworldData.archetype_allotments]
		update_icon(current_icon,unit.icon)

func update_icon(icon1,texture):
	icon1.texture = texture

func clear_archetype_icons():
	var children = archetype_icon_container.get_children()
	for child in children:
		child.queue_free()


func set_army_draft_stage_label(text):
	army_draft_stage_label.text = text


func set_pick_amount_label(text):
	pick_amount_label.text = text

func set_header_label(text):
	header_label.text = text


func enable_screen_focus():
	var draft_scene = main_container.get_child(-1)
	draft_scene.enable_selector_focus()

func disable_screen_focus():
	var draft_scene = main_container.get_child(-1)
	draft_scene.disable_selector_focus()

func _on_menu_closed():
	enable_screen_focus()
	pause_menu_open = false
	main_container.get_child(-1).get_first_selector().grab_focus()
