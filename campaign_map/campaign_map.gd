extends Node2D
class_name CampaignMap

const SCROLL_SPEED := 15
const MAP_ROOM = preload("res://campaign_map/campaign_map_room.tscn")
const MAP_LINE = preload("res://campaign_map/campaign_map_line.tscn")
#const BATTLE_PREP = preload("res://ui/battle_preparation/battle_preparation.tscn")
#const BATTLE_PREP = preload("res://ui/battle_prep_new/battle_prep.tscn")

const EVENT_SELECT = preload("res://campaign_map/events/event_selection.tscn")
const TREASURE_SCENE = preload("res://campaign_map/treasure/treasure.tscn")
const RECRUITMENT_SCENE = preload("res://campaign_map/recruitment/recruitment.tscn")
const PLACEHOLDER = preload("res://campaign_map/placeholder/place_holder_scene.tscn")

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

@onready var playerOverworldData : PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)

@onready var campaign_map_generator: CampaignMapGenerator = $CampaignMapGenerator
@onready var lines :Node2D = %Lines
@onready var rooms :Node2D = %Rooms
@onready var visuals :Node2D = $Visuals
@onready var camera_2d : Camera2D = $Camera2D

const menu_music = preload("res://resources/music/Menu_-_Dreaming_Darkly.ogg")
const main_pause_menu_scene = preload("res://ui/main_pause_menu/main_pause_menu.tscn")
#var map_data:Array[Array]
#var floors_climbed:int
#var last_room:CampaignRoom
var camera_edge_y : float
var pause_menu_open = false

var tutorial_complete := true

func _ready() -> void:
	AudioManager.play_music("menu_theme")
	transition_in_animation()
	campaign_map_generator.FLOORS = playerOverworldData.current_campaign.max_floor_number
	campaign_map_generator.NUMBER_OF_REQUIRED_COMBAT_MAPS = playerOverworldData.current_campaign.number_of_required_combat_maps
	camera_edge_y = CampaignMapGenerator.Y_DIST * (campaign_map_generator.FLOORS -1)
	if !playerOverworldData.campaign_map_data:
		#If this is the first time loading into the campaign map for the campaign
		generate_new_map()
		unlock_floor(0)
	else:
		create_map()
		if playerOverworldData.floors_climbed > 0:
			unlock_next_rooms()
		else:
			unlock_floor(0)
	
	grab_first_available_room_foucs()
	set_map_room_focus_neighbors()
	SelectedSaveFile.save(playerOverworldData)
	
	if playerOverworldData.current_campaign.name == "Tutorial" and playerOverworldData.floors_climbed == 0:
			#If it's the tutorial campaign, show the tutorial
			tutorial_complete = false
			var tutorial_panel = preload("res://ui/tutorial/tutorial_panel.tscn").instantiate()
			tutorial_panel.current_state = TutorialPanel.TUTORIAL.CAMPAIGN_MAP
			camera_2d.add_child(tutorial_panel)
			tutorial_panel.tutorial_completed.connect(tutorial_completed)


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


func _input(event:InputEvent) ->void:
	if event.is_action_pressed("camera_zoom_in") or event.is_action_pressed("ui_up"):
		camera_2d.position.y -= SCROLL_SPEED
	if event.is_action_pressed("camera_zoom_out") or event.is_action_pressed("ui_down"):
		camera_2d.position.y += SCROLL_SPEED
	camera_2d.position.y = clamp(camera_2d.position.y,-camera_edge_y/4,camera_edge_y/2)
	if event.is_action_pressed("ui_cancel"):
		if !pause_menu_open and tutorial_complete:
			var main_pause_menu = main_pause_menu_scene.instantiate()
			camera_2d.add_child(main_pause_menu)
			main_pause_menu.menu_closed.connect(_on_menu_closed)
			disable_available_map_room_focus()
			pause_menu_open = true
		else:
			camera_2d.get_child(-1).queue_free()
			_on_menu_closed()

func tutorial_completed():
#	camera_2d.zoom = Vector2(3,3)
	rooms.get_child(0).grab_focus()
	tutorial_complete = true

func generate_new_map() -> void:
	playerOverworldData.floors_climbed = 0
	playerOverworldData.combat_maps_completed = 0
	playerOverworldData.campaign_map_data = campaign_map_generator.generate_map()
	create_map()

func create_map() -> void:
	for current_floor: Array in playerOverworldData.campaign_map_data:
		for room:CampaignRoom in current_floor:
			if room.next_rooms.size() > 0:
				_spawn_room(room)
	#Boss room has no next room but we need to spawn it
	var middle := floori(CampaignMapGenerator.MAP_WIDTH * .5)
	_spawn_room(playerOverworldData.campaign_map_data[campaign_map_generator.FLOORS-1][middle])
	
	var map_width_pixels := CampaignMapGenerator.X_DIST * (CampaignMapGenerator.MAP_WIDTH-1)
	var map_height_pixels := CampaignMapGenerator.Y_DIST * (campaign_map_generator.FLOORS)
	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = (get_viewport_rect().size.y - map_height_pixels)/2


func unlock_floor(which_floor:int = playerOverworldData.floors_climbed) -> void:
	for map_room : CampaignMapRoom in rooms.get_children():
		if map_room.room.row == which_floor:
			map_room.available = true


