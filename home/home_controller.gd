extends Node

enum OVERWORLD_STATES{INIT, START, DRAFT, OVERWORLD}
var  state = OVERWORLD_STATES.INIT

var save_file_name = "PlayerOverworldSave.tres"
var playerOverworldData = PlayerOverworldData.new()

const START_ADVENTURE_SCREEN = preload("res://start adventure/start_adventure.tscn")
const OVERWORLD_SCREEN = preload("res://overworld/overworld.tscn")
const DRAFT_SCREEN = preload("res://unit drafting/unit_drafting.tscn")

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
		state = OVERWORLD_STATES.START
	elif(state == OVERWORLD_STATES.START):
		if not ui_loaded:
			var start_adventure_screen = START_ADVENTURE_SCREEN.instantiate()
			await start_adventure_screen
			$UI.add_child(start_adventure_screen)
			ui_loaded = true
			start_adventure_screen.connect("adventure_begun",adventure_begun)
	elif(state == OVERWORLD_STATES.DRAFT):
		if not ui_loaded:
			var draft_scene = DRAFT_SCREEN.instantiate()
			await draft_scene
			$UI.add_child(draft_scene)
			draft_scene.playerOverworldData = playerOverworldData
			draft_scene.connect("drafting_complete",drafting_complete)
			ui_loaded = true
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


func adventure_begun():
	state = OVERWORLD_STATES.DRAFT
	ui_loaded = false

func drafting_complete(po_data):
	state = OVERWORLD_STATES.OVERWORLD
	playerOverworldData = po_data
	ui_loaded = false
