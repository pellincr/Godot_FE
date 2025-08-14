extends Node2D
class_name CampaignMap

const SCROLL_SPEED := 15
const MAP_ROOM = preload("res://campaign_map/campaign_map_room.tscn")
const MAP_LINE = preload("res://campaign_map/campaign_map_line.tscn")
const BATTLE_PREP = preload("res://ui/battle_preparation/battle_preparation.tscn")
const PLACEHOLDER = preload("res://placeholder/place_holder_scene.tscn")

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

@onready var playerOverworldData : PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)

@onready var campaign_map_generator: CampaignMapGenerator = $CampaignMapGenerator
@onready var lines :Node2D = %Lines
@onready var rooms :Node2D = %Rooms
@onready var visuals :Node2D = $Visuals
@onready var camera_2d : Camera2D = $Camera2D


#var map_data:Array[Array]
#var floors_climbed:int
#var last_room:CampaignRoom
var camera_edge_y : float


func _ready() -> void:
	transition_in_animation()
	campaign_map_generator.FLOORS = playerOverworldData.current_campaign.max_floor_number
	camera_edge_y = CampaignMapGenerator.Y_DIST * (campaign_map_generator.FLOORS - 1)
	if !playerOverworldData.campaign_map_data:
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
	camera_2d.position.y = clamp(camera_2d.position.y,-camera_edge_y,0)



func generate_new_map() -> void:
	playerOverworldData.floors_climbed = 0
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
	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = get_viewport_rect().size.y/2

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
			playerOverworldData.current_level = playerOverworldData.current_campaign.level_pool.battle_levels.pick_random()
			SelectedSaveFile.save(playerOverworldData)
			transition_out_animation()
			get_tree().change_scene_to_packed(BATTLE_PREP)
		CampaignRoom.TYPE.EVENT:
			SelectedSaveFile.save(playerOverworldData)
			transition_out_animation()
			get_tree().change_scene_to_packed(PLACEHOLDER)
		CampaignRoom.TYPE.BOSS:
			playerOverworldData.current_level = playerOverworldData.current_campaign.level_pool.boss_levels.pick_random()
			SelectedSaveFile.save(playerOverworldData)
			transition_out_animation()
			get_tree().change_scene_to_packed(BATTLE_PREP)
		CampaignRoom.TYPE.TREASURE:
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
