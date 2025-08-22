extends Control


@onready var icon = $MarginContainer/VBoxContainer/HBoxContainer/EventIconPanelContainer/Icon
@onready var event_selection_container = $MarginContainer/VBoxContainer/HBoxContainer/EventSelectionContainer

@onready var playerOverworldData : PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + SelectedSaveFile.save_file_name).duplicate(true)

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

func _ready():
	transition_in_animation()
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
	var events = EventDatabase.events
	var chosen_event : Event = events.pick_random()
	#set_event_icon(chosen_event.icon)
	event_selection_container.event = chosen_event
	event_selection_container.update_by_event()

func set_event_icon(texture):
	icon.texture = texture

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




func _on_event_option_selected(event_option: EventOption):
	match event_option.effect:
		EventOption.EVENT_EFFECT.STRENGTH_ALL:
			#Give All Units +1 Strength
			for unit : Unit in playerOverworldData.total_party:
				unit.stats.strength += 1
		EventOption.EVENT_EFFECT.MAGIC_ALL:
			#Give All Units +1 Magic
			for unit : Unit in playerOverworldData.total_party:
				unit.stats.magic += 1
	SelectedSaveFile.save(playerOverworldData)
	transition_out_animation()
	get_tree().change_scene_to_file("res://campaign_map/campaign_map.tscn")


func _on_event_selection_container_leave_selected():
	transition_out_animation()
	get_tree().change_scene_to_file("res://campaign_map/campaign_map.tscn")
