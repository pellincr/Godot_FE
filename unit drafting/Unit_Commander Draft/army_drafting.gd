extends Control
var save_file_name = "PlayerOverworldSave.tres"
@onready var current_draft_state = Constants.DRAFT_STATE.COMMANDER
@onready var main_container = $MarginContainer/VBoxContainer
var playerOverworldData : PlayerOverworldData
var control_node : Node = self

signal drafting_complete(po_data)

const unit_draft_scene = preload("res://unit drafting/Unit_Commander Draft/unit_draft.tscn")
const archetype_draft_scene = preload("res://unit drafting/Archetype Draft/ArmyArchetypeDraft.tscn")
const recruit_container_scene = preload("res://overworld/recruit_v_container.tscn")
const unit_draft_controls_scene = preload("res://unit drafting/Unit_Commander Draft/unit_draft_controls.tscn")

@onready var army_draft_stage_label = $MarginContainer/VBoxContainer/HBoxContainer/ArmyDraftStageLabel
@onready var pick_amount_label = $MarginContainer/VBoxContainer/HBoxContainer/PickAmountLabel
@onready var header_label = $MarginContainer/VBoxContainer/HeaderPanel/HeaderLabel


@onready var army_list_container = $MarginContainer/VBoxContainer/MarginContainer/ArmyListContainer
@onready var army_list_label = $MarginContainer/VBoxContainer/MarginContainer/ArmyListContainer/ArmyListLabel
@onready var archetype_icon_container = $MarginContainer/VBoxContainer/MarginContainer/ArmyListContainer/ArchetypeIconContainer

@onready var unit_draft_controls = $"MarginContainer/UnitDraftControls"

var max_unit_draft = 0


func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + save_file_name).duplicate(true)
	#update the gui
	#set_recruit_buttons(recruit_buttons, playerOverworldData.new_recruits)
	#update_manage_party_buttons()
	print("Loaded")

func save():
	ResourceSaver.save(playerOverworldData,SelectedSaveFile.selected_save_path + save_file_name)
	print("Saved")




# Called when the node enters the scene tree for the first time.
func _ready():
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	var unit_draft = unit_draft_scene.instantiate()
	main_container.add_child(unit_draft)
	unit_draft.current_state = current_draft_state
	unit_draft.connect("commander_drafted",commander_selection_complete)



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
	save()
	drafting_complete.emit(playerOverworldData)
	get_tree().change_scene_to_file("res://combat/game.tscn")



func update_to_archetype_screen():
	current_draft_state = Constants.DRAFT_STATE.ARCHETYPE
	army_list_label.visible = true
	unit_draft_controls.set_view_visibility(false)
	unit_draft_controls.set_details_visibility(false)
	#update_army_icon_container()
	var archetype_draft = archetype_draft_scene.instantiate()
	main_container.add_child(archetype_draft)
	archetype_draft.set_po_data(playerOverworldData)
	archetype_draft.connect("archetype_selection_complete",archetype_selection_complete)
	archetype_draft.connect("archetype_selected",archetype_selected)

func update_to_unit_draft_screen():
	current_draft_state = Constants.DRAFT_STATE.UNIT
	unit_draft_controls.set_view_visibility(true)
	unit_draft_controls.set_details_visibility(true)
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
		playerOverworldData.append_to_array(playerOverworldData.convoy, unit)
	playerOverworldData.archetype_allotments.remove_at(0)
	#update_army_icon_container()
	update_archetype_icon_container(unit)
	if (playerOverworldData.archetype_allotments.size() > 0):
		set_pick_amount_label("Pick " + str(playerOverworldData.total_party.size()) + " of " + 
		str(playerOverworldData.archetype_allotments.size() + playerOverworldData.total_party.size()-1))
		set_header_label("Draft a " + playerOverworldData.archetype_allotments[0].name)
	if (playerOverworldData.total_party.size() + playerOverworldData.convoy.size()) >= max_unit_draft + 1:
		recruiting_complete()


func archetype_selected(archetype):
	#update_archetype_icon_container()
	add_archetype_to_archetype_icon_container(archetype)
	if playerOverworldData.current_archetype_count <= playerOverworldData.max_archetype:
		set_pick_amount_label("Pick " + str(playerOverworldData.current_archetype_count+1) + " of " + str(playerOverworldData.max_archetype))


func add_archetype_to_archetype_icon_container(archetype : ArmyArchetypeDefinition):
	var picks = archetype.archetype_picks
	#var panel = Panel.new()
	var hbox = HBoxContainer.new()
	var panel = PanelContainer.new()
	for pick in picks:
		for i in pick.volume:
			var icon = preload("res://resources/sprites/icons/UnitArchetype.png")
			var texture = TextureRect.new()
			texture.texture = icon
			hbox.add_child(texture)
	panel.add_child(hbox)
	archetype_icon_container.add_child(panel)

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
		var current_icon = accum[playerOverworldData.total_party.size()-2]
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
