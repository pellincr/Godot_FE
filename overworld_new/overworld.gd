extends Panel

var playerOverworldData : PlayerOverworldData
var save_file_name = "PlayerOverworldSave.tres"

# Called when the node enters the scene tree for the first time.
func _ready():
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()

func set_po_data(po_data):
	playerOverworldData = po_data

func save():
	if SelectedSaveFile.verify_save_directory(SelectedSaveFile.selected_save_path):
		DirAccess.make_dir_absolute(SelectedSaveFile.selected_save_path)
	ResourceSaver.save(playerOverworldData,SelectedSaveFile.selected_save_path + save_file_name)
	print("Saved")

func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + save_file_name).duplicate(true)
	#update the gui
	#set_recruit_buttons(recruit_buttons, playerOverworldData.new_recruits)
	#update_manage_party_buttons()
	print("Loaded")

func _on_campaign_selector_node_campaign_selected(campaign):
	playerOverworldData.current_campaign = campaign
	save()
	var army_draft = preload("res://unit drafting/Unit_Commander Draft/army_drafting.tscn")
	#army_draft.instantiate().set_player_overworld_data(playerOverworldData)
	get_tree().change_scene_to_packed(army_draft)
