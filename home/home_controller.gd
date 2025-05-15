extends Node

enum OVERWORLD_STATES{INIT, OVERWORLD, PARTY, RECRUITMENT, SHOP}
var  state = OVERWORLD_STATES.INIT

var save_file_name = "PlayerOverworldSave.tres"
var playerOverworldData = PlayerOverworldData.new()

const OVERWORLD_SCREEN = preload("res://overworld/overworld.tscn")

var ui_loaded = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var overworld_screen = OVERWORLD_SCREEN.instantiate()
	if FileAccess.file_exists(SelectedSaveFile.selected_save_path + save_file_name):
		load_data()
	else:
		save()


func _process(delta):
	
	if(state == OVERWORLD_STATES.INIT):
		if FileAccess.file_exists(SelectedSaveFile.selected_save_path + save_file_name):
			load_data()
		else:
			save()
		ui_loaded = false
		state = OVERWORLD_STATES.OVERWORLD
	elif(state == OVERWORLD_STATES.OVERWORLD):
		if not ui_loaded:
			var overworld_scene = OVERWORLD_SCREEN.instantiate()
			await overworld_scene
			$UI.add_child(overworld_scene)
			overworld_scene.playerOverworldData = playerOverworldData
			overworld_scene.initialize()
			ui_loaded = true
	
	
	if Input.is_action_just_pressed("save"):
		save()
	if Input.is_action_just_pressed("load"):
		load_data()


func load_data():
	playerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + save_file_name).duplicate(true)
	print("Loaded")

func save():
	ResourceSaver.save(playerOverworldData,SelectedSaveFile.selected_save_path + save_file_name)
	print("Saved")
