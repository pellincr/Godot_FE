extends ScrollContainer

@onready var main_scroll_container = $MainScrollContainer

@onready var campaign_name_label = $MainScrollContainer/CampaignNameLabel
@onready var win_number_label = $MainScrollContainer/WinNumberLabel

const hoh_unit_container_scene = preload("res://hall_of_heroes/hall_of-Heroes_unit_container.tscn")

@onready var playerOverworldData:PlayerOverworldData

var represented_win_number : int

# Called when the node enters the scene tree for the first time.
func _ready():
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
	if represented_win_number:
		set_campaign_name_label(playerOverworldData.hall_of_heroes_manager.winning_campaigns[represented_win_number].name)
		set_win_number_label(represented_win_number)
		fill_alive_units(represented_win_number)
		fill_dead_units(represented_win_number)

func set_po_data(po_data):
	playerOverworldData = po_data

func set_campaign_name_label(name):
	campaign_name_label.text = name

func set_win_number_label(win_number):
	win_number_label.text = str(win_number)


func fill_alive_units(winning_run_number):
	var alive_units = playerOverworldData.hall_of_heroes_manager.alive_winning_units[winning_run_number]
	for unit in alive_units:
		var hoh_unit_container = hoh_unit_container_scene.instantiate()
		hoh_unit_container.unit = unit
		main_scroll_container.add_child(hoh_unit_container)

func fill_dead_units(winning_run_number):
	var dead_units = playerOverworldData.hall_of_heroes_manager.dead_winning_units[winning_run_number]
	for unit in dead_units:
		var hoh_unit_container = hoh_unit_container_scene.instantiate()
		hoh_unit_container.unit = unit
		main_scroll_container.add_child(hoh_unit_container)
		hoh_unit_container.set_dead_icon_visibility(true)
		hoh_unit_container.modulate = "828282"
