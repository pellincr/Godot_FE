extends Panel

var playerOverworldData : PlayerOverworldData
var save_file_name = "PlayerOverworldSave.tres"

@onready var return_button = $ReturnButton

# Called when the node enters the scene tree for the first time.
func _ready():
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()

func set_po_data(po_data):
	playerOverworldData = po_data


func _on_campaign_selector_node_campaign_selected(campaign):
	playerOverworldData.current_campaign = campaign
	SelectedSaveFile.save(playerOverworldData)
	var army_draft = preload("res://unit drafting/Unit_Commander Draft/army_drafting.tscn")
	#army_draft.instantiate().set_player_overworld_data(playerOverworldData)
	get_tree().change_scene_to_packed(army_draft)


func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://Game Main Menu/main_menu.tscn")