func unlock_next_rooms() -> void:
	for map_room : CampaignMapRoom in rooms.get_children():
		if playerOverworldData.last_room.next_rooms.has(map_room.room):
			map_room.available = true

func show_map() -> void:
	show()
	camera_2d.enabled = true

func hide_map() -> void:
	hide()
	camera_2d.enabled = false

func _spawn_room(room:CampaignRoom) -> void:
	var new_map_room := MAP_ROOM.instantiate() as CampaignMapRoom
	rooms.add_child(new_map_room)
	new_map_room.room = room
	new_map_room.selected.connect(_on_map_room_selected)
	_connect_lines(room)
	
	if room.selected and room.row < playerOverworldData.floors_climbed:
		#Show as selected because it was already visited
		new_map_room.show_selected()

func _connect_lines(room:CampaignRoom)->void:
	if room.next_rooms.is_empty():
		return
	for next: CampaignRoom in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)

func _on_map_room_selected(room:CampaignRoom) ->void:
	for map_room :CampaignMapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			#Make the rooms on the same floor unavailable
			map_room.available = false
	playerOverworldData.last_room = room
	playerOverworldData.floors_climbed += 1
	match  room.type:
		CampaignRoom.TYPE.BATTLE:
			var battle_tier = playerOverworldData.combat_maps_completed
			if playerOverworldData.current_campaign.level_pool.battle_levels.has(playerOverworldData.combat_maps_completed):
				playerOverworldData.current_level = playerOverworldData.current_campaign.level_pool.battle_levels.get(playerOverworldData.combat_maps_completed).pick_random()
			SelectedSaveFile.save(playerOverworldData)
			transition_out_animation()
			#get_tree().change_scene_to_packed(BATTLE_PREP)
			playerOverworldData.began_level = true
			get_tree().change_scene_to_packed(playerOverworldData.current_level)
		CampaignRoom.TYPE.EVENT:
			SelectedSaveFile.save(playerOverworldData)
			transition_out_animation()
			get_tree().change_scene_to_packed(EVENT_SELECT)
		CampaignRoom.TYPE.BOSS:
			if playerOverworldData.current_campaign.level_pool.battle_levels.has("BOSS") and not playerOverworldData.current_campaign.level_pool.battle_levels.get("BOSS").is_empty():
				playerOverworldData.current_level = playerOverworldData.current_campaign.level_pool.battle_levels.get("BOSS").pick_random()
			SelectedSaveFile.save(playerOverworldData)
			transition_out_animation()
			#get_tree().change_scene_to_packed(BATTLE_PREP)
			playerOverworldData.began_level = true
			get_tree().change_scene_to_packed(playerOverworldData.current_level)
		CampaignRoom.TYPE.TREASURE:
			SelectedSaveFile.save(playerOverworldData)
			transition_out_animation()
			get_tree().change_scene_to_packed(TREASURE_SCENE)
		CampaignRoom.TYPE.SHOP:
			SelectedSaveFile.save(playerOverworldData)
			transition_out_animation()
			get_tree().change_scene_to_packed(PLACEHOLDER)
		CampaignRoom.TYPE.RECRUITMENT:
			SelectedSaveFile.save(playerOverworldData)
			transition_out_animation()
			get_tree().change_scene_to_packed(RECRUITMENT_SCENE)
		CampaignRoom.TYPE.ELITE:
			SelectedSaveFile.save(playerOverworldData)
			transition_out_animation()
			get_tree().change_scene_to_packed(PLACEHOLDER)

func grab_first_available_room_foucs() -> void:
	for map_room:CampaignMapRoom in rooms.get_children():
		if map_room.available:
			map_room.grab_focus()


func set_map_room_focus_neighbors() -> void:
	var available_map_rooms :Array[CampaignMapRoom] = _get_available_map_rooms()
	for room_index in available_map_rooms.size():
		if available_map_rooms.size() > 1:
			if room_index == 0:
				available_map_rooms[room_index].focus_neighbor_right = available_map_rooms[room_index+1].get_path()
			elif room_index == available_map_rooms.size() - 1:
				available_map_rooms[room_index].focus_neighbor_left = available_map_rooms[room_index-1].get_path()
			else:
				available_map_rooms[room_index].focus_neighbor_right = available_map_rooms[room_index+1].get_path()
				available_map_rooms[room_index].focus_neighbor_left = available_map_rooms[room_index-1].get_path()

func _get_available_map_rooms() -> Array[CampaignMapRoom]:
	var available_rooms : Array[CampaignMapRoom]
	for map_room : CampaignMapRoom in rooms.get_children():
		if map_room.available:
			available_rooms.append(map_room)
	return available_rooms

func set_available_map_room_focus(focus):
	var available_map_rooms := _get_available_map_rooms()
	for map_room in available_map_rooms:
		map_room.focus_mode = focus

func disable_available_map_room_focus():
	set_available_map_room_focus(Control.FOCUS_NONE)

func enable_available_map_room_focus():
	set_available_map_room_focus(Control.FOCUS_ALL)

func _on_menu_closed():
	enable_available_map_room_focus()
	_get_available_map_rooms()[0].grab_focus()
	pause_menu_open = false
